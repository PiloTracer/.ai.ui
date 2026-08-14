# UI skill dependency graph

**Purpose:** Gates for **ui-*** skills only. Agent OS gates live in `.ai/skills/SKILL_DEPENDENCIES.md`.

## Work tree path resolution (mandatory)

**Repository root** (`.git/`, `.cursorrules`) is **not** `{WORK_UI_ROOT}`. All `ui-*` skills resolve paths from **repo root** (parent of `.ai.ui/` in nested layouts).

| Placeholder | Resolved path | Common wrong path |
|-------------|---------------|-------------------|
| `{WORK_UI_ROOT}` | `.work.ui/` | `.ai.ui/.work.ui/`, `work.ui/`, paths under `templates/work.ui/` |
| `{HANDOFF_UI}` | `.work.ui/context/HANDOFF_UI.md` | `context/HANDOFF_UI.md`, `HANDOFF_UI.md` at repo root |
| `{UI_ITERATION_CARRIER}` | `.work.ui/plans/NEXT_UI.md` | `plans/NEXT_UI.md`, Agent OS `NEXT.md` |
| `{SCREEN_SPEC_ROOT}` | `.work.ui/screens/` | `.work/features/`, `.ai.ui/screens/` |
| `{UI_PLANS_ROOT}` | `.work.ui/plans/` | `plans/` without `.work.ui/` |
| `{UI_DECISIONS_ROOT}` | `.work.ui/decisions/` | `.ai.ui/decisions/` (pointer only) |
| `{UI_DESIGN_SYSTEM_ROOT}` | `.work.ui/design-system/` | catalog only in `.ai.ui/` |
| `{UI_ROADMAP}` | `.work.ui/plans/full/*-ui-roadmap.md` | `.work/plans/full/*-full-plan.md` |

**Write rule:** Every skill artifact (SPECs, foundation docs, `NEXT_UI` iteration, `CATALOG.md`, registry rows) MUST be written under the **Resolved path** column. Framework templates under `.ai.ui/templates/work.ui/` are **copy sources only** — not the live project tree.

**Read rule:** In mandatory-read tables and blocked reports, use resolved paths. Shorthand `HANDOFF_UI` / `NEXT_UI` means the paths above.

---

## Readiness states

```text
ui-bootstrap (scaffold)
        ↓
ui-foundation-complete  →  screen-spec-ready  →  ui-implementation-ready
   ui-design-foundation      ui-design-foundation certify
                             ui-component-build + verify
```

| State | Certified by | Unlocks |
|-------|--------------|---------|
| *(scaffold)* | `@ui-bootstrap init` | `@ui-design-foundation greenfield` |
| **ui-foundation-complete** | `@ui-design-foundation status` | `certify` |
| **screen-spec-ready** | `@ui-design-foundation certify screen-spec-ready` | `@ui-screen-spec create` |
| **ui-implementation-ready** | `@ui-component-build status` + verify pass on active milestone | Broad UI iteration |

---

## Dependency matrix (summary)

