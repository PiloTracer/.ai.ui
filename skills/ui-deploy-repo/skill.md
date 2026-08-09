---
name: ui-deploy-repo
description: >-
  Full git-based deploy of UI Design OS into a target directory. Two modes:
  clone (git clone with full history via origin remote) or archive (git archive
  extract including .github, .gitignore, .cursorrules). Use clone for a full git
  mirror; use archive when no remote is available or when updating an existing
  target. Verbs work with or without "--" (clone == --clone,
  archive == --archive). ui-deploy-repo clone - <path>,
  ui-deploy-repo archive - <path>, ui-deploy-repo verify <path> [--fix],
  ui-deploy-repo status.
---

# ui-deploy-repo

**Shell:** `bash .ai.ui/scripts/ui-deploy-repo.sh [status [path] | verify <path> [--fix] | <clone|archive> <target-path>]`

Deploys the entire `.ai.ui` UI Design OS repository (including `.git/`, `.github/`, `.gitignore`, and root `.cursorrules`) into a target directory. Two modes cover both git-mirror and snapshot deployments.

**Canonical path:** `.ai.ui/skills/ui-deploy-repo/skill.md` · **Shell:** `.ai.ui/scripts/ui-deploy-repo.sh` · **Verifier:** `.ai.ui/scripts/cursorrules-verify.sh`

**Contrast with `ui-deploy-files`:** `ui-deploy-repo` includes VCS artifacts. Use `@ui-deploy-files copy` when you only need the `.ai.ui/` directory without git history or `.github/`.

---

## Parse invocation

**Flag equivalence (hard rule):** verbs work **with or without** the `--` prefix. `@ui-deploy-repo clone - /path` and `@ui-deploy-repo --clone /path` are **identical**. The agent-syntax separator `-` between verb and path is ignored.

| User says | Mode |
|-----------|------|
| `@ui-deploy-repo` **clone - /path/to/repo** | Full `git clone` from origin remote to target path |
| `@ui-deploy-repo` **archive - /path/to/repo** | `git archive HEAD \| tar xf` — full tree, no `.git` |
| `@ui-deploy-repo` **verify** - /path [--fix] | Strict `.cursorrules` wiring audit of the deployed target (exit 1 on blocking gap); `--fix` pins sister paths / appends Source-resolution |
| `@ui-deploy-repo` **status** | Report source remote, HEAD, optional target deploy state + wiring audit report |
| `@ui-deploy-repo` **status** - /path | Same with target path inspection |

**Shell (read-only):** `bash scripts/ui-deploy-repo.sh status [target-path]`

**Default:** usage error if no verb matches (deploy modes are destructive enough to require an explicit verb).

---

## I0 — Pre-checks

| Condition | Action |
|-----------|--------|
| Target parent dir does not exist | **Block**: report missing path |
| No git remote in source (clone mode) | **Block**: suggest `archive` mode instead |
| Target already has `.git` (clone mode) | Report existing; exit (clone requires fresh target) |
| Target exists as non-dir | **Block**: report conflict |

---

## I1 — Clone mode

1. `bash .ai.ui/scripts/ui-deploy-repo.sh clone "<resolved-path>"`
2. Requires git remote `origin` on source repo.
3. Target must not exist or must be empty.
4. Full `git clone` preserves all branches and tags.

**When to use:** You need the full repository with git history, CI/CD workflows (`.github/`), and version tracking in the target.

---

## I2 — Archive mode

1. `bash .ai.ui/scripts/ui-deploy-repo.sh archive "<resolved-path>"`
2. Uses `git archive HEAD` — no remote required.
3. Includes `.github/`, `.gitignore`, `.cursorrules` (everything except `.git` directory).
4. Idempotent — re-runs safely overwrite files.
5. Runs the **wiring audit** (`cursorrules-verify.sh --report`) after extraction so the deploy ends with evidence of the target's `.cursorrules` state.

**When to use:** No remote available, or target already exists and you want to update its `.ai.ui/` tree while keeping VCS artifacts (`.github/`, `.gitignore`, `.cursorrules`).

---

## I3 — status / verify (`.cursorrules` wiring audit)

`status` with a target path and the `archive` deploy both end in a report-only audit; `verify` runs the strict form (exit 1 on blocking gap) and `verify --fix` repairs machine-fixable gaps. All delegate to `scripts/cursorrules-verify.sh`. A full-repo deploy target is usually a **framework-root** checkout (the repo IS the framework), so the audit validates `skills/README.md` at the root and auto-discovers sister frameworks (`.ai`, `.ai.biz`, `.ai.soc`) next to the checkout.

---

## Completion

| # | Check | Clone | Archive |
|---|-------|-------|---------|
| 1 | Source repo has origin remote (or archive mode) | pass | pass |
| 2 | Target path exists and is populated | | |
| 3 | `.git/` present (clone) / `.github/` present (archive) | | |
| 4 | `.cursorrules` present at target root | | |
| 5 | `verify` exits 0 (or gaps reported; `verify --fix` applied where offered) | | |
| 6 | User informed of next steps | | |

## Next commands (in target project)

```text
# Strict wiring audit (exit 1 on blocking gap; add --fix to auto-fill):
bash scripts/cursorrules-verify.sh .

@ui-bootstrap init
@ui-project-approach - <describe project>
```
