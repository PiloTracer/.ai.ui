# ui-session - reference

Supplement to `skill.md`. Invocation examples, HANDOFF_UI templates, detailed protocols, and edge cases. **Scope is dual:** in adopter target repos everything is scoped to **`<repo-root>/.work.ui/`**; in the UI Design OS framework source repo (auto-detected), `add` / `commit` / `push` cover the **whole repo tree**. This is the UI-scoped mirror of Agent OS `session-control/reference.md`.

---

## Invocation examples

**Canonical forms:**

| Action | Prompt |
|--------|--------|
| Open UI session | `@ui-session` **start** |
| Open + goal | `@ui-session` **start** - S2 dashboard shell |
| Compact snapshot | `@ui-session` **status** |
| Full context load (no writes, uncommitted-aware) | `@ui-session` **context** |
| Stage checkpoint (no commit) | `@ui-session` **add** |
| Stage bookend files only (no commit) | `@ui-session` **add** **scoped** |
| Close UI session | `@ui-session` **close** |
| Close + commit (all safe `.work.ui/` changes incl. new files) | `@ui-session` **close** **commit** |
| Close + commit (HANDOFF_UI/NEXT_UI only) | `@ui-session` **close** **commit** **scoped** |
| Close + commit + push | `@ui-session` **close** **commit** **push** |
| **Commit only (no close)** | `@ui-session` **commit** |
| **Commit with message** | `@ui-session` **commit** -m "UIS-123: dashboard shell" |
| **Commit + push (no close)** | `@ui-session` **commit** **push** |

Aliases: `begin`/`open` → start · `end`/`handoff` → close · `stage` → add.

### Cursor / Claude Code / opencode / Codex

```
@ui-session start - S2 dashboard shell
@ui-session close
@ui-session close commit
@ui-session close commit push
@ui-session commit
@ui-session commit push
@ui-session add
@ui-session context
@ui-session status
```

```
Follow .ai.ui/skills/ui-session/skill.md - close commit push.
```

### Verb × action matrix

| Invocation | HANDOFF_UI open | HANDOFF_UI closed | NEXT_UI update | `git add` | `git commit` | `git push` | Commit message in report | Checklist |
|------------|-----------------|-------------------|----------------|-----------|--------------|------------|--------------------------|-----------|
| `start` | yes | - | no | no | no | no | no | yes |
| `status` | no | no | no | no | no | no | no | no |
| `context` | no | no | no | no | no | no | no | no |
| `add` | no | no | no | **yes** | no | no | no | yes |
| `close` | - | yes | yes | no | no | no | **always** (draft) | yes |
| `close commit` | - | yes | yes | yes | yes | no | **always** (used + SHA) | yes |
| `close commit push` | - | yes | yes | yes | yes | yes | **always** (used + push) | yes |
| `commit` | no | no | no | yes | **yes** | no | **always** (used + SHA) | yes |
| `commit push` | no | no | no | yes | **yes** | **yes** | **always** (used + push) | yes |
| `push` | no | no | no | no | no | **yes** | no | yes |

Default `close` never runs `git commit` or `git push`. The operator runs git manually from the drafted message if they want.

---

## HANDOFF_UI - Session status templates

### Open (after start)

```markdown
## Session status

**Open:** 2026-08-14 - goal: S2 dashboard shell

**Updated:** 2026-08-14

**Closed:** -
```

### Closed (after close)

```markdown
## Session status

**Open:** closed

**Updated:** 2026-08-14

**Closed:** 2026-08-14 (S2 dashboard shell landed; visual verify pending)
```

The shell writes the `Open` / `Updated` / `Closed` lines mechanically; the agent refreshes the surrounding sections per C5.

---

## Git commands reference

All git writes go through the shell (or its exact steps):

| Purpose | Command |
|---------|---------|
| Status snapshot | `bash .ai.ui/scripts/ui-session.sh status` |
| Context snapshot (read-only) | `bash .ai.ui/scripts/ui-session.sh context` |
| Mark session open | `bash .ai.ui/scripts/ui-session.sh start - <goal>` |
| Mark session closed | `bash .ai.ui/scripts/ui-session.sh close` |
| Stage only | `bash .ai.ui/scripts/ui-session.sh add` |
| Commit | `bash .ai.ui/scripts/ui-session.sh commit [-m "msg"]` |
| Push (scope-checked) | `bash .ai.ui/scripts/ui-session.sh push` |
| Combinations | `bash .ai.ui/scripts/ui-session.sh close commit push` |

