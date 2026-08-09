# ui-director — orchestration reference

Full skill registry, dependency map, and routing tables for the `@ui-director` orchestrator.

---

## 1. Complete skill registry (all `ui-*` skills)

All 18 registered skills except `ui-director` itself (15 `ui-*` + 3 `ui-deploy-*` utilities listed below). Source of truth: `skills/README.md` (**19 total** including `ui-director`).

| `@` handle | Folder | Role | Modes | Writes? | Depends on |
|------------|--------|------|-------|---------|------------|
| `ui-bootstrap` | `ui-bootstrap/` | Scaffold `.work.ui/`, install/merge cursorrules | `init`, `init merge-cursorrules`, `init create-cursorrules`, `status`, `cursorrules status`, `cursorrules merge-block`, `cursorrules create-full` | Yes (`.work.ui/`, `.cursorrules`) | `.ai.ui/` present |
| `ui-project-approach` | `ui-project-approach/` | Classify archetype + complexity + skill chain | `- <description>`, `status`, `help` | Read-only (optional HANDOFF write) | — |
| `ui-style-stack` | `ui-style-stack/` | Set/report active styling approach | `set - <stack>`, `status` | Yes (`HANDOFF_UI`) | — |
| `ui-design-foundation` | `ui-design-foundation/` | Establish tokens, patterns, screen map, a11y baseline; certifies screen-spec-ready | `greenfield`, `probe`, `probe - status`, `probe - until ready`, `status`, `certify screen-spec-ready` | Yes (foundation docs 01–04, PROBE_LEDGER) | Recommended: `@ui-bootstrap init`, `@ui-project-approach`, `@ui-style-stack set` |
| `ui-screen-spec` | `ui-screen-spec/` | Author/review screen SPECs | `intake - <sentence>`, `create - <slug>`, `review - <path>`, `amend - <slug>`, `status` | Yes (SPECs) | `screen-spec-ready` certified |
| `ui-component-build` | `ui-component-build/` | Execute UI iteration from NEXT_UI.md | `status`, `probe`, `probe - status`, `probe - until ready`, `plan - S{N}`, `start`, `continue`, `complete` | Yes (code, NEXT_UI, HANDOFF) | Approved SPECs, valid iteration block, style stack |
| `ui-copy` | `ui-copy/` | Plan, write, review, or audit UI copy | `write - <element>`, `plan - <screen>`, `review - <path>`, `audit - <path>`, `tone - <description>`, `status` | Yes (copy deliverables) | — (gate-independent) |
| `ui-python-desktop` | `ui-python-desktop/` | Design/scaffold/verify Python desktop UIs (FLET/PySide6/PyQt6) | `stack set - flet\|pyside6\|pyqt`, `scaffold - <slug>`, `component add - <name>`, `verify - <path>`, `status` | Yes (code, HANDOFF_UI) | screen-spec-ready + tokens (Phase 2) |
| `ui-design-system` | `ui-design-system/` | Primitives catalog and Storybook discipline | `init`, `add - <component>`, `status` | Yes (`CATALOG.md`, files) | Tokens doc (foundation doc 02) |
| `ui-visual-verify` | `ui-visual-verify/` | Visual/token regression audits | `milestone`, `uncommitted`, `status` | Read-only (report) | Active UI milestone |
| `ui-accessibility-audit` | `ui-accessibility-audit/` | WCAG-oriented checks | `screen - <slug>`, `milestone`, `status` | Read-only (report) | Active UI milestone |
| `ui-concept-run` | `ui-concept-run/` | Run UIS-01…10 prompts | `list`, `run - UIS-NN`, `status` | Varies (attachments) | Trigger table in `concepts/README.md` |
| `ui-plan-verify` | `ui-plan-verify/` | Read-only audit: verifiers, probe coverage, traceability | `audit`, `probe-coverage`, `traceability` | Read-only (report) | — |
| `ui-process-router` | `ui-process-router/` | Read-only UI process Q&A | `- <question>`, `help` | Read-only | — |
| `ui-deploy-files` | `ui-deploy-files/` | Deploy `.ai.ui` files to target project | `copy - <path>`, `update`, `status`, `verify [--fix]` | Yes (target `.ai.ui/`) | Source git repo |
| `ui-deploy-basic` | `ui-deploy-basic/` | Thin-client bootstrap (cursorrules + .work.ui/ only; skills load from source) | `- <target-path>`, `update`, `status`, `verify [--fix]` | Yes (target `.cursorrules`, `.work.ui/`) | Source `.ai.ui/` path or git remote |
| `ui-deploy-repo` | `ui-deploy-repo/` | Full git-based deploy (clone/archive) | `clone - <path>`, `archive - <path>`, `status`, `verify [--fix]` | Yes (target repo) | Source git remote (for clone) |
| `ui-session` | `ui-session/` | `.work.ui`-scoped session carrier | `commit`, `close`, `push` (any combination), `status` | Yes (`.work.ui/` only) | Target repo with `.work.ui/`; explicit commit/push intent |

