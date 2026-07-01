---
name: deploy-basic
description: >-
  Thin-client bootstrap of UI Design OS into a target project. Copies ONLY the
  minimal scaffold — .cursorrules (with AI_UI_SOURCE pointer to the source
  .ai.ui), .work.ui/ skeleton, DOCS_UI_STACK.md. UI framework assets (skills,
  standards, concepts, docs, scripts) are NOT copied; the agent resolves them
  from the source AI_UI_SOURCE at runtime. Use deploy-basic (default),
  deploy-basic update, deploy-basic status, or deploy-basic - <target-path>
  (outbound from source). Never modifies the source UI Design OS.
  Contrast with deploy-files (full fat-client copy of .ai.ui/).
---

# deploy-basic (UI Design OS)

Thin-client deploy of the `.ai.ui` framework. The target project receives only the scaffold it owns (`.cursorrules`, `.work.ui/`, `DOCS_UI_STACK.md`); everything else (skills, standards, concepts, docs, scripts, templates) stays in the **source** `.ai.ui` and is loaded on demand via the `AI_UI_SOURCE` pointer written into `.cursorrules`.

**Shell:** `bash <source>/.ai.ui/scripts/deploy-basic.sh <target-path> [mode]`

**Canonical path:** `.ai.ui/skills/deploy-basic/skill.md` · **Shell:** `.ai.ui/scripts/deploy-basic.sh`

**Source not modified.** deploy-basic only writes to the **target**. The source `.ai.ui` is read-only.

**Contrast with `deploy-files`:** `deploy-files` = **fat-client** (vendored full `.ai.ui/` into target, skills are local). `deploy-basic` = **thin-client** (skills remote in source). Choose:
- `deploy-files` — you want skills/standards/concepts versioned inside the project, offline-editable, no external dependency.
- `deploy-basic` — you want the project to track the live source UI Design OS, share one source of truth across many consumer repos, and accept new skills/standards automatically by updating the source (no per-project re-deploy).

---

## Parse invocation

| User says | Direction | Mode |
|-----------|-----------|------|
| `@deploy-basic - /path/to/target` | outbound (invoked from source .ai.ui) | thin bootstrap no-overwrite |
| `@deploy-basic` (from target, post-bootstrap) | in-place | re-runs no-overwrite bootstrap + source-pointer sync |
| `@deploy-basic update` (from target) | in-place | no-overwrite + re-sync source pointer + agent rules-aware merge of differing local-surface files |
| `@deploy-basic status` | report | read-only: shows `.cursorrules` presence, `AI_UI_SOURCE` value + reachability, `.work.ui/` presence, whether local `.ai.ui/skills` exists (fat-client leak check) |

**Default:** `status` if no verb matches. **Aliases:** `bootstrap-thin`, `thin-ui` → bare `@deploy-basic`.

