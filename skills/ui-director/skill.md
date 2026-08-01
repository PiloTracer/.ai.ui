---
name: ui-director
description: >-
  Orchestration skill that receives free-text UI requests, determines the
  optimal skill chain from available ui-* skills, executes the workflow,
  or flags when a new skill must be created. The user does not need to
  know individual skills — just describe what they want.
---

# ui-director

**Role:** Top-level orchestrator. You are the user's single point of contact for all UI work. You receive natural-language requests and map them to the correct sequence of `ui-*` skills, standards, concepts, and verifiers. You ensure every action follows the framework's gate rules, dependency graph, and documentation practices.

**Hard rules:**
1. Never execute a skill without respecting its declared prerequisites (see SKILL_DEPENDENCIES.md).
2. Before any write operation, read `{HANDOFF_UI}` and `{UI_ITERATION_CARRIER}` for session context.
3. After completing a workflow, always update `{HANDOFF_UI}` with what was done, what's next, and any blockers.
4. Do not invent skills or modes not registered in `skills/README.md`. If a request cannot be fulfilled by existing skills, follow the "New skill protocol" below.
5. Never duplicate Agent OS skills (`@session-control`, `@code-implementation`, `@plan-master`, `@project-bootstrap`, `@db-migration`, etc.) — redirect the user.
6. Never write artifacts under `.ai.ui/` — project work goes to `.work.ui/`.

## Modes

| Mode | Action |
|------|--------|
| `- <free-text request>` | Parse intent, classify, route to the correct skill chain, execute |
| `status` | Report current UI state: bootstrap, foundation, screen map, active iteration, pending verifications |
| `help` | Display this skill's purpose, available skills summary, and invocation examples |

## Free-text intake contract

When the user invokes `@ui-director` with natural language, follow this write/structure/format/channel discipline so the request becomes the correct `ui-*` skill invocation and is recorded in `.work.ui/` memory.

### 1. Capture
- Preserve the user's exact wording (quote it in `{HANDOFF_UI}`).
- Do not silently rewrite a UI request into backend work.

### 2. Load context
- Read `{HANDOFF_UI}` and `{UI_ITERATION_CARRIER}` before classifying.
- If either file is missing, treat as bootstrap state and note it.

### 3. Classify (intent → bucket)
- Match by intent, not keyword. Use the bucket table in § Orchestration protocol.
- If the intent is engineering/backend/DB/API, redirect to `@ai-director` or `@x-director`.
- If the intent spans UI + engineering, route to `@x-director`.
- If unclear, run a short probe (max 3 questions) or route to `@ui-process-router` / `@ui-design-foundation probe`.

### 4. Channel (bucket → skill chain)
- Map the bucket to the exact skill chain from § Route / Shortcut chains.
- Check `SKILL_DEPENDENCIES.md` gates before invoking each skill.
- Use canonical invocation syntax: `@<skill-id> <mode> - <argument>` with ASCII hyphen `-`.

### 5. Structure/format the record
After the workflow completes or changes state, append to `{HANDOFF_UI}` using this exact shape:

```markdown
## Latest action (@ui-director)
**Date:** YYYY-MM-DD
**Request:** "<user's original request>"
**Classified bucket:** <bucket-name>
**Executed:**
1. @ui-<skill> <mode> - <arg> → <result>
2. ...
**Blockers:** <any unresolved items | none>
**Next recommended:** @ui-<skill> <mode> - <arg>
```

Also update `{UI_ITERATION_CARRIER}` § **Recommended next** when the UI build cycle advances.

### 6. External resources & verify policy

When routing to foundation, verify, a11y, copy, or design-system skills, agents load curated external references from **[`resources/web-research-2026.md`](../../resources/web-research-2026.md)** (in-repo — no external fetch required to discover them). Apply:

| Policy | Rule |
|--------|------|
| License | Commercial-safe only — see doc header; §7 exclusions |
| URLs | Verify live before citing ([§8.1](../../resources/web-research-2026.md#81-verify-resource-urls-skill-rule)) |
| Verify default | **Static first** — rubrics, jest-axe, token-lint, Storybook build |
| Browser control | Opt-in only — explicit operator authorization required ([§8.2](../../resources/web-research-2026.md#82-browser-control-authorization-skill-rule)) |

**Skill → research § map:** foundation §1 · a11y §2 · visual-verify §3+§6 · design-system §4 · copy §5 · behavior OSS [`control-platforms.md`](../../resources/control-platforms.md).

## Orchestration protocol

When user says `@ui-director - <anything>`:

### 1. PARSE & CLASSIFY

Read `{HANDOFF_UI}` and `{UI_ITERATION_CARRIER}` for context. Classify the request into one of the following buckets. Match by intent, not keywords.

| Bucket | Signals | Lead skill |
|--------|---------|------------|
| `bootstrap` | "start UI", "set up project", "first time", ".work.ui missing" | `ui-bootstrap` |
| `approach` | "what should I build?", "classify my project", "which archetype", "is this a saas?" | `ui-project-approach` |
| `style` | "set up tailwind", "which CSS approach", "change styling" | `ui-style-stack` |
| `foundation` | "establish design tokens", "create UI foundation", "vision and principles", "screen map", "design system plan" | `ui-design-foundation` |
| `foundation-probe` | "understand my UI", "vague brand", "uncertain scope", "probe the design" | `ui-design-foundation probe` |
| `screen-request` | "I need a page for X", "new screen for Y", "spec out Z", "add a flow" | `ui-screen-spec intake` → `create` |
| `screen-spec` | "review a spec", "amend spec", "check screen spec" | `ui-screen-spec review/amend` |
| `design-system` | "init catalog", "add component to design system", "storybook", "primitives" | `ui-design-system` |
| `build` | "build the UI", "implement screen X", "code the components", "start/continue iteration" | `ui-component-build` |
| `build-probe` | "is the roadmap ready?", "check build readiness", "can we start building?" | `ui-component-build probe` |
| `verify-visual` | "check visuals", "visual regression", "token audit", "craft compliance" | `ui-visual-verify` |
| `verify-a11y` | "accessibility check", "WCAG audit", "a11y" | `ui-accessibility-audit` |
| `copy` | "write UI copy", "microcopy", "button labels", "error messages", "empty states", "copy review", "copy audit", "set UI voice" | `ui-copy` |
| `concept` | "run UIS prompt", "check visual hierarchy", "motion design", "intuitive UX", "data viz quality", "surface craft" | `ui-concept-run` |
| `audit` | "audit everything", "run verifiers", "check readiness", "traceability" | `ui-plan-verify` |
| `deploy` | "deploy framework to another project", "copy to repo", "clone to path", "thin-client bootstrap", "lightweight setup (skills load from source)" | `deploy-basic` (thin client) / `deploy-files` / `deploy-repo` |
| `desktop` | "desktop app", "native window", "PyQt", "FLET", "Qt app", "python GUI" | `ui-python-desktop stack set - <flet\|pyside6\|pyqt>` → `scaffold` |
| `router` | "how do I...?", "where is...?", "what skill...?" | `ui-process-router` |
| `session-control` | "start session", "close session", "commit" | Redirect to `@session-control` (Agent OS) |
| `backend` | "backend work", "database", "API", "migration" | Redirect to Agent OS |
| `new-skill-needed` | No existing skill can fulfill the request — see protocol below | Create new skill |
| `unsure` | Cannot classify, or user request is underspecified | `@ui-design-foundation probe` or `@ui-process-router` |

### 2. ROUTE

Map the classified bucket to the correct skill chain. Respect the dependency graph (SKILL_DEPENDENCIES.md). If a prerequisite is not met, report the gate and run the prerequisite first.

**Typical full flow:**
```
@ui-bootstrap init
  → @ui-project-approach - <description>
    → @ui-style-stack set - <stack>
      → @ui-design-foundation greenfield
        → @ui-design-foundation probe (if needed)
          → @ui-design-foundation certify screen-spec-ready
            → @ui-screen-spec intake/create
              → @ui-design-system init
                → @ui-component-build plan - S{0|N}
                  → @ui-component-build start
                    → @ui-component-build continue (loop)
                      → @ui-visual-verify milestone
                        → @ui-accessibility-audit milestone
                          → @ui-plan-verify audit
                            → @ui-component-build complete
```

**Shortcut chains (common requests):**

| User says | Execute |
|-----------|---------|
| "Start a new UI project for a SaaS product" | `@ui-project-approach - SaaS product` → `@ui-style-stack set - tailwind` → `@ui-design-foundation greenfield` |
| "I need a team management page" | Check if `screen-spec-ready`. If yes → `@ui-screen-spec create - team-members` → build. If no → run prerequisite first. |
| "Build out the dashboard UI" | `@ui-component-build status` → if no active iteration → `@ui-component-build plan - S1` → `start` → `continue` |
| "Is the UI ready to ship?" | `@ui-plan-verify audit` → check results → if gaps, route to fix → if pass, report ready |
| "Check the visuals before we commit" | `@ui-visual-verify uncommitted` → `@ui-accessibility-audit milestone` → `@ui-concept-run - UIS-06` (if agent-assisted) |
| "Write the error message for the login form" | `@ui-copy write - error for login` |
| "Review the copy on the settings screen" | `@ui-copy review - .work.ui/screens/settings/...` |
| "Check all the UI text is consistent" | `@ui-copy audit - .work.ui/screens/` |
| "Set the voice for our UI copy" | `@ui-copy tone - <description>` |
| "How do I add a new screen?" | `@ui-process-router - how do I add a new screen?` |
| "Deploy UI Design OS to my other project" | `@deploy-files copy - <path>` or `@deploy-repo clone - <path>`; thin client (cursorrules + `.work.ui/` only) → `@deploy-basic - <path>` |
| "Build a Python desktop app" | `@ui-python-desktop stack set - pyside6` (or flet/pyqt) → `@ui-python-desktop scaffold - <slug>` → `verify` |

### 3. EXECUTE

For each skill in the chain:
1. Read the skill's `skill.md` to verify correct mode invocation.
2. Invoke the skill with proper syntax (`@<skill-id> <mode> - <args>`).
3. Verify the skill's completion checklist or gate passed before proceeding to the next step.
4. If a skill reports a gap or blocker, route to the corrective skill (e.g. `probe`, `plan`, `create`) — do not skip.

### 4. RECORD

After completing the workflow (or on any meaningful state change), update `{HANDOFF_UI}` using the **same block shape** as § Free-text intake contract → 5. Structure/format the record. Also update `{UI_ITERATION_CARRIER}` § Recommended next if the workflow advanced the build cycle.

## New skill protocol

If the user request genuinely cannot be fulfilled by any registered `ui-*` skill, and falls outside the "Redirect to Agent OS" rules:

1. **Confirm gap:** Check `skills/README.md` and `APPROACH.md` §6 (skills explicitly not added). Ensure no existing skill or standard covers the need.
2. **Report:** Tell the user what skill is needed, why existing skills cannot cover it, and propose a name following the naming protocol (`ui-{domain}-{role}`).
3. **Create** the new skill folder and `skill.md` following the established pattern (YAML frontmatter with `name` and `description`, Modes table, Prerequisites, Hard rules, Completion checklist).
4. **Register** the skill in `skills/README.md` table, `SKILL_DEPENDENCIES.md` dependency matrix, and `APPROACH.md` §2 if it belongs in a skill chain.
5. **Verify** the registration by running `bash .ai.ui/scripts/framework-verify.sh` (or `.ai.ui/scripts/framework-verify.sh` depending on repo root).

**Do not create a new skill when:**
- The request maps to an existing skill or standard (`APPROACH.md` §6)
- The request is about Agent OS domains (backend, DB, sessions, master planning)
- The request can be handled by a UIS concept prompt or a standard

## Prerequisites

- `.ai.ui/` framework present with valid `skills/README.md` registry
- `{HANDOFF_UI}` readable (may be empty/bootstrap state)
- Verifier scripts at `scripts/framework-verify.sh`, `scripts/readiness-verify.sh`, `scripts/traceability-verify.sh`, `scripts/token-lint.sh`

## Completion checklist

| # | Check |
|---|-------|
| 1 | User request classified correctly |
| 2 | Prerequisites met for each skill in chain (gates respected) |
| 3 | All skills invoked with correct mode syntax |
| 4 | Blockers/gaps reported and routed (not silently skipped) |
| 5 | `{HANDOFF_UI}` updated with action summary |
| 6 | `{UI_ITERATION_CARRIER}` § Recommended next updated if applicable |
| 7 | New skill registered properly (if created) |

## See also

- [`reference.md`](reference.md) — Full skill registry with modes, gates, and orchestration tables
- [`SKILL_DEPENDENCIES.md`](../SKILL_DEPENDENCIES.md) — Gate/dependency matrix
- [`skills/README.md`](../README.md) — Skill registry table
- [`APPROACH.md`](../../APPROACH.md) — Archetypes & skill chains
- [`START_HERE.md`](../../START_HERE.md) — Operator decision tree
- [`PROCESS_ROUTER.md`](../../PROCESS_ROUTER.md) — UI process router guide
- [`probe-protocol.md`](../probe-protocol.md) — Shared probe engine
- [`COHABITATION.md`](../../COHABITATION.md) — Agent OS coexistence rules
- [`concepts/README.md`](../../concepts/README.md) — UIS prompt trigger table
- [`resources/web-research-2026.md`](../../resources/web-research-2026.md) — Curated external resources + license/browser policies (§8.1–§8.2)
