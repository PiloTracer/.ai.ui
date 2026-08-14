---
name: ui-session
description: >-
  .work.ui-scoped session carrier for adopter repos — the UI-scoped
  counterpart of Agent OS @session-control — and whole-repo session carrier
  when run inside the UI Design OS framework source repo itself (auto-detected:
  framework mode = whole tree; target mode = .work.ui/ only). Supports the
  same verbs as session-control: start, status, context, add, commit, close,
  push, in any combination (e.g. close commit push), plus the `scoped`
  modifier and `-m` message. In target repos, git operations are STRICTLY
  limited to the target repo's .work.ui/ working directory (never app code,
  .ai/, .work/, or .cursorrules). `start` marks the UI session open in
  HANDOFF_UI.md, `close` marks it closed; `add` stages in-scope changes
  (incl. NEW untracked files and dirs) without committing; `commit` stages +
  commits with a ref-prefixed default message; `push` pushes (target mode:
  .work.ui-scoped history only); `context` and `status` are read-only.
  Secrets-pattern paths are never staged in either mode. Machine-enforced
  scope guard: scripts/ui-session.sh. Use ui-session start, close, commit,
  push, add, status, context, or any combination.
---

# ui-session

Session carrier with **session-control verb parity**: **start / status / context / add / commit / close / push**, with a dual-scope model auto-detected per repo:

- **Target mode** (adopter project repo — the framework lives under `.ai.ui/`): every git write op is strictly scoped to `<repo-root>/.work.ui/`. `ui-session` never touches app code, `.ai/`, `.work/`, or `.cursorrules`. This is the `.work.ui`-scoped complement to Agent OS `@session-control` (which owns full-repo bookends).
- **Framework mode** (the repo IS the UI Design OS source — repo root carries `COHABITATION.md` + `skills/ui-session/skill.md` + `templates/bootstrap.sh`): `add` / `commit` / `push` apply to **all modified/added/new files** in the repo. Session bookends still land in `.work.ui/`.

**Shell:** `bash <repo-root>/.ai.ui/scripts/ui-session.sh <verbs...>` (run from anywhere inside the target repo; resolves repo root via `git rev-parse`). When this repo **is** the git root: `bash scripts/ui-session.sh <verbs...>`. Every action line reports the active mode (`[mode: framework (whole repo)]` / `[mode: target (.work.ui/ only)]`).

**Canonical path:** `.ai.ui/skills/ui-session/skill.md` · **Invocation examples + detailed protocols:** `reference.md` · **Scope:** target repo → `.work.ui/` ONLY · framework repo → whole tree

**Hard rules:**