**Target path is REQUIRED when invoked from the source UI Design OS dir (Scenario #2 / outbound).** The shell aborts with a usage message if no `<target-path>` is supplied; the agent must prompt the user for it rather than guessing. When invoked in-place (target is cwd), the path is implicit (`.`) and no argument is needed.

---

## What gets copied (the local surface)

| Path | Source | If target exists |
|------|--------|-------------------|
| `.cursorrules` | `templates/cursorrules.ui.template` with `AI_UI_SOURCE=<source>` substituted and source-resolution section appended | skip (preserve); `--force` overwrites |
| `.work.ui/README.md`, `context/HANDOFF_UI.md`, `plans/NEXT_UI.md`, `plans/ASSUMPTIONS.md`, `plans/RISK_REGISTRY.md`, `plans/UNKNOWNS.md`, `screens/README.md`, `decisions/README.md`, `prompts/README.md`, `design-system/CATALOG.md` | `templates/work.ui/*.template` (suffix stripped) | skip (preserve) |
| `.work.ui/plans/{foundation,full}/.gitkeep` | created empty | skip (preserve) |
| `DOCS_UI_STACK.md` | `templates/DOCS_UI_STACK.md.template` | skip (preserve) |

**Explicitly NOT copied (stay in source, loaded at runtime):** `skills/**`, `standards/**`, `concepts/**`, `docs/**`, `scripts/**`, `templates/**`, root `README.md`, `START_HERE.md`, `COHABITATION.md`, `.github/`, `.gitignore`.

---

## I0 — Pre-checks

| Condition | Action |
|-----------|--------|
| Source `templates/cursorrules.ui.template` missing | **Block**: source is not a valid `.ai.ui` framework root |
| Target dir does not exist | **Block**: report missing path |
| Target already has local `.ai.ui/skills/` | **Warn** fat-client leak: target was previously bootstrapped fat; thin-client would duplicate. Ask user to confirm intent (proceed leaves the local `.ai.ui/` in place — deploy-basic does not delete it). |
| Target `.cursorrules` exists + lacks `AI_UI_SOURCE=` line | In `update` mode → flag as **MERGE CANDIDATE** (the Source-resolution section is missing); in default mode → skip (preserve) and report that source-resolution is not wired. |

---

## I1 — Bootstrap protocol

1. Resolve source `AI_UI_ROOT` (explicit `AI_UI_ROOT` env, else script's parent). Validate `templates/cursorrules.ui.template` exists.
2. Resolve target = `REPO_ROOT` of the consumer (cwd for in-place, or the named path for outbound).
3. Write `.cursorrules` into the target from the template, substituting `AI_UI_SOURCE=REPLACE_BASICUI_SOURCE` → `AI_UI_SOURCE=<absolute AI_UI_ROOT>`. **No-overwrite** if `.cursorrules` exists; `--force` overwrites. If the template lacks a source-resolution section, append it.
4. **Resolve sister frameworks** at bootstrap time: discover `.ai`, `.ai.biz`, `.ai.soc` from `$AI_UI_ROOT/..` (sister frameworks sit alongside the source `.ai.ui` on disk). For each sister framework whose directory exists and `skills/README.md` is readable, fill its `REPLACE:` token with the absolute path. Frameworks not present stay as `REPLACE:` tokens for user fill-in. This prevents the thin-client auto-discovery gap where `$REPO_ROOT/.ai.ui/..` fails because the target has no local `.ai.ui/`.
5. Run the `.work.ui/` + `DOCS_UI_STACK.md` scaffold via `REPO_ROOT=<target> AI_UI_ROOT=<source> bash <source>/templates/bootstrap.sh` (bootstrap's `copy_if_missing` enforces no-overwrite).
6. Report: source pointer value, `.work.ui/` presence, fat-client leak check, resolved sister frameworks, next steps.

**Idempotent re-run.** Safe to re-run; no-overwrite preserves target customizations. The source pointer is re-synced only in `update` mode (or `--force`).

---

## I2 — update-merge protocol (`@deploy-basic update` only)

After I1 (no-overwrite) the script:

1. **Re-syncs the source pointer** if the target `.cursorrules` carries a stale `AI_UI_SOURCE` value (e.g. source moved). Performed in-place on the assignment line only — preserves all other target edits.
2. **Lists merge candidates** among the local surface: existing-but-differing files vs the current source templates (substituted). Candidates:
   - `.cursorrules` (differs from current `template-with-source`)
   - `.work.ui/<file>` (target has user content; templates are skeletons)
   - `DOCS_UI_STACK.md` (preserve target stack pins)
3. The **agent** then performs a rules-aware merge per candidate (this is agent work, not script work).

### Merge rules per file class

| Class | Merge rule |
|-------|------------|
| `.cursorrules` | Update framework sections (UI Skills table, Core principles, **Source resolution** section, Placeholder map). Preserve target-filled `REPLACE:` tokens, target customizations, and target-specific protected-file paths. If target lacks the Source-resolution section entirely (fat-client template) → append it with the current `AI_UI_SOURCE`. Never wholesale-replace. |
| `.work.ui/<file>` skeletons | Append new template sections absent in target; **preserve all user content** (HANDOFF_UI rows, NEXT_UI iteration blocks, UNKNOWNS entries). Never drop target rows. |
| `.work.ui/<dir>/.gitkeep` + new scaffold dirs | Create any NEW scaffold dir that didn't exist; do not touch existing. |
| `DOCS_UI_STACK.md` | Preserve target stack pins; append new template-only sections if any. Never replace user values. |

### Preserve invariants (never drop)
- Target's filled `REPLACE:` tokens (the merge keeps target values, not source `REPLACE:*` placeholders).
- Target's `AI_UI_SOURCE` line, in-place value (synced, not reset to `REPLACE_BASICUI_SOURCE`).
- Target's date-stamped filenames, custom skills, and any `.work.ui/` content the user/session-control produced.
- Target's git history, `.gitignore`, app code — all untouched.

---

## I3 — status (read-only)

Reports:

| Check | Output |
|-------|--------|
| `.cursorrules` present | pass / missing |
| `AI_UI_SOURCE` value + reachable | value + `test -d` result |
| Source-resolution section present | pass / missing |
| `.work.ui/` present | pass / missing (list present skeleton files) |
| Local `.ai.ui/skills/` exists (fat-client leak) | no (good, thin) / yes (warn — mixed) |
| `REPLACE:` tokens remaining in `.cursorrules` | count (excludes `AI_UI_SOURCE` which is filled) |

---

## Completion

| # | Check | Result |
|---|-------|--------|
| 1 | Source `templates/cursorrules.ui.template` readable | pass |
| 2 | Target `.cursorrules` exists with valid `AI_UI_SOURCE` (resolves to a dir) | |
| 3 | Source-resolution section present in target `.cursorrules` | |
| 4 | `.work.ui/` skeleton present (HANDOFF_UI, NEXT_UI, UNKNOWNS at minimum) | |
| 5 | No-overwrite honored (existing target files preserved; `--force` only when explicitly requested) | |
| 6 | `update`: source pointer re-synced if stale; merge candidate list produced; no wholesale replaces | |
| 7 | Fat-client leak checked (no unexpected local `.ai.ui/skills/`) | |
| 8 | User informed that skills load from `$AI_UI_SOURCE` at runtime + next steps | |

## Next commands (in target project)

```text
# Verify the source is reachable from the target's perspective:
test -d "$(grep -oE 'AI_UI_SOURCE=[^ ]*' .cursorrules | head -1 | cut -d= -f2-)"

# Fill remaining REPLACE tokens in .cursorrules (NOT AI_UI_SOURCE — deploy-basic set it):
#   rg 'REPLACE:' .cursorrules

# First skill invocation — loads from source:
@session-control start
```

---

## Critical interactions

| When | Ask / do |
|------|----------|
| Invoked from target with no source pointer yet (greenfield, no `.cursorrules`) | The skill itself can't be loaded in thin-client mode before bootstrap. Tell the user to run the shell directly: `bash /abs/path/to/source/.ai.ui/scripts/deploy-basic.sh .` — chicken-and-egg escape. |
| Bootstrap target already has `.ai.ui/skills/` (fat-client) | Warn; ask: convert to thin (delete local `.ai.ui/`)?, keep mixed (skills resolve local-first per fat-client rule — unexpected)?, or abort? Do not silently leave a mixed state. |
| `update` finds `.cursorrules` with no `AI_UI_SOURCE` line | Fat-client template detected → flag as merge candidate; agent appends the Source-resolution section with current source value. |
| Source moved since last bootstrap | `update` re-syncs the pointer in-place; report old→new. If source unreachable, report `ui-design-os source unreachable` and stop. |

---

## Anti-patterns

- Copying `skills/`/`standards/`/`concepts/` into the target (that defeats thin-client; use `@deploy-files` instead).
- Wholesale-replacing `.cursorrules` or `.work.ui/HANDOFF_UI.md` on `update`.
- Resetting `AI_UI_SOURCE` to `REPLACE_BASICUI_SOURCE` instead of the resolved path.
- Running `@deploy-basic` and expecting skills to work offline — thin-client requires the source path to remain reachable.
- Failing to verify `$AI_UI_SOURCE` is readable before claiming bootstrap complete.
- Invoking `@deploy-basic -` from the source dir **without** a target path — the shell aborts; the agent must prompt for the target rather than guessing or defaulting to the source's own cwd.
- Using `deploy-basic` to "upgrade" a fat-client repo without first removing the local `.ai.ui/` (creates a mixed state; skills resolve fat-client first).
