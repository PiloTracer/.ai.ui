---
name: ui-install
description: >-
  Install .ai.ui into a target project. Two modes: copy (rsync clean copy
  excluding .git, .github, .gitignore, root .cursorrules) or submodule
  (git submodule add from origin remote). Use copy - <path>, submodule - <path>,
  status.
---

# ui-install

**Shell:** `bash .ai.ui/scripts/install-target.sh <mode> <path>`

Installs this `.ai.ui` framework into a target project so you can use UI Design
OS skills there. Path auto-resolution: if path ends in `.ai.ui` it is used
as-is; otherwise `.ai.ui` is appended inside the path.

---

## Parse invocation

| User says | Mode |
|-----------|------|
| `@ui-install` **copy - /path/to/repo** | Copy clean files (no .git, .github, .gitignore, .cursorrules) to `/path/to/repo/.ai.ui` |
| `@ui-install` **copy - /path/to/repo/.ai.ui** | Same, destination explicit |
| `@ui-install` **submodule - /path/to/repo** | `git submodule add` from origin remote to `/path/to/repo/.ai.ui` |
| `@ui-install` **submodule - /path/to/repo/.ai.ui** | Same, destination explicit |
| `@ui-install` **status** | Report current install locations of .ai.ui (git submodules, known copies) |

---

## I0 — Pre-install checks

| Condition | Action |
|-----------|--------|
| Target parent dir does not exist | **Block**: report missing path |
| Destination exists and is not a dir | **Block**: report conflict |
| Destination already has `.ai.ui` | Report existing; re-copy in copy mode, skip in submodule mode |
| No git remote in source (submodule mode) | **Block**: suggest copy mode instead |

---

## I1 — Copy mode

1. `bash .ai.ui/scripts/install-target.sh copy "<resolved-path>"`
2. Copies only **git-tracked files** (respects `.gitignore` automatically).
3. Additionally excludes: `.git/`, `.github/`, `.gitignore`, `.cursorrules`, `scripts/install-target.sh`.
4. Re-copies on re-run (idempotent overwrite).

**When to use:** Target project is not a git repo, or you want a standalone copy without git submodule overhead.

---

## I2 — Submodule mode

1. `bash .ai.ui/scripts/install-target.sh submodule "<resolved-path>"`
2. Requires git remote `origin` on source repo.
3. Adds submodule; user must commit `.gitmodules` in target.

**When to use:** Target project is a git repo and you want to track framework version via submodule.

---

## Completion

| # | Check | Result |
|---|-------|--------|
| 1 | Destination `.ai.ui/` exists | |
| 2 | `.git/` excluded (copy) or submodule registered (submodule) | |
| 3 | User informed of next steps | |

## Next commands

```text
@ui-bootstrap init merge-cursorrules   # in the target project
@ui-project-approach - <describe project>
```