| Skill / mode | Depends on | Gate |
|--------------|------------|------|
| **ui-bootstrap** `init` | `.ai.ui/` present; must not overwrite `.work/` or base `.cursorrules` | - |
| **ui-deploy-basic** `- <target>` / `update` / `verify [--fix]` | Source `.ai.ui/` path or git remote; target dir must exist; `verify` backend `scripts/cursorrules-verify.sh` | - |
| **ui-deploy-files** `copy` / `update` / `verify [--fix]` | Source git repo with `.ai.ui/` as root; target parent dir must exist | - |
| **ui-deploy-repo** `clone` / `archive` / `verify [--fix]` | Source git repo; origin remote required for clone mode | - |
| **ui-session** `start` / `status` / `context` / `add` / `commit` / `close` / `push` | Target repo with `.work.ui/` (framework source repo: whole-tree mode auto-detected); git identity configured; explicit `commit`/`push` intent in the same message | **Required** (target repos: never stages paths outside `.work.ui/`) |
| **ui-design-foundation** `greenfield` | `{HANDOFF_UI}`; UI standards paths in `.cursorrules` snippet | Recommended: `@ui-bootstrap init` |
| **ui-design-foundation** `probe` | None; interrogates + fills foundation gaps. Engine: [`probe-protocol.md`](probe-protocol.md). Ledger `{UI_PLANS_ROOT}/foundation/PROBE_LEDGER.md` | Recommended before `certify` when understanding is thin |
| **ui-design-foundation** `certify screen-spec-ready` | **ui-foundation-complete: yes** | **Required** |
| **ui-component-build** `probe` | None; interactive roadmap-completeness check before `ui-implementation-ready`. Ledger `{UI_PLANS_ROOT}/full/PROBE_LEDGER.md` | Recommended before broad iteration |
| **ui-screen-spec** `intake` | None (free-text front door); classifies + routes, only writes a SPEC when class=`local` | - (records to `NEXT_UI` § Intake queue) |
| **ui-screen-spec** `create` | SCREEN_SPEC_STANDARD; **screen-spec-ready** | **Required** (warn if no) |
| **ui-component-build** `plan` | Approved screen SPEC(s) for milestone | **Required** |
| **ui-component-build** `start` / `continue` | Valid `NEXT_UI.md` UI iteration; screen-spec-ready or waiver in HANDOFF_UI | **Required** |
| **ui-component-build** `complete` | `@ui-visual-verify milestone` + `@ui-accessibility-audit milestone` + `@ui-plan-verify audit` pass | **Required** |
| **ui-component-build** `complete` (craft tier ≥ refined) | `@ui-concept-run - UIS-07` on milestone diff | **Required** |
| **ui-component-build** `complete` (any screen) | `@ui-concept-run - UIS-08` on milestone diff | **Required** |
| **ui-component-build** `complete` (analytical dashboard) | `@ui-concept-run - UIS-09` on milestone diff | **Required** |
| **ui-visual-verify** / **ui-accessibility-audit** | Active UI milestone in NEXT_UI | Per skill |
| **ui-concept-run** `run` | UIS trigger table | Per `.ai.ui/concepts/README.md` |
| **ui-plan-verify** | - | Read-only (runs verifiers; reports + routes, never fixes) |
| **ui-process-router** | - | Read-only |
| **ui-project-approach** | - | Read-only (optional write to HANDOFF_UI on user request) |
| **ui-copy** `write` / `plan` / `review` / `audit` / `tone` | None — can run at any stage | — |
| **ui-python-desktop** `stack set` | None — records `UI_DESKTOP_STACK` | — |
| **ui-python-desktop** `scaffold` | Tokens doc (Phase 2 DTCG) + approved screen SPEC | **Required** |
| **ui-python-desktop** `component add` | CATALOG binding when `UI_DESKTOP_STACK` set | Recommended |
| **ui-style-stack** `set` | Recommended: before `ui-design-foundation greenfield` | Warn if missing |
| **ui-component-build** `start` | Active style stack in HANDOFF_UI or user-named in message | Recommended |
| **ui-director** `- <request>` | Reads `{HANDOFF_UI}` + `{UI_ITERATION_CARRIER}` for context | Recommends: execute prerequisite first |

---

## Redirect cheat sheet

| User tried | Run next |
|------------|----------|
| `@ui-director - <request>` | Orchestrates across all skills (route by [`ui-director/reference.md`](ui-director/reference.md)) |
| `@ui-deploy-basic - /path` | `bash scripts/ui-deploy-basic.sh /path` |
| `@ui-deploy-files copy - /path` | `bash scripts/ui-deploy-files.sh /path` |
| `@ui-deploy-repo clone - /path` | `bash scripts/ui-deploy-repo.sh clone /path` |
| `@ui-deploy-repo archive - /path` | `bash scripts/ui-deploy-repo.sh archive /path` |
| `@ui-python-desktop scaffold - <slug>` | Generates Python desktop skeleton (FLET/PySide6/PyQt6) from tokens + SPEC |
| `@ui-screen-spec create` | `@ui-design-foundation certify screen-spec-ready` |
| `@ui-component-build start` | `@ui-component-build plan - S{N}` |
| Free-text UI request, unsure where it goes | `@ui-screen-spec intake - <sentence>` |
| UI copy / microcopy request | `@ui-copy write - <description>` or `@ui-director - <request>` |
| Brand/users/scope vague; "do you understand the UI?" | `@ui-design-foundation probe` (then `certify`) |
| Roadmap completeness unclear before broad build | `@ui-component-build probe` |
| Audit readiness (verifiers + coverage + orphans) | `@ui-plan-verify audit` |
| External UX/a11y/token/copy references | read `resources/web-research-2026.md` (route via `@ui-process-router`) |
| UI session close / commit (full repo) | `@session-control close` (Agent OS) |
| `.work.ui`-scoped session verbs | `@ui-session start` / `status` / `context` / `add` / `commit` / `close` / `push` (any combination) |
| Backend migration | `@db-migration` (Agent OS) — not a ui-* skill |

---

## Command vocabulary (canonical verbs)

One verb set across `ui-*` skills. New verbs go here first, then into the matrix.

