# ui-director — orchestration reference

Full skill registry, dependency map, and routing tables for the `@ui-director` orchestrator.

---

## 1. Complete skill registry (all `ui-*` skills)

All 13 other registered ui-* skills + 2 deploy utilities (the 14th ui-* skill is `ui-director` itself, not listed here). Source of truth: `skills/README.md` (16 total).

| `@` handle | Folder | Role | Modes | Writes? | Depends on |
|------------|--------|------|-------|---------|------------|
| `ui-bootstrap` | `ui-bootstrap/` | Scaffold `.work.ui/`, install/merge cursorrules | `init`, `init merge-cursorrules`, `init create-cursorrules`, `status`, `cursorrules status`, `cursorrules merge-block`, `cursorrules create-full` | Yes (`.work.ui/`, `.cursorrules`) | `.ai.ui/` present |
| `ui-project-approach` | `ui-project-approach/` | Classify archetype + complexity + skill chain | `- <description>`, `status`, `help` | Read-only (optional HANDOFF write) | — |
| `ui-style-stack` | `ui-style-stack/` | Set/report active styling approach | `set - <stack>`, `status` | Yes (`HANDOFF_UI`) | — |
| `ui-design-foundation` | `ui-design-foundation/` | Establish tokens, patterns, screen map, a11y baseline; certifies screen-spec-ready | `greenfield`, `probe`, `probe - status`, `probe - until ready`, `status`, `certify screen-spec-ready` | Yes (foundation docs 01–04, PROBE_LEDGER) | Recommended: `@ui-bootstrap init`, `@ui-project-approach`, `@ui-style-stack set` |
| `ui-screen-spec` | `ui-screen-spec/` | Author/review screen SPECs | `intake - <sentence>`, `create - <slug>`, `review - <path>`, `amend - <slug>`, `status` | Yes (SPECs) | `screen-spec-ready` certified |
| `ui-component-build` | `ui-component-build/` | Execute UI iteration from NEXT_UI.md | `status`, `probe`, `probe - status`, `probe - until ready`, `plan - S{N}`, `start`, `continue`, `complete` | Yes (code, NEXT_UI, HANDOFF) | Approved SPECs, valid iteration block, style stack |
| `ui-copy` | `ui-copy/` | Plan, write, review, or audit UI copy | `write - <element>`, `plan - <screen>`, `review - <path>`, `audit - <path>`, `tone - <description>`, `status` | Yes (copy deliverables) | — (gate-independent) |
| `ui-design-system` | `ui-design-system/` | Primitives catalog and Storybook discipline | `init`, `add - <component>`, `status` | Yes (`CATALOG.md`, files) | Tokens doc (foundation doc 02) |
| `ui-visual-verify` | `ui-visual-verify/` | Visual/token regression audits | `milestone`, `uncommitted`, `status` | Read-only (report) | Active UI milestone |
| `ui-accessibility-audit` | `ui-accessibility-audit/` | WCAG-oriented checks | `screen - <slug>`, `milestone`, `status` | Read-only (report) | Active UI milestone |
| `ui-concept-run` | `ui-concept-run/` | Run UIS-01…09 prompts | `list`, `run - UIS-0N`, `status` | Varies (attachments) | Trigger table in `concepts/README.md` |
| `ui-plan-verify` | `ui-plan-verify/` | Read-only audit: verifiers, probe coverage, traceability | `audit`, `probe-coverage`, `traceability` | Read-only (report) | — |
| `ui-process-router` | `ui-process-router/` | Read-only UI process Q&A | `- <question>`, `help` | Read-only | — |
| `deploy-files` | `deploy-files/` | Deploy `.ai.ui` files to target project | `copy - <path>`, `status` | Yes (target `.ai.ui/`) | Source git repo |
| `deploy-repo` | `deploy-repo/` | Full git-based deploy (clone/archive) | `clone - <path>`, `archive - <path>`, `status` | Yes (target repo) | Source git remote (for clone) |

---

## 2. Gate / dependency matrix

| Gate state | Meaning | Certified by |
|------------|---------|--------------|
| *(scaffold)* | `.work.ui/` skeleton exists | `@ui-bootstrap init` |
| **ui-foundation-complete** | All 4 foundation docs present | `@ui-design-foundation status` |
| **screen-spec-ready** | Tokens + screen map ready for SPEC authoring | `@ui-design-foundation certify screen-spec-ready` |
| **ui-implementation-ready** | Active milestone with passing verify | `@ui-component-build status` + verify pass |

**Gate blocking rules:**

