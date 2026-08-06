---
name: ui-deploy-files
description: >-
  Deploy .ai.ui (UI Design OS) files into a target project. Two directions:
  (1) in-place bootstrap — invoked from a TARGET project, copies the source
  .ai.ui in without overwriting existing files, then scaffolds .work.ui/ +
  .cursorrules; (2) outbound copy — invoked from the source .ai.ui repo,
  copies into an explicit <path>. `update` mode additionally performs a
  rules-aware merge of existing-but-differing files (append new rules, update
  shared sections, preserve target customizations + REPLACE: tokens; never
  wholesale-replace). Copies only git-tracked / non-ignored files (anything in
  .gitignore is never copied). Use ui-deploy-files (default), ui-deploy-files update,
  ui-deploy-files copy - <path>, ui-deploy-files status.
---

# ui-deploy-files

Two-direction deploy of the `.ai.ui` framework into a target project so the project can use UI Design OS skills. **Default = no-overwrite**: existing target files are preserved by construction.

**Shell:** `bash <source>/.ai.ui/scripts/ui-deploy-files.sh <target-path> [--force|--update]`
**Scaffold shell:** `REPO_ROOT=<target> AI_UI_ROOT=<source> bash <source>/.ai.ui/templates/bootstrap.sh`

**Canonical path:** `.ai.ui/skills/ui-deploy-files/skill.md` · **Shell:** `.ai.ui/scripts/ui-deploy-files.sh`

**Security invariant:** The script enumerates files via `git ls-files --cached --others --exclude-standard` from the **source** `.ai.ui` repo root, so anything `.gitignore` excludes is never copied — enforced by construction, not a hand-maintained list. The source must be a git repo with `.ai.ui/` as its root.

**Source not modified.** ui-deploy-files only writes to the **target**. The source `.ai.ui` is read-only.

**No local `opencode.json`.** When co-installed with Agent OS, register skills via parent `.ai/opencode.json`.

**Contrast with `ui-deploy-repo`:** `ui-deploy-files` copies only the `.ai.ui/` directory (no VCS artifacts). Use `@ui-deploy-repo clone` when you need the full repo including `.git` and `.github/`.

---

## Parse invocation

| User says | Direction | Mode |
|-----------|-----------|------|
| `@ui-deploy-files` | in-place (cwd is target) | copy no-overwrite + scaffold no-overwrite |
| `@ui-deploy-files update` | in-place | copy no-overwrite + scaffold no-overwrite + **rules-aware merge** |
| `@ui-deploy-files copy - /path/to/repo` | outbound (source = this repo) | copy no-overwrite to `/path/to/repo/.ai.ui` |
| `@ui-deploy-files copy - /path/to/repo --force` | outbound | copy with idempotent overwrite of existing files (legacy) |
| `@ui-deploy-files status` | report | report whether `.ai.ui/` exists at known deploy locations |

**Default:** `status` if no verb matches; if invoked bare with no `.ai.ui/` in cwd → in-place bootstrap.

**Aliases:** `bootstrap`, `in-place` → bare `@ui-deploy-files`.

Path auto-resolution: if the path ends in `.ai.ui` it is used as-is; otherwise `.ai.ui` is appended inside the path.

---

## I0 — Pre-checks (both directions)

| Condition | Action |
|-----------|--------|
| Source is not a git repo, or `.ai.ui/` is not the git root | **Block**: report; ui-deploy-files relies on `git ls-files` as the authority |
| Target parent dir does not exist | **Block**: report missing path |
| Destination exists and is not a dir | **Block**: report conflict |
| Destination already has `.ai.ui/` | Proceed with **no-overwrite**; report skipped count (default) |
| `--force` requested and destination populated | Warn that target customizations will be overwritten; require explicit `--force` in the same invocation |

### Source resolution (in-place direction)

When invoked from a **target** project (cwd has no `.ai.ui/scripts/ui-deploy-files.sh`):

1. **Auto:** if the script can be located at a known source path (user named it, or `AI_UI_ROOT` / `AI_SOURCE` env), use it.
2. **Ask once:** if source is unknown, ask the user for the source `.ai.ui` path. Do not guess.
3. Source determined → run from the **target** directory:
   ```bash
   cd <target> && bash <source>/scripts/ui-deploy-files.sh . [--update|--force]
   ```

---

## I1 — Copy mode (no-overwrite by default)

1. `bash <source>/.ai.ui/scripts/ui-deploy-files.sh "<resolved-target>"` (default) — or `--force` / `--update`.
2. **File set:** `git ls-files --cached --others --exclude-standard` from the source repo root.
3. **Skill-level omissions:** `.github/`, `.gitignore`, `.gitattributes`, `.cursorrules`, `scripts/ui-deploy-files.sh`, `scripts/ui-deploy-basic.sh`, `scripts/ui-deploy-repo.sh`.
4. **No-overwrite default:** `rsync --ignore-existing` skips any file already present in the target. `--force` drops that flag (legacy overwrite; still no `--delete`). `--update` keeps no-overwrite and emits the **merge candidate list** for § I3.

---

## I2 — Scaffold (in-place direction only)

When invoked in-place (bare `@ui-deploy-files` or `@ui-deploy-files update`), after the copy pass the script chains bootstrap **into the target** (no-overwrite — `copy_if_missing`):

```bash
REPO_ROOT=<target> AI_UI_ROOT=<source> bash <source>/templates/bootstrap.sh
```

Creates `.work.ui/`, `DOCS_UI_STACK.md`, and `.cursorrules` (or merge hint if `.cursorrules` already exists).

**Outbound `copy - <path>` does NOT scaffold** — leaves next-step instructions for `@ui-bootstrap init merge-cursorrules`.

---

## I3 — update-merge protocol (`@ui-deploy-files update` only)

After I1 (no-overwrite copy) the script prints a **merge candidate list** for differing files under `.ai.ui/`. The **agent** performs rules-aware merge for each candidate.

| Class | Merge rule |
|-------|------------|
| Skills | Append new sections/rules absent in target; update shared sections; never drop target-only verbs/tables |
| Standards | Append new sections; update shared text; preserve dated overrides |
| Framework docs | Append new sections; update shared paragraphs; preserve target examples |
| Templates | Prefer source version; if target edited intentionally, keep target + record |
| Scripts | Prefer source version (mechanical); overwrite → record in report |

**Preserve invariants:** target `REPLACE:` tokens, target-only skill folders, target table rows, date-stamped filenames.

---

## Completion

| # | Check | Result |
|---|-------|--------|
| 1 | Source repo is a git repo with `.ai.ui/` as root | pass |
| 2 | Destination `.ai.ui/` exists after copy | |
| 3 | No `.gitignored` content in destination | |
| 4 | `.github/` excluded from destination | |
| 5 | `.cursorrules` excluded from copy (created by scaffold or `@ui-bootstrap init`) | |
| 6 | No-overwrite honored | |
| 7 | Scaffold ran into target (in-place only) | |
| 8 | `update`: merge candidate list processed | |

## Next commands (in target project)

```text
@session-control start
@ui-project-approach - <describe project>
@ui-design-foundation greenfield
```

(In-place `@ui-deploy-files` already scaffolded `.work.ui/` + `.cursorrules`; outbound needs `@ui-bootstrap init`.)
