---
name: ui-session
description: >-
  .work.ui-scoped session carrier for the target repo. Handles any combination
  of commit / close / push verbs — git operations are STRICTLY limited to the
  target repo's .work.ui/ working directory (never app code, .ai/, .work/, or
  .cursorrules). `commit` stages all .work.ui/ changes including NEW untracked
  files and dirs. `close` marks the UI session closed in HANDOFF_UI.md. `push`
  pushes the current branch. Use ui-session commit, ui-session close,
  ui-session push, ui-session status, or any combination (e.g. close commit
  push). Machine-enforced scope guard: scripts/ui-session.sh.
---

# ui-session

`.work.ui`-scoped session carrier: commit / close / push **of `.work.ui/` changes only**, in the **target repo** (the repo whose `<repo-root>/.work.ui/` is being maintained). Complements Agent OS `@session-control` (full-repo session bookends); `ui-session` never touches anything outside `.work.ui/`.

**Shell:** `bash <repo-root>/.ai.ui/scripts/ui-session.sh <verbs...>` (run from anywhere inside the target repo; resolves repo root via `git rev-parse`)

**Canonical path:** `.ai.ui/skills/ui-session/skill.md` · **Shell:** `.ai.ui/scripts/ui-session.sh` · **Scope:** `<repo-root>/.work.ui/` ONLY

---

## Parse invocation

| User says | Actions (order-independent; normalized close → commit → push) |
|-----------|--------------------------------------------------------------|
| `@ui-session status` | Read-only: repo root, `.work.ui/` presence, session open/closed, changes under `.work.ui/`, last `.work.ui` commit |
| `@ui-session close` | Mark session closed in `.work.ui/context/HANDOFF_UI.md` (`**Open:** closed`, `Updated`/`Closed` dates) |
| `@ui-session commit` | `git add -A -- .work.ui` (includes **untracked files and dirs**) + `git commit -m "ui-session: .work.ui update"` |
| `@ui-session commit -m "msg"` | Same, custom message |
| `@ui-session push` | `git push` current branch (requires upstream; only meaningful after commit) |
| `@ui-session close commit push` | Any subset/order of `close`/`commit`/`push` — executed in dependency order (close → commit → push) |