| When | Allowed |
|------|---------|
| `close` | audit only |
| `close commit` | stage safe paths under `.work.ui/` (incl. new untracked files/dirs) → commit → verify |
| `close commit scoped` | stage HANDOFF_UI + NEXT_UI only → commit |
| `close commit push` | above + push |
| `commit` / `commit push` | same git steps, **no** HANDOFF_UI/NEXT_UI update |
| `add` | stage only; no commit |

Never on default `close`: commit or push. **Standalone `commit` / `commit push`** always runs git. **`add`** never commits.

---

## Commit message rules (summary)

Per repo `.cursorrules` §Git:

- Subject ≤72 chars, imperative.
- **Ref known:** `UIS-123: description` (or the adopter's task ref, e.g. `PROJ-456:`).
- **No ref:** `type: description` with `feat` / `fix` / `refactor` / `docs` / `chore`.
- Body: why, not file list; omit if subject suffices.
- No attribution lines, no `Co-authored-by:` trailers (hooks enforce).
- Ref-prefixed subjects feed the `post-commit` hook (`.work.ui/commit-ref-pending/`).

**Ref auto-detect priority (shell default message):**

1. **HANDOFF_UI session goal** — `**Open:**` line contains `[A-Z]+-[0-9]+` (e.g. `UIS-123`).
2. **Branch name** — e.g. `feature/UIS-123-dashboard`.
3. **Last commit subject** — starts with a ref.
4. **Fallback** — `chore: update .work.ui session state` (never a bare untyped subject).

Override any of it with `-m "<msg>"`. The agent-drafted message (C4/M4) beats the shell default when the session produced a richer description.

## Commit message examples

**With UIS ref (detected from HANDOFF_UI goal):**

```
UIS-123: add dashboard shell primitives

S0 primitives before S1 screens per craft tier refined.
```

**Docs/planning session (no ref):**

```
docs: close UI session - screen SPECs approved

HANDOFF_UI and NEXT_UI updated; S1 screens ready for build.
```

**Mid-session checkpoint (standalone commit):**

```
chore: update .work.ui session state
```

---

## Start protocol (detailed)

<a id="start-protocol-detailed"></a>

UI-scoped mirror of `@session-control start`. Writes only the HANDOFF_UI `Open` line (via shell); never touches `.work/`.

### S1 - Baseline reads (mandatory)

Read these files **in full** (or confirm missing). Record `pass` only after reading.

| # | File (repo-root path) | Pass criteria |
|---|----------------------|----------------|
| 1 | `.cursorrules` | identity, 7 core principles, UI block, no-commit rule |
| 2 | `.work.ui/context/HANDOFF_UI.md` | §Session status → §Open owner actions (UI) |
| 3 | `.work.ui/plans/NEXT_UI.md` | Recommended next + owner blockers + intake queue |
| 4 | `.work.ui/plans/UNKNOWNS.md` | every open unknown + owner + Blocks |
| 5 | `.work.ui/plans/foundation/*-01-*-ui-vision*.md` **if present** | one-sentence product intent (or skip) |

### S2 - Conditional reads (task-based)

Use HANDOFF_UI § Conditional reads: tokens → foundation doc 02; screen map → doc 04; building UI → approved screen SPEC; stack → `DOCS_UI_STACK.md`.

### S3 - Environment snapshot (evidence)

```bash
git status -sb
git log -1 --oneline
bash .ai.ui/scripts/ui-session.sh status
```

Record: branch, clean/dirty (`.work.ui/`), last commit, UI session open/closed.

### S4 - Session goal (interaction)

Capture goal from (in order): text after `start -`, else HANDOFF_UI **Recommended pick-up**, else ask **once**: *What is the primary UI goal for this session? (one line)*

### S5 - Mark session open (HANDOFF_UI)

```bash
bash .ai.ui/scripts/ui-session.sh start - <goal>   # or: start
```

The shell writes `**Open:** <date> - goal: <goal>`, refreshes `**Updated:**`, resets `**Closed:** -`. Nothing else is written; no git action.

### S6 - Start report (mandatory output)

```markdown
## UI session started - <Project>

**Date:** <ISO date> · **Branch:** <branch> · **`.work.ui/` tree:** clean | dirty

### Completion checklist
| # | Check | Result | Evidence |
|---|-------|--------|----------|
| 1 | .cursorrules read | pass/fail | |
| 2 | HANDOFF_UI read | pass/fail | |
| 3 | NEXT_UI read | pass/fail | |
| 4 | UNKNOWNS read | pass/fail | |
| 5 | Foundation doc 01 | pass/skip | |
| 6 | Conditional reads | pass/skip | <paths> |
| 7 | Git snapshot | pass | <one-liner> |
| 8 | Session goal captured | pass | <goal> |
| 9 | HANDOFF_UI marked Open | pass | shell output |

### Pick up here
<quote recommended next from NEXT_UI.md>

### Open blockers (owner)
<from HANDOFF_UI / NEXT_UI>
```

---

## Status protocol (detailed)

<a id="status-protocol-detailed"></a>

Read-only. Run the shell `status` verb, then:

```markdown
## UI session status - <Project>

**Session:** Open | Closed - <date> - <goal if Open>
**Branch:** <branch> · **`.work.ui/` tree:** clean | dirty (N paths)
**Pick up:** <one line from NEXT_UI.md>
**Owner blockers:** <short list or none>
```

---

## Context protocol (detailed)

<a id="context-protocol-detailed"></a>

Read-only full context load — sits between `status` and `start`. Writes nothing.

### X1 - Mandatory context reads

Same set as S1 (all five rows). Conditional reads per S2 only when the operator named a domain.

### X2 - Uncommitted-aware snapshot (evidence)

```bash
bash .ai.ui/scripts/ui-session.sh context
```

The shell reports, scoped to `.work.ui/`: branch + last commit, session open/closed, staged/unstaged/untracked counts, changed paths (no content), secrets-scan flags (paths only), last `.work.ui/` commit. **Do not** paste full diffs — paths + counts only.

### X3 - Context report (mandatory output)

```markdown
## UI session context - <Project>

**Date:** <ISO date> · **Branch:** <branch> · **`.work.ui/` tree:** clean | dirty (N paths)
**Last .work.ui commit:** <sha - subject>

### Context loaded
| # | File | Result | Note |
|---|------|--------|------|
| 1 | .cursorrules | pass | |
| 2 | .work.ui/context/HANDOFF_UI.md | pass (or missing) | §Session status: Open|Closed … |
| 3 | .work.ui/plans/NEXT_UI.md | pass (or missing) | |
| 4 | .work.ui/plans/UNKNOWNS.md | pass (or missing) | |
| 5 | Foundation doc 01 | pass|skip | |

### Uncommitted status (read-only)
- Staged: <N> · Unstaged: <N> · Untracked: <N> (under .work.ui/)
- Secrets scan: clean | <flagged paths (not printed)>
- (Clean tree → state "working tree clean".)

### Pick up here
<quote recommended next from NEXT_UI.md, or "no NEXT_UI.md">

### Open blockers (owner)
<from HANDOFF_UI / NEXT_UI, or none>

### No files written
This mode is read-only: HANDOFF_UI, NEXT_UI, UNKNOWNS are **not** modified. To open a UI session bookend, run `@ui-session start`.
```

---

## Commit protocol (detailed)

<a id="commit-protocol-detailed"></a>

### M1 - Working tree audit (same as C1)

Same as [C1](#c1---working-tree-audit-mandatory), scoped to `.work.ui/`.

### M2 - Verification gate (same as C2)

Same as [C2](#c2---verification-gate-this-session).

### M3 - Follow-ups

Same as [C3](#c3---follow-ups-required).

### M4 - Commit message with ref (always)

**Always** produce the commit message block — even when the tree is clean (`none - working tree clean`). Follow [Commit message rules](#commit-message-rules-summary): ref auto-detect priority, `UIS-123:` / `type:` subject format, `-m` override.

Label in report: **Commit message (draft)** vs **Commit message (used)**.

### M5 - Git actions (modifiers only)

Same as [C4b](#c4b--git-actions-modifiers-only). **Hard rule - agents MUST execute git:** typing `@ui-session commit` does not commit by itself — run the shell. Checklist item 6 is **fail** if the tree still has unstaged safe `.work.ui/` changes and no commit SHA was produced.

**Hard rule - no Co-authored-by:** never add trailers; hooks strip/reject them.

**Clean tree + `commit` modifier:** skip commit; report `Commit message (used): none - working tree clean`.

### M6 - Commit report (mandatory output)

```markdown
## UI commit completed - <Project>

**Date:** <ISO date> · **Branch:** <branch>

### Checklist
| # | Check | Result | Evidence |
|---|-------|--------|----------|
| 1 | Git audit (.work.ui/) | pass/fail | clean / N files changed |
| 2 | Secrets safe | pass/fail | |
| 3 | Verification honest | pass/fail | |
| 4 | Follow-ups listed | pass | |
| 5 | Commit message shown | pass | always |
| 6 | Git commit | pass/fail/skip | SHA + shell output |
| 7 | `.work.ui/` scope staged | pass/fail/skip | leftover safe paths listed |
| 8 | Git push (if requested) | pass/fail/skip | |

### Commit message
**Status:** draft | used
**Message:**

    UIS-123: subject line here

    Optional body.

**Git:** committed \<sha\> | push \<remote/branch\> result

**Session:** still open — no HANDOFF_UI or NEXT_UI changes.
```

---

## Close protocol (detailed)

<a id="close-protocol-detailed"></a>

**Execution order:** C1 → C2 → C3 → C4 (draft message) → C5 (HANDOFF_UI) → C6 (NEXT_UI) → C4b (git via shell, if `commit`/`push`) → C7 (optional) → C8 (report).

If C1 secrets **fail**, **stop** — do not run C5, C6, or C4b; report failure in C8.

### C1 - Working tree audit (mandatory)

```bash
git status -- .work.ui/
git diff --stat -- .work.ui/
git diff --cached --stat -- .work.ui/
```

Classify: uncommitted changes (summarize by area), untracked files (flag unexpected), staged only (ready), clean tree (state explicitly).

**Secrets scan (mandatory):** before summarizing, confirm no `.work.ui/` path matches: `credentials/`, `.env`, `.env.*` (except `.env.example`/`.sample`/`.template`), `*.pem`, `*.p12`, `*.key`, `*.pfx`, `*.p8`, `*id_rsa*`, `*.token`, `*.secret`. On match → checklist **fail**, **halt close** (no HANDOFF_UI/NEXT_UI/git); never print content. The shell re-checks mechanically at stage time.

### C2 - Verification gate (this session)

Per `.cursorrules` Completion Gate — answer honestly:

| Question | Answer |
|----------|--------|
| UI artifacts changed this session? | yes / no |
| UI task gate run (lint / token-lint / tests)? | yes / no / n/a |
| Visual / a11y verify needed and run? | yes / no / n/a |
| All passed? | yes / no / partial |
| What remains unverified? | list |

Do not claim "all good" if checks failed.

### C3 - Follow-ups required

Detect and list:

- [ ] Uncommitted `.work.ui/` work needing commit (or intentional WIP)
- [ ] HANDOFF_UI / NEXT_UI out of date vs actual state
- [ ] Open UI ADRs blocking the work touched
- [ ] Owner actions (brand assets, legal review, chart-library decision, …)
- [ ] Temp files under `.work.ui/tmp/` that should be cleaned
- [ ] Screen SPECs promised but not written
- [ ] Agent OS cross-link needed (`### UI layer` in `.work/context/HANDOFF.md`)

### C4 - Commit message with ref (always)

**Always** produce the commit message block — even when the tree is clean. Follow [Commit message rules](#commit-message-rules-summary). One message if changes are cohesive; suggest **split** with multiple blocks if not (but each commit still goes through the `.work.ui/`-scoped shell).

### C4b - Git actions (modifiers only)

| Modifier | Action |
|----------|--------|
| *(none)* | Message only. Operator runs git themselves. |
| `commit` | Only if C1 secrets **pass**. After C5/C6: `bash .ai.ui/scripts/ui-session.sh commit [-m "msg"]` → verify SHA + tree. |
| `commit scoped` | `bash .ai.ui/scripts/ui-session.sh commit scoped` — bookend files only (HANDOFF_UI + NEXT_UI); other staged `.work.ui/` paths are unstaged first (kept as working-tree changes). |
| `commit push` | After successful commit: `… commit push` or a follow-up `… push`. |

**Hard rule - agents MUST execute git:** typing `@ui-session close commit` does not commit by itself. Checklist item 6 is **fail** if the tree still has unstaged safe `.work.ui/` changes and no commit SHA was produced.

**Default commit scope (target mode):** every safe path under `.work.ui/` (status `M`, `A`, `D`, `R`, `C`, `??` — incl. new untracked files/dirs), except secrets-scan paths (never) and `.work.ui/tmp/` (unless the operator explicitly named it). The shell's `git add -A -- .work.ui` implements this; exclusions are applied by the agent before invoking it (delete/gitignore temp files, never force them in). **Framework mode (source repo):** the whole tree — `git add -A` — all modified/added/new files.

**Post-commit verification (mandatory):**

| Check | pass when |
|-------|-----------|
| Commit created | shell printed a new short SHA |
| Staging complete | no remaining safe `M`/`D`/`??` under `.work.ui/`, or report lists each leftover + why |

**On commit failure:** report shell/hook output; do not claim close complete for the git step; HANDOFF_UI/NEXT_UI updates still stand if already written.

**Never:** `git commit --no-verify`, `git push --force` unless the operator explicitly requests in the same message.

### C5 - Update HANDOFF_UI (mandatory on close)

Rewrite top sections (keep history append-only):

1. **Session status:** `**Open:** closed`; `**Closed:** <date>` + one-line outcome; `**Updated:**` today (the shell writes these three lines — verify them).
2. **UI layer state:** current truth (milestone, verify state).
3. **Recommended pick-up:** point to `NEXT_UI.md`.
4. **What this cycle produced (UI):** append rows for new/updated artifacts (no duplicates).
5. **Open owner actions (UI):** refresh.
6. **UI readiness:** update a row only with evidence (verify run, gate certify).
7. **Cross-link:** if Agent OS is present and a milestone closed, note the `### UI layer` line for `.work/context/HANDOFF.md`.

Do not delete historical rows in artifact tables; append new entries.

### C6 - Update NEXT_UI.md (mandatory on close)

- Move completed items to **Done** with date + Notes (gate-verify: Done tasks must carry Notes).
- Set **one** clear **Recommended next**.
- Refresh **Blocked** / owner blockers.
- Note new intake-queue entries if ideas were parked.

### C7 - Optional: ui-design-foundation status

If the repo tracks UI readiness, attach ≤5 lines: `ui-foundation-complete` / `screen-spec-ready` / `ui-implementation-ready` snapshot (read-only).

### C8 - Close report (mandatory output)

```markdown
## UI session closed - <Project>

**Date:** <ISO date> · **Branch:** <branch>

### Completion checklist
| # | Check | Result | Evidence |
|---|-------|--------|----------|
| 1 | Git audit (.work.ui/) | pass/fail | clean / N files changed |
| 2 | Secrets safe | pass/fail | |
| 3 | Verification honest | pass/fail | |
| 4 | Follow-ups listed | pass | |
| 5 | Commit message shown | pass | always |
| 6 | Git commit (if requested) | pass/fail/skip | SHA + shell output |
| 6b | `.work.ui/` scope staged (default `commit`) | pass/fail/skip | leftovers listed |
| 7 | Git push (if requested) | pass/fail/skip | |
| 8 | HANDOFF_UI updated | pass/fail | |
| 9 | NEXT_UI updated | pass/fail | |
| 10 | Foundation status (optional) | pass/skip | |

### Commit message
**Status:** draft | used
**Ref:** <UIS-123 | none>
**Message:** (plain text below - always present)

    UIS-123: subject line here

    Optional body - why, not what.

**Git:** no commit (default) | committed \<sha\> | push \<remote/branch\> result

### Follow-ups before next session
<ordered list>

### Next session should
<one line from NEXT_UI.md>
```

---

## Critical interactions

<a id="critical-interactions"></a>

| When | Ask / do |
|------|----------|
| **Start** | Prior HANDOFF_UI says `closed` → treat as new UI session; do not assume prior chat memory |
| **Start** | Missing `.work.ui/` / HANDOFF_UI → run `@ui-bootstrap init` first |
| **Start** | Dirty `.work.ui/` tree at start → note in report; ask if continuing WIP |
| **Start** | HANDOFF_UI already **Open**, new goal differs → shell overwrites the Open line; note prior goal in the start report |
| **Close** | Large uncommitted diff → suggest commit split (each part still `.work.ui/`-scoped) |
| **Close** | Operator expected commit but tree still dirty → **fail** item 6/6b |
| **Commit** | `@ui-session commit` → Commit protocol; **do not** update HANDOFF_UI or NEXT_UI |
| **Add** | `@ui-session add` → stage only; report staged paths; session stays open |
| **Push** | Mixed history (non-`.work.ui/` commits ahead of upstream) → target-mode shell refuses; use plain `git push` outside this skill. Framework mode: no `.work.ui`-only restriction — push covers the framework's own whole-tree history |
| **Framework repo** | This repo IS the UI Design OS source → `add`/`commit`/`push` intentionally cover **all** modified/added/new files (skills, scripts, standards, docs, `.work.ui/`) |
| **Any** | Secrets scan fail → **halt**; never print secret content; advise gitignore |
| **Any** | Paths outside `.work.ui/` need committing → `@session-control` (Agent OS) or operator's own git |

---

## Anti-patterns

<a id="anti-patterns"></a>

- Claiming "context loaded" without reading HANDOFF_UI and NEXT_UI
- Closing the UI session without updating HANDOFF_UI and NEXT_UI
- Committing on plain `close` (without the `commit` modifier)
- `close commit` with only HANDOFF_UI/NEXT_UI staged while other safe `.work.ui/` paths remain dirty (that is `scoped`, not default)
- **Reporting close commit done without running the shell/git** or without a new SHA
- Staging outside `.work.ui/` in a target repo — or working around the script's refusal (framework mode stages the whole tree by design; do not "fix" that either)
- Staging secrets-pattern paths (script refuses; never route around)
- Omitting the commit message block from close/commit reports
- Marking checklist `pass` without evidence
- Running HANDOFF_UI/NEXT_UI updates on standalone `commit` / `commit push` / `add`
- Treating `context` as `start` (context writes nothing)
- Using `ui-session` for whole-repo commits in an **adopter target repo** (that is `@session-control` / operator git — whole-tree commits are correct only in the framework source repo)
- Adding `Co-authored-by:` trailers or `git commit --no-verify`

---

## Wrong prompts

| Prompt | Problem | Use instead |
|--------|---------|-------------|
| `close` expecting auto-commit | Default is draft only | `close commit` |
| `close commit` but tree still dirty | Agent staged bookends only or skipped the shell | Re-run close; follow C4b default scope |
| `close commit` for bookend files only | Default commits all safe `.work.ui/` changes | `close commit scoped` |
| `close push` without `commit` | Skill maps to commit+push | `close commit push` |
| `commit` expecting HANDOFF_UI update | Standalone commit skips bookends | Use `close commit` instead |
| `add` expecting a commit | `add` is stage-only | Use `commit` instead |
| `context` expecting session open | `context` writes nothing | Use `start` instead |
| `start close` in one call | Contradictory — script refuses | Two invocations |
| `status commit` in one call | Read-only + write mix — script refuses | Two invocations |

---

## Project layout (convention)

**`{WORK_UI_ROOT}` = `.work.ui/`** at repo root (sibling of `.ai.ui/` in adopter repos). All session git ops are **scoped to `.work.ui/`** (default scope).

```
.work.ui/                        ← {WORK_UI_ROOT}
  context/HANDOFF_UI.md          ← ui-session ({HANDOFF_UI})
  plans/NEXT_UI.md               ← ui-session + ui-component-build ({UI_ITERATION_CARRIER})
  plans/UNKNOWNS.md              ← open unknowns
  screens/                       ← ui-screen-spec ({SCREEN_SPEC_ROOT})
  commit-ref-pending/            ← post-commit hook output (ref → sha)
.ai.ui/skills/                   ← portable skills only (never session artifacts)
```

Projects without `.work.ui/context/HANDOFF_UI.md`: run `@ui-bootstrap init` (or `bash .ai.ui/templates/bootstrap.sh`).