- **Default close / default commit:** never `git commit` or `git push`. Only when the invocation names **`commit`** and/or **`push`** (same-message intent per the framework's Git rules).
- **`close commit` / `commit` / any combination with `commit`:** **MUST** run the shell script (or the exact git steps it performs) — staging **`.work.ui/` only in target mode, the whole tree in framework mode** (default scope, incl. new untracked files/dirs). A dirty in-scope tree after close with only a draft message is **fail**.
- **Always** show the commit message — drafted, used for commit, or `none - working tree clean`.
- **`commit` / `commit push` (standalone):** git only — **no** HANDOFF_UI or NEXT_UI updates. Session stays open. Useful for mid-session checkpoints.
- **`add` stages without committing.** Session stays open; nothing else changes.
- **Commit subject:** `UIS-123: description` when a task ref is known, else `type: description` (`feat`/`fix`/`refactor`/`docs`/`chore`) — per repo `.cursorrules` §Git. Never invent a ref; never commit with a bare untyped subject.
- Never paste secrets from `.env`, `credentials/`, or tokens into chat or HANDOFF_UI. Secrets-pattern paths are never staged (script-enforced).
- Every write mode ends with a **Completion checklist** — each item `pass` | `fail` | `skip` with evidence.

### Path resolution (mandatory before any Read)

Resolve from **repository root**. `{WORK_UI_ROOT}` = **`.work.ui/`** — not the repo root, never under `.ai.ui/`.

| Artifact | Read / write this path |
|----------|------------------------|
| `{HANDOFF_UI}` | `.work.ui/context/HANDOFF_UI.md` |
| `{UI_ITERATION_CARRIER}` | `.work.ui/plans/NEXT_UI.md` |
| `{UI_PLANS_ROOT}/UNKNOWNS.md` | `.work.ui/plans/UNKNOWNS.md` |

**Never** open `context/HANDOFF_UI.md` or `plans/NEXT_UI.md` at repo root, and never edit Agent OS `.work/context/HANDOFF.md` from this skill (that is `@session-control`'s carrier; see [`COHABITATION.md`](../../COHABITATION.md)).

---

## Parse invocation

Normalize the user message to **verbs** + optional **modifiers**. Order-independent; execution is normalized to dependency order: start → close → add → commit → push.

| User says | Verbs | Git action |
|-----------|-------|------------|
| `@ui-session` **start** | start | - |
| `@ui-session` **start** - \<goal\> | start | - (goal recorded in HANDOFF_UI Open line) |
| `@ui-session` **status** | status | - (read-only) |
| `@ui-session` **context** | context | - (read-only, uncommitted-aware) |
| `@ui-session` **add** | add | stage `.work.ui/` (incl. untracked), **no commit** |
| `@ui-session` **close** | close | draft message only |
| `@ui-session` **close** **commit** | close | commit all **safe** changes under `.work.ui/` (default scope) |
| `@ui-session` **close** **commit** **scoped** | close | commit only HANDOFF_UI + NEXT_UI (bookend files) |
| `@ui-session` **close** **commit** **push** | close | commit then push |
| `@ui-session` **close** **push** | close | treat as **commit push** (`push` requires commit) |
| `@ui-session` **commit** | commit | commit all safe changes under `.work.ui/`, NO close |
| `@ui-session` **commit** -m "msg" | commit | same, custom message |
| `@ui-session` **commit** **push** | commit | commit then push, NO close |
| `@ui-session` **push** | push | push current branch (scope-checked) |

**Aliases (same verb):** `begin`, `open` → start; `end`, `handoff` → close; `stage` → add.

**Mode note:** the Git actions above describe **target mode** (`.work.ui/` scope). In **framework mode** (the UI Design OS source repo), `add` / `commit` stage the **whole repo tree** and `push` has no `.work.ui`-only history restriction.

**Goal text:** anything after a bare `-` (not the words `commit`/`push`/`scoped`).

**Commit scope:** depends on the auto-detected mode (see intro). **Target mode:** default is **`.work.ui/` only** (all safe changed + **new untracked files/dirs** under `.work.ui/`; e.g. `git add -A -- .work.ui`). Nothing outside `.work.ui/` is staged — ever. **Framework mode** (this source repo): default is the **whole repo tree** (`git add -A` — all modified/added/new files). Either mode: use **`commit scoped`** for bookend files only (HANDOFF_UI + NEXT_UI; any other staged path is unstaged first and left as a working-tree change).

**Standalone commit:** `commit` / `commit push` run the same git steps as `close commit` / `close commit push` but **skip** HANDOFF_UI and NEXT_UI updates. The session remains open.

**Read-only modes:** `status` and `context` write nothing and cannot be combined with write verbs. `start` + `close` in one invocation is contradictory — the script refuses.

---

## Step 0 - Pick a mode

| Mode | Triggers | Action |
|------|----------|--------|
| **start** | `start`, optional goal | [Start protocol](#start-protocol) |
| **close** | `close` [commit] [push] [scoped] | [Close protocol](#close-protocol) |
| **commit** | `commit` [push] [scoped] [-m msg] | [Commit protocol](#commit-protocol) — git only; no HANDOFF_UI/NEXT_UI writes |
| **add** | `add` [scoped] | Stage-only via shell; no commit, no HANDOFF_UI/NEXT_UI writes |
| **push** | `push` | Scope-checked `git push` via shell |
| **context** | `context` | [Context protocol](#context-protocol) — full mandatory context load + uncommitted-aware summary; no writes |
| **status** | `status` | [Status protocol](#status-protocol) — compact snapshot; no writes |

---

## Start protocol

UI-scoped counterpart of `@session-control start`. Marks the UI session open in HANDOFF_UI; does **not** touch Agent OS `.work/` carriers.

### S1 - Baseline reads (mandatory)

Five-file read table (.cursorrules, HANDOFF_UI, NEXT_UI, UNKNOWNS, optional foundation doc 01): [reference.md § Start protocol (detailed)](reference.md#start-protocol-detailed) (S1).

### S2 - Conditional reads (task-based)

HANDOFF_UI § Conditional reads table (tokens / screen map / SPECs / stack): [reference.md § Start protocol (detailed)](reference.md#start-protocol-detailed) (S2).

### S3 - Environment snapshot (evidence)

Git snapshot scoped to `.work.ui/`: [reference.md § Start protocol (detailed)](reference.md#start-protocol-detailed) (S3).

### S4 - Session goal (interaction)

Capture goal from invocation or HANDOFF_UI pick-up; ask once if unclear: [reference.md § Start protocol (detailed)](reference.md#start-protocol-detailed) (S4).

### S5 - Mark session open (HANDOFF_UI)

Run the shell `start` verb (writes `**Open:** <date> - goal: <goal>`, refreshes `Updated`, resets `Closed`): [reference.md § Start protocol (detailed)](reference.md#start-protocol-detailed) (S5).

### S6 - Start report (mandatory output)

Start report template and checklist: [reference.md § Start protocol (detailed)](reference.md#start-protocol-detailed) (S6).

---

## Status protocol

Read-only snapshot. **No** HANDOFF_UI/NEXT_UI writes. **No** completion checklist.

Run `bash .ai.ui/scripts/ui-session.sh status` and add one line from `{UI_ITERATION_CARRIER}` (**Pick up:**) plus owner blockers from HANDOFF_UI. Output template: [reference.md § Status protocol (detailed)](reference.md#status-protocol-detailed).

For full context load **without** writes, use **context**. To open the UI session bookend, use **start**.

---

## Context protocol

Read-only full context load. **No** HANDOFF_UI/NEXT_UI writes. **No** completion checklist. Sits between `status` (compact) and `start` (full load + marks HANDOFF_UI Open).

Difference from `start`: writes nothing. Difference from `status`: loads the **full mandatory context set** (S1) plus an uncommitted-aware **`.work.ui/` snapshot** (staged/unstaged/untracked counts, secrets flags — paths only, never content).

### X1 - Mandatory context reads

Same set as S1: [reference.md § Context protocol (detailed)](reference.md#context-protocol-detailed) (X1).

### X2 - Uncommitted-aware snapshot (evidence)

`bash .ai.ui/scripts/ui-session.sh context` (read-only): [reference.md § Context protocol (detailed)](reference.md#context-protocol-detailed) (X2).

### X3 - Context report (mandatory output)

Report template: [reference.md § Context protocol (detailed)](reference.md#context-protocol-detailed) (X3).

---

## Commit protocol

**Execution order:** M1 → M2 → M3 → M4 (draft message with ref) → M5 (git via shell, if `commit`/`push`) → M6 (report).

Runs git commit and optional push **without** updating HANDOFF_UI or NEXT_UI. Session remains open. Idempotent — re-runnable mid-session.

If M1 secrets **fail**, **stop** — do not run M4 or M5.

### M1 - Working tree audit (same as C1)

Same as [C1 in reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed), scoped to `.work.ui/`.

### M2 - Verification gate (same as C2)

Same as [C2 in reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed).

### M3 - Follow-ups

Same as [C3 in reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed).

### M4 - Commit message with ref (always)

Always produce the commit message block — even when tree is clean. Ref extraction, subject/body format, report labels: [reference.md § Commit protocol (detailed)](reference.md#commit-protocol-detailed) (M4).

### M5 - Git actions (modifiers only)

Same as [C4b in reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed). **Hard rules:** agents MUST run the shell (or its exact git steps); no `Co-authored-by:` trailers.

### M6 - Commit report (mandatory output)

Report template and checklist: [reference.md § Commit protocol (detailed)](reference.md#commit-protocol-detailed) (M6).

---

## Close protocol

**Execution order:** C1 → C2 → C3 → C4 (draft message) → C5 (HANDOFF_UI) → C6 (NEXT_UI) → C4b (git via shell, if `commit`/`push`) → C7 (optional) → C8 (report).

If C1 secrets **fail**, **stop** — do not run C5, C6, or C4b; report failure in C8.

### C1 - Working tree audit (mandatory)

`git status` + diff stats scoped to `.work.ui/`; classify findings; **secrets scan** (halt close on match). Table and patterns: [reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed) (C1).

### C2 - Verification gate (this session)

Completion Gate honesty table (UI task gate: lint / token-lint / visual / a11y as applicable): [reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed) (C2).

### C3 - Follow-ups required

Uncommitted work, stale HANDOFF_UI/NEXT_UI, owner actions, temp files, SPECs promised: [reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed) (C3).

### C4 - Commit message with ref (always)

Always show the commit message in the close report. Ref priority order and format: [reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed) (C4).

### C4b - Git actions (modifiers only)

Modifier table, **default commit scope**, shell invocation, post-commit verification: [reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed) (C4b).

### C5 - Update HANDOFF_UI (mandatory on close)

Session-status rewrite + section refresh list: [reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed) (C5).

### C6 - Update NEXT_UI.md (mandatory on close)

Done / Recommended next / Blocked refresh: [reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed) (C6).

### C7 - Optional: ui-design-foundation status

Optional ≤5-line readiness snapshot on close: [reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed) (C7).

### C8 - Close report (mandatory output)

Close report template and checklist: [reference.md § Close protocol (detailed)](reference.md#close-protocol-detailed) (C8).

---

## Scope model (hard rule)

**Target mode (adopter repo): every git write op is restricted to `<repo-root>/.work.ui/`.** **Framework mode (this source repo): `add` / `commit` / `push` cover the whole repo tree.** The shell detects the mode from the repo root (framework markers: `COHABITATION.md` + `skills/ui-session/skill.md` + `templates/bootstrap.sh`) and enforces it mechanically:

1. Stage scope — target: `git add -A -- .work.ui`; framework: `git add -A`. Either mode, `scoped`: only `.work.ui/context/HANDOFF_UI.md` + `.work.ui/plans/NEXT_UI.md`.
2. Pre-commit check (target mode): if any **already-staged** path lies outside `.work.ui/` (e.g. staged by another tool), `ui-session` **refuses** and lists the offending paths.
3. Post-add check (target mode): if anything outside `.work.ui/` ended up staged, it is unstaged and the commit is refused.
4. Secrets scan (both modes): staged paths matching `credentials/`, `.env*`, `*.pem|p12|key|pfx|p8|token|secret`, `id_rsa` are **never** committed — the script unstages them and refuses.
5. Push check (target mode): the to-be-pushed range must touch `.work.ui/` paths only, else push is refused. Framework mode pushes normally (the framework's own history spans all areas).

**Target mode:** **never** stage, commit, or push app code, `.ai/`, `.ai.ui/`, `.work/`, `.cursorrules`, or any other path. If the operator needs those committed, they use `@session-control` (Agent OS) or their own git workflow — in a target repo, `ui-session` is not a whole-repo commit tool. **Framework mode** exists precisely because the source repo's commits must span the whole tree (`skills/`, `scripts/`, `standards/`, docs, `.work.ui/`).

**Commit message default (shell):** `<REF>: update .work.ui session state` (target) / `<REF>: update framework session state` (framework) when a ref is detectable (HANDOFF_UI Open goal → branch → last commit subject), else `chore: …`. Override with `-m "<msg>"`.

---

## Combinations (verification)

| Invocation | Expected result |
|------------|-----------------|
| `start - <goal>` | HANDOFF_UI `Open: <date> - goal: <goal>`; no git action |
| `close` | Session marked closed; commit message drafted; no git write |
| `close commit` | Session marked closed, `.work.ui/` changes committed |
| `commit close` | Same result (order-independent) |
| `close commit scoped` | Only HANDOFF_UI + NEXT_UI committed |
| `commit push` | `.work.ui/` changes committed then pushed |
| `close commit push` | Close → commit → push in one call |
| `add` | `.work.ui/` changes staged (incl. untracked); no commit |
| `commit -m "x"` | Custom message used |
| `status` / `context` | Read-only; no write |
| `commit` with no changes | No-op, exit 0 |
| `start close` | Refused (contradictory) |
| `status commit` | Refused (read-only + write mix) |

**Verified by the script self-test** (`bash scripts/ui-session.sh --self-test`, wired into `framework-verify.sh`): tmp-repo behavioral test covering target-mode scope guard, untracked inclusion, close, combinations, push, start, add, scoped, secrets refusal, read-only context, the ref-prefixed default message, and framework-mode whole-tree commit/push/status.

---

## Hard rules

1. Target mode: never stage/commit/push outside `<repo-root>/.work.ui/` (script-enforced for stage+commit+push; agent must double-check). Framework mode: whole-tree is the intended scope — still never stage secrets-pattern paths.
2. `commit`/`push` only when the operator names them in the same message (same-message intent gate).
3. Never force-push, amend, reset, or rewrite history. No `Co-authored-by:` trailers.
4. When `.ai/` (Agent OS) is present, full-repo session bookends remain with `@session-control`; `ui-session` is the `.work.ui`-scoped complement — never call it "the session skill" for whole-repo work.
5. Do not write project artifacts under `.ai.ui/` — everything stays in `.work.ui/`.
6. `start`/`context`/`status` never write git state; `add` never commits; `commit` never closes the session.

---

## Critical interactions

| When | Ask / do |
|------|----------|
| **Start** | Prior HANDOFF_UI says `closed` → treat as new UI session; do not assume prior chat memory |
| **Start** | Missing HANDOFF_UI → run `@ui-bootstrap init` first |
| **Close** | `close commit` / `close commit push` → run shell after HANDOFF_UI/NEXT_UI updates; stage **`.work.ui/` scope** |
| **Commit** | User says `@ui-session commit` → Commit protocol; **do not** update HANDOFF_UI or NEXT_UI |
| **Any** | Secrets scan fail → **halt**; never print secret content |

Full table: [reference.md § Critical interactions](reference.md#critical-interactions).

---

## Anti-patterns

- Claiming "context loaded" without reading HANDOFF_UI and NEXT_UI
- Closing the UI session without updating HANDOFF_UI and NEXT_UI (on **close**)
- **`close commit` without running the shell/git** or without a new SHA
- **Staging outside `.work.ui/` in a target repo** on any commit — the scope invariant is absolute there (framework mode stages the whole tree by design)
- Committing a secrets-pattern path (the script refuses; do not route around it)
- Omitting the commit message block from close/commit reports
- Running HANDOFF_UI/NEXT_UI updates on standalone `commit` / `commit push` / `add`
- Adding `Co-authored-by:` trailers
- Treating `context` as `start` (context writes nothing)

Full list: [reference.md § Anti-patterns](reference.md#anti-patterns).

---

## Completion checklist

| # | Check | Result |
|---|-------|--------|
| 1 | Repo root resolved (`git rev-parse --show-toplevel`) | pass |
| 2 | `.work.ui/` present before any write | |
| 3 | Staged paths ⊆ `.work.ui/` (script check) | |
| 4 | Secrets scan clean (script check) | |
| 5 | `commit` included untracked files/dirs under `.work.ui/` | |
| 6 | Commit message shown (draft / used / none - clean) | |
| 7 | `start` set `Open: <date> [- goal]` / `close` set `Open: closed` + dates in HANDOFF_UI | |
| 8 | `push` pushed current branch (when requested) or reported upstream setup | |
| 9 | No path outside `.work.ui/` touched | |

## Next commands

```text
@ui-session start - S2 dashboard shell
@ui-session status
@ui-session context
@ui-session add                       # stage checkpoint, no commit
@ui-session commit push -m "UIS-123: dashboard shell"
@ui-session close commit push -m "S2 milestone: dashboard shell"
@ui-bootstrap init                    # if .work.ui/ missing
```

## See also

- [`SKILL_DEPENDENCIES.md`](../SKILL_DEPENDENCIES.md) — gate matrix + redirect cheat sheet
- [`COHABITATION.md`](../../COHABITATION.md) — `.work.ui`-scoped session vs Agent OS `@session-control`
- [`START_HERE.md`](../../START_HERE.md) — operator decision tree
- Agent OS `.ai/skills/session-control/` — the full-repo counterpart this skill mirrors