| Attempted skill/mode | Blocked unless | Route instead |
|----------------------|----------------|---------------|
| `@ui-design-foundation greenfield` | `.work.ui/` exists (or bootstrap complete) | `@ui-bootstrap init` |
| `@ui-screen-spec create` | **screen-spec-ready** | `@ui-design-foundation certify screen-spec-ready` |
| `@ui-component-build plan` | Approved screen SPEC(s) for milestone | `@ui-screen-spec review - <path>` → approve |
| `@ui-component-build start` | Valid `NEXT_UI.md` + screen-spec-ready or waiver | `@ui-component-build plan - S{N}` |
| `@ui-component-build complete` | `@ui-visual-verify milestone` + `@ui-accessibility-audit milestone` + `@ui-plan-verify audit` pass | Run each verify first |
| `@ui-component-build complete` (craft ≥ refined) | `@ui-concept-run - UIS-07` done | Run UIS-07 |
| `@ui-component-build complete` (any screen) | `@ui-concept-run - UIS-08` done | Run UIS-08 |
| `@ui-component-build complete` (analytical dashboard) | `@ui-concept-run - UIS-09` done | Run UIS-09 |
| `@ui-design-system init` | Tokens doc (foundation doc 02) exists | `@ui-design-foundation greenfield` |

---

## 3. Skill chain templates by archetype

From `APPROACH.md` §2. Use these when the user describes a project:

| Archetype | Chain (after `@ui-bootstrap init`) |
|-----------|----------------------------------|
| **marketing-site** | `@ui-style-stack set` → `@ui-design-foundation greenfield` → `@ui-screen-spec create` per route → `@ui-copy write` per screen → `@ui-component-build` → verify |
| **saas-product** | `@ui-style-stack set` → `@ui-design-foundation` → `@ui-screen-spec` (shell + key flows) → `@ui-copy write` per screen → `@ui-design-system init` → `@ui-component-build` → verify + a11y |
| **admin-dashboard (operational)** | Same as saas; **require** UIS-01 + UI-PATTERNS § data-density in SPECs |
| **admin-dashboard (analytical)** | Same as saas; **require** chart library in doc 03, UIS-09 at milestone verify, chart tokens in foundation 02 |
| **mobile-app** | `@ui-style-stack set` → foundation → specs per screen → build; **UIS-02 required** every screen |
| **design-system** | foundation → `@ui-design-system init` → primitives before screens |
| **hybrid** | foundation once → separate SPEC groups per shell |

---

## 4. UIS concept trigger table

From `concepts/README.md`. Run these as required during the build cycle:

| Trigger | Run | Required? |
|---------|-----|-----------|
| Agent-assisted UI session | `@ui-concept-run - UIS-06` | **Required** (unless human-only) |
| Build complete, craft tier ≥ refined | `@ui-concept-run - UIS-07` | **Required** |
| Any screen before ship | `@ui-concept-run - UIS-08` | **Required** |
| Analytical dashboard screens | `@ui-concept-run - UIS-09` | **Required** |
| New theme or semantic color token | `@ui-concept-run - UIS-04` | **Required** |
| New screen, marketing block, dense dashboard | `@ui-concept-run - UIS-01` | Default lightest prompt |
| Breakpoints, grid, mobile | `@ui-concept-run - UIS-02` | Recommended per SPEC |
| Animation beyond micro-feedback | `@ui-concept-run - UIS-03` | Recommended |
| Multi-step flow or modal | `@ui-concept-run - UIS-05` | Recommended |

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
| "Deploy to /path/to/project" | `deploy` | `@deploy-files copy - /path/to/project` |
| "Start a session" | `session-control` | Redirect: `@session-control start` (Agent OS) |
| "Commit my changes" | `session-control` | Redirect: `@session-control close` (Agent OS) |
| "Create a migration" | `backend` | Redirect: `@db-migration` (Agent OS) |

---

## 7. State files (paths)

| Placeholder | Resolved path | Purpose |
|-------------|---------------|---------|
| `{WORK_UI_ROOT}` | `.work.ui/` | Project memory root |
| `{HANDOFF_UI}` | `.work.ui/context/HANDOFF_UI.md` | UI session state |
| `{UI_ITERATION_CARRIER}` | `.work.ui/plans/NEXT_UI.md` | Active iteration + intake queue |
| `{SCREEN_SPEC_ROOT}` | `.work.ui/screens/` | Screen SPECs |
| `{UI_PLANS_ROOT}` | `.work.ui/plans/` | Foundation docs, ledgers, roadmap |
| `{UI_DECISIONS_ROOT}` | `.work.ui/decisions/` | Architecture Decision Records |
| `{UI_DESIGN_SYSTEM_ROOT}` | `.work.ui/design-system/` | CATALOG.md, stories |
| `{UI_ROADMAP}` | `.work.ui/plans/full/*-ui-roadmap.md` | Full roadmap |

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
| Standards | `standards/*.md` (8 files) | Binding templates for screen SPECs, craft, tokens, components, a11y, conventions, directory map, patterns |
| Concepts | `concepts/*/` (UIS-01..09) | Design/UX quality prompts |
| Style stacks | `style-stacks/*.md` (4 files) | Implementation rules per CSS approach |
| Examples | `examples/*/` with `manifest.md` | Reference implementations with extractedRules |
| Approach | `APPROACH.md` | Archetype definitions, skill chains, complexity levels |
| Decision tree | `START_HERE.md` | Operator entry point |
| Cohabitation | `COHABITATION.md` | Rules when coexisting with Agent OS |