---

## 2. Gate / dependency matrix

Single source: [`SKILL_DEPENDENCIES.md`](../SKILL_DEPENDENCIES.md) — readiness states, dependency matrix, and blocked-until rules. The director checks the gate before invoking any skill; if a prerequisite is unmet, report it and run the prerequisite first (see § ROUTE).

---

## 3. Skill chain templates by archetype

Single source: `APPROACH.md` §2 (archetypes → chains). Director note: always start from `@ui-bootstrap init` unless the scaffold is already present.

---

## 4. UIS concept trigger table

Single source: `concepts/README.md` trigger table. Required at the gates listed there: UIS-06 (agent-assisted), UIS-07 (craft ≥ refined), UIS-08 (any screen), UIS-09 (analytical dashboards), UIS-10 (marketing/hybrid), UIS-04 (token/theme changes).

---

## 5. Verify gate checklist (pre-complete)

Before `@ui-component-build complete`, ensure these all pass:

| Check | Command | Required for |
|--------|---------|-------------|
| Visual/token regression | `@ui-visual-verify milestone` | All builds |
| Accessibility audit | `@ui-accessibility-audit milestone` | All builds |
| Plan audit (verifiers + coverage + traceability) | `@ui-plan-verify audit` | All builds |
| AI visual quality (if agent-assisted) | `@ui-concept-run - UIS-06` | Agent-assisted diffs |
| Surface & control craft (if tier ≥ refined) | `@ui-concept-run - UIS-07` | Craft ≥ refined |
| Intuitive UX | `@ui-concept-run - UIS-08` | All screens |
| Data viz quality (if analytical dashboard) | `@ui-concept-run - UIS-09` | Analytical dashboards |
| Creative direction (if marketing/landing) | `@ui-concept-run - UIS-10` | Marketing-site, hybrid |
| Token contract (no raw hex) | `bash scripts/token-lint.sh` | All builds |

---

## 6. Common user request routing table

| User says (paraphrased) | Classified bucket | Execute |
|------------------------|-------------------|---------|
| "Start a new UI project" | `bootstrap` | `@ui-bootstrap init` → `@ui-project-approach - ...` |
| "Set up the UI for my app" | `bootstrap` | `@ui-bootstrap init` (then approach/foundation) |
| "What kind of project is this?" | `approach` | `@ui-project-approach - <description>` |
| "I use Tailwind" / "set up CSS modules" | `style` | `@ui-style-stack set - <stack>` |
| "Create the design tokens" | `foundation` | `@ui-design-foundation greenfield` |
| "I'm not sure about the design direction" | `foundation-probe` | `@ui-design-foundation probe` |
| "I need a login page" | `screen-request` | Check screen-spec-ready → `@ui-screen-spec create - login` or `intake` |
| "Add a dashboard page" | `screen-request` | `@ui-screen-spec create - dashboard` |
| "Review the spec for checkout" | `screen-spec` | `@ui-screen-spec review - .work.ui/screens/checkout/...` |
| "Init the catalog" / "storybook" | `design-system` | `@ui-design-system init` (needs foundation doc 02 tokens) |
| "Add a component to the design system" | `design-system` | `@ui-design-system add - <component>` |
| "Are we ready to start building?" | `build-probe` | `@ui-component-build probe` |
| "Build the login screen" | `build` | `@ui-component-build status` → if no iteration → `plan - S{N}` → `start` |
| "Continue building" | `build` | `@ui-component-build continue` |
| "Run the visual checks" | `verify-visual` | `@ui-visual-verify milestone` |
| "Check accessibility" | `verify-a11y` | `@ui-accessibility-audit milestone` |
| "Write copy for the login form" | `copy` | `@ui-copy write - login form` |
| "Review the copy on settings" | `copy` | `@ui-copy review - .work.ui/screens/settings/...` |
| "Audit all UI text" | `copy` | `@ui-copy audit - .work.ui/screens/` |
| "Set the UI voice" | `copy` | `@ui-copy tone - <description>` |
| "Plan copy needs for the dashboard" | `copy` | `@ui-copy plan - dashboard` |
| "Run UIS-06" | `concept` | `@ui-concept-run - UIS-06` |
| "Check if we're ready to close the milestone" | `audit` | `@ui-plan-verify audit` |
| "How do I create a screen spec?" | `router` | `@ui-process-router - how do I create a screen spec?` |
| "Deploy to /path/to/project" | `deploy` | `@ui-deploy-files copy - /path/to/project` |
| "Thin-client deploy (just cursorrules + .work.ui/)" | `deploy` | `@ui-deploy-basic - /path/to/project` |
| "Build a desktop app" | `desktop` | `@ui-python-desktop stack set - pyside6` → `scaffold - <slug>` |
| "Start a session" | `session-control` | Redirect: `@session-control start` (Agent OS) |
| "Commit my .work.ui changes" | `session` | `@ui-session commit` (scoped to `.work.ui/`; includes untracked) |
| "Close the UI session / push .work.ui" | `session` | `@ui-session close` / `@ui-session push` (any combination) |
| "Commit the whole repo" | `session-control` | Redirect: `@session-control close` (Agent OS) |
| "Create a migration" | `backend` | Redirect: `@db-migration` (Agent OS) |