**Default:** `status` if no verb matches. **No verb → nothing destructive:** `commit`/`push` only ever run when explicitly named in the same invocation (which is the required same-message intent per the framework's Git rules).

---

## Scope invariant (hard rule)

**Every git write op is restricted to `<repo-root>/.work.ui/`.** The shell backstop enforces this mechanically:

1. `git add -A -- .work.ui` — the pathspec keeps staging inside `.work.ui/`.
2. Pre-commit check: if any **already-staged** path lies outside `.work.ui/` (e.g. staged by another tool), `ui-session` **refuses** to commit and lists the offending paths.
3. Post-add check: if anything outside `.work.ui/` ended up staged, it is unstaged and the commit is refused.

**Never** stage, commit, or push app code, `.ai/`, `.ai.ui/`, `.work/`, `.cursorrules`, or any other path. If the operator needs those committed, they use `@session-control` (Agent OS) or their own git workflow — `ui-session` is not a whole-repo commit tool.

**Commit message default:** `ui-session: .work.ui update` (or `-m "<msg>"`).

---

## I0 — Pre-checks

| Condition | Action |
|-----------|--------|
| Not inside a git repo | **Block**: report; run from the target repo (or a subdir) |
| `.work.ui/` missing | **Block**: run `@ui-bootstrap init` first |
| Staged path(s) outside `.work.ui/` (commit/push) | **Block**: list them; unstage or commit via Agent OS first |
| `HANDOFF_UI.md` missing (close) | **Block**: nothing to close |
| No upstream for current branch (push) | **Report**: push fails with set-upstream hint (`git push -u origin <branch>`) |

---

## I1 — close

1. Read `.work.ui/context/HANDOFF_UI.md`.
2. Set `**Open:** closed`, `**Updated:** YYYY-MM-DD`, `**Closed:** YYYY-MM-DD` (today's date).
3. Do **not** touch anything else. The close edit is itself a `.work.ui/` change — run `commit` (same or next invocation) to capture it.

---

## I2 — commit

1. `git add -A -- .work.ui` — this stages new (untracked) files **and** directories, modified files, and deletions under `.work.ui/`, exactly as required.
2. Verify staged paths ⊆ `.work.ui/` (script-enforced). If violated → unstage and block.
3. `git commit -m "<message>"`. If nothing is staged → clean no-op ("nothing to commit"), exit 0.

**Untracked guarantee:** `git add -A -- .work.ui` includes files and dirs not yet tracked — e.g. a newly created `.work.ui/screens/<slug>/YYYYMMDD-SCREEN-SPEC.md` is committed. Confirm with `git status --porcelain -- .work.ui` afterward.

---

## I3 — push

1. Run after `commit` (same invocation or earlier). `git push` the current branch.
2. **Scope check (script-enforced):** before pushing, the script verifies the to-be-pushed commits touch only `.work.ui/` paths — the upstream range `@{u}..HEAD` when an upstream exists, else at least the tip commit. If any commit in the range touches a path outside `.work.ui/` (e.g. an app-code commit made outside `ui-session`), push is **refused** and the offending paths are listed — `ui-session` never pushes mixed history.
3. If no upstream: report `git push -u origin <branch>` and exit non-zero — do not invent a remote.
4. Push propagates only `.work.ui/`-scoped history (enforced by the check above).

---

## Combinations (verification)

| Invocation | Expected result |
|------------|-----------------|
| `close commit` | Session marked closed, HANDOFF_UI edit committed |
| `commit close` | Same result (order-independent) |
| `commit push` | `.work.ui/` changes committed then pushed |
| `close commit push` | Close → commit → push in one call |
| `commit -m "x"` | Custom message used |
| `status` | Read-only; no write |
| `commit` with no changes | No-op, exit 0 |

**Combined invocation is verified by the script self-test** (`bash scripts/ui-session.sh --self-test`, wired into `framework-verify.sh`): creates a tmp git repo, closes+commits with an untracked file, asserts the commit contains only `.work.ui/` paths (including the untracked file), asserts an outside staged path blocks the commit, and pushes to a bare remote.

---

## Hard rules

1. Never stage/commit/push outside `<repo-root>/.work.ui/` (script-enforced for stage+commit+push; agent must double-check).
2. `commit`/`push` only when the operator names them in the same message (same-message intent gate).
3. Never force-push, amend, reset, or rewrite history.
4. When `.ai/` (Agent OS) is present, full-repo session bookends remain with `@session-control`; `ui-session` is the `.work.ui`-scoped complement — never call it "the session skill" for whole-repo work.
5. Do not write project artifacts under `.ai.ui/` — everything stays in `.work.ui/`.

---

## Completion checklist

| # | Check | Result |
|---|-------|--------|
| 1 | Repo root resolved (`git rev-parse --show-toplevel`) | pass |
| 2 | `.work.ui/` present before any write | |
| 3 | Staged paths ⊆ `.work.ui/` (script check) | |
| 4 | `commit` included untracked files/dirs under `.work.ui/` | |
| 5 | `close` set `Open: closed` + dates in HANDOFF_UI | |
| 6 | `push` pushed current branch (when requested) or reported upstream setup | |
| 7 | No path outside `.work.ui/` touched | |

## Next commands

```text
@ui-session status
@ui-session close commit push -m "S2 milestone: dashboard shell"
@ui-bootstrap init            # if .work.ui/ missing
```

## See also

- [`SKILL_DEPENDENCIES.md`](../SKILL_DEPENDENCIES.md) — gate matrix + redirect cheat sheet
- [`COHABITATION.md`](../../COHABITATION.md) — `.work.ui`-scoped session vs Agent OS `@session-control`
- [`START_HERE.md`](../../START_HERE.md) — operator decision tree