| Verb | Skills | Writes? | Meaning |
|------|--------|---------|---------|
| `init` | ui-bootstrap | yes | Scaffold `.work.ui/` + cursorrules |
| `copy` | ui-deploy-files | yes | Deploy `.ai.ui` files into target project |
| `clone` / `archive` | ui-deploy-repo | yes | Full git-based deploy of `.ai.ui` repo |
| `commit` / `close` / `push` / `add` / `start` | ui-session | yes (`.work.ui` only; whole tree in framework repo) | Session carrier; any combination; `commit` includes untracked files/dirs; `scoped` = bookends only; `status`/`context` read-only |
| `set` | ui-style-stack | yes (HANDOFF_UI) | Record active style stack |
| `greenfield` | ui-design-foundation | yes | Create foundation docs 01–04 |
| `probe` | ui-design-foundation, ui-component-build | yes (docs + ledger) | Interrogate until coverage target; sub-modes `- status`, `- until ready` |
| `intake` | ui-screen-spec | records only | Classify + route a free-text request |
| `create` | ui-screen-spec | yes (SPEC) | New screen SPEC (slug or derived) |
| `review` / `amend` | ui-screen-spec | yes | Check / amend a SPEC |
| `plan` | ui-component-build | yes (NEXT_UI) | Write a milestone iteration |
| `start` / `continue` | ui-component-build | yes (code) | Execute iteration tasks |
| `complete` | ui-component-build | yes | Close milestone after verify gates |
| `init` | ui-design-system | yes (CATALOG) | Primitives catalog from doc 03 |
| `run` | ui-concept-run | varies | Run a UIS prompt |
| `write` | ui-copy | yes | Author copy for a UI element or screen |
| `review` | ui-screen-spec, ui-copy | yes | Check / amend a SPEC; evaluate screen copy |
| `audit` / `probe-coverage` / `traceability` | ui-plan-verify, ui-copy | read | Report + route readiness gaps; audit UI copy quality |
| `tone` | ui-copy | yes | Define or reload brand voice for UI copy |
| `stack` | ui-python-desktop | yes (HANDOFF_UI) | Set desktop stack (flet/pyside6/pyqt) |
| `scaffold` | ui-python-desktop | yes (code) | Generate Python desktop app skeleton |
| `component` | ui-python-desktop | yes (code) | Add FLET control / Qt widget primitive |
| `milestone` | ui-visual-verify, ui-accessibility-audit | read | Verify before ship |
| `uncommitted` | ui-visual-verify | read | Visual/token regression on uncommitted tree |
| `status` | most skills | read | Read-only state |
| *(question)* | ui-process-router, ui-project-approach | read | Classify / orient |

---

## Blocked report shape

```markdown
## @<ui-skill> <command> - blocked (prerequisite)
**Required:** …
**Detected:** …
**Run first:** `@…`
```

---

## Operator handoff contract

Every `ui-*` skill response closes so the operator never has to ask "what do you need from me?" (Source protocol: `.work.ui/prompts/improve-clarity-of-responses.md`.)

- **Terse output:** report only what changed and what is needed next. No restating the task, no filler transitions, no unrequested rationale.
- **Approvals** go under `**Needs your approval:**` — numbered, one decision per item, each citing `path/to/file.md:L<n>`. Never make the operator hunt for what changed.
- **Questions** go under `**Needs your answer:**` — numbered, self-contained, in their own list. Decisions and questions are never mixed.
- **Next step:** exactly one `**Next step:**` command, in the exact syntax to run/type. One per response — present only the immediate action.
- **Form A (nothing needed):** a single line, e.g. `Next: nothing - work complete`. Never render an empty Approval / Answer / Next-step section — omit it.
- **Report sections do not replace the close:** "Follow-ups" / "Remaining" / "Recommended next" inside a report template are content; anything operator-required must also appear in the labeled closing sections above.

Every `skills/<id>/skill.md` must reference this contract, and every operator-facing report template in a skill must close with Form A or Form B. Enforced by `scripts/framework-verify.sh`.

---

## Document clarity contract

Every document a `ui-*` skill generates (foundation docs, SPECs, plans, CATALOG, copy plans/audits, reports) must make it obvious what it is, what state it is in, and what the reader must do next. (Source protocol: `.work.ui/prompts/improve-clarity-of-documentation.md`.)

- **Header (≤4 lines):** what this is (one sentence); **Status** — `Draft` | `In review` | `Approved` | `Superseded` (+ date); **Needs** — the decision, review, or nothing.
- **Brevity:** summary first; every section informs a decision or an action; no boilerplate.
- **Exact references:** claims cite `path/to/file.md:L<n>`; quantitative claims tagged `measured` | `estimated` | `assumption` | `unknown`.
- **Decisions needed** and **Open questions** are separate numbered lists — never mixed, never buried in prose; each decision cites what is being decided.
- **Next action:** exactly one `## Next action` section with one action in exact syntax — or one line `Next action: none — <reason>`.
- **No leftover scaffolding:** `REPLACE:*` / instructional comments must be stripped or filled before a document is presented as complete.

Doc-generating skills (must reference this contract from `skill.md`): `ui-design-foundation`, `ui-screen-spec`, `ui-component-build`, `ui-copy`, `ui-design-system`, `ui-visual-verify`, `ui-accessibility-audit`. Enforced by `scripts/framework-verify.sh`; doc templates under `templates/work.ui/` carry the Status/Needs header and `## Next action`.