---

## 7. State files (paths)

Single source: `SKILL_DEPENDENCIES.md` § Work tree path resolution (mandatory). `{WORK_UI_ROOT}` always resolves to `<repo-root>/.work.ui/` — never under `.ai.ui/`.

---

## 8. Verifier scripts

| Script | Purpose | Called by |
|--------|---------|-----------|
| `scripts/framework-verify.sh` | Self-test: skill count, registration, link scan | `@ui-plan-verify audit`, release |
| `scripts/readiness-verify.sh` | PROBE_LEDGER honesty check (evidence, coverage math, gate-blocking unknowns) | `@ui-plan-verify audit` |
| `scripts/traceability-verify.sh` | Screen→SPEC→milestone chain check (orphans, unbacked claims) | `@ui-plan-verify audit` |
| `scripts/token-lint.sh` | Machine-enforce no raw hex/color in component source | `@ui-visual-verify milestone` |
| `scripts/cursorrules-ui.sh` | Install/merge UI rules into .cursorrules | `@ui-bootstrap` |
| `scripts/release.sh` | Release preflight (runs all verifiers, checks CHANGELOG, tags) | Manual |

---

## 9. Notable non-skills (shared engines & patterns)

| Resource | Location | Purpose |
|----------|----------|---------|
| Probe protocol | `skills/probe-protocol.md` | Shared adaptive interrogation loop for `ui-design-foundation probe` and `ui-component-build probe` |
| Standards | `standards/*.md` (11 files) | Binding templates for screen SPECs, craft, tokens, components, a11y, conventions, directory map, patterns, responsive, motion, copy |
| Concepts | `concepts/*/` (UIS-01…10) | Design/UX quality prompts |
| Style stacks | `style-stacks/*.md` (4 files) | Implementation rules per CSS approach |
| Examples | `examples/*/` with `manifest.md` | Reference implementations with extractedRules |
| Approach | `APPROACH.md` | Archetype definitions, skill chains, complexity levels |
| Decision tree | `START_HERE.md` | Operator entry point |
| Cohabitation | `COHABITATION.md` | Rules when coexisting with Agent OS |
| Control platforms | `resources/control-platforms.md` | OSS behavior libraries (MIT/Apache) |
| Web research | `resources/web-research-2026.md` | Curated external URLs + agent apply rules; license + browser policies |
| Resource index | `resources/README.md` | Gallery URLs + pointers to research + control platforms |

---

## 10. External research → skill map

Canonical source: [`resources/web-research-2026.md`](../../resources/web-research-2026.md) §9. Director routes verify/foundation/copy work through the mapped skill; each skill's `skill.md` links its §.

| Research § | Primary `@` skills | Static default | Browser opt-in |
|------------|-------------------|----------------|----------------|
| §1 Tokens/color | `ui-design-foundation`, UIS-04 | DTCG JSON, OKLCH, color.js, token-lint | — |
| §2 Accessibility | `ui-accessibility-audit` | jest-axe, WCAG/APG rubric, manual checklist | `@axe-core/playwright`, Lighthouse, Playwright MCP |
| §3 Visual QA | `ui-visual-verify`, `ui-concept-run` (UIS-01/08/09) | NN/g, Laws of UX, GoodUI, FT Vocabulary rubrics | Playwright snapshots, Chromatic (CI) |
| §4 Design systems | `ui-design-system` | Storybook MCP query, Open UI, Style Dictionary | Framelink Figma MCP |
| §5 UX writing | `ui-copy` | Polaris/Google/Microsoft tone rubrics | — |
| §6 Agent verify | `ui-visual-verify`, `ui-plan-verify` | Static checklists, Design2Code metrics | Playwright MCP, DevTools MCP (authorized) |
| Behavior OSS | `ui-design-system`, `ui-component-build` | `control-platforms.md` | — |

**Policies (all skills):** commercial-safe license (doc header) · verify URLs before citing (§8.1) · browser control requires explicit operator authorization (§8.2).
