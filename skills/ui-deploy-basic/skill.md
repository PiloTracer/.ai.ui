---
name: ui-deploy-basic
description: >-
  Thin-client bootstrap of UI Design OS into a target project. Copies ONLY the
  minimal scaffold — .cursorrules (with AI_UI_SOURCE pointer to the source
  .ai.ui), .work.ui/ skeleton, DOCS_UI_STACK.md. UI framework assets (skills,
  standards, concepts, docs, scripts) are NOT copied; the agent resolves them
  from the source AI_UI_SOURCE at runtime. Verbs work with or without "--"
  (update == --update). Use ui-deploy-basic (default), ui-deploy-basic update,
  ui-deploy-basic verify [--fix], ui-deploy-basic status, or
  ui-deploy-basic - <target-path> (outbound from source). Never modifies the
  source UI Design OS. Contrast with ui-deploy-files (full fat-client copy
  of .ai.ui/).
---

# ui-deploy-basic (UI Design OS)

Thin-client deploy of the `.ai.ui` framework. The target project receives only the scaffold it owns (`.cursorrules`, `.work.ui/`, `DOCS_UI_STACK.md`); everything else (skills, standards, concepts, docs, scripts, templates) stays in the **source** `.ai.ui` and is loaded on demand via the `AI_UI_SOURCE` pointer written into `.cursorrules`.

**Shell:** `bash <source>/.ai.ui/scripts/ui-deploy-basic.sh <target-path> [mode]`

**Canonical path:** `.ai.ui/skills/ui-deploy-basic/skill.md` · **Shell:** `.ai.ui/scripts/ui-deploy-basic.sh` · **Verifier:** `.ai.ui/scripts/cursorrules-verify.sh`

**Source not modified.** ui-deploy-basic only writes to the **target**. The source `.ai.ui` is read-only.

**Contrast with `ui-deploy-files`:** `ui-deploy-files` = **fat-client** (vendored full `.ai.ui/` into target, skills are local). `ui-deploy-basic` = **thin-client** (skills remote in source). Choose:
- `ui-deploy-files` — you want skills/standards/concepts versioned inside the project, offline-editable, no external dependency.
- `ui-deploy-basic` — you want the project to track the live source UI Design OS, share one source of truth across many consumer repos, and accept new skills/standards automatically by updating the source (no per-project re-deploy).

---

## Parse invocation

**Flag equivalence (hard rule):** verbs work **with or without** the `--` prefix, in any position relative to the target path. `@ui-deploy-basic /path update`, `@ui-deploy-basic /path --update`, and `@ui-deploy-basic --update /path` are **identical**. The agent-syntax separator `-` between verb and path is ignored.

| User says | Direction | Mode |
|-----------|-----------|------|
| `@ui-deploy-basic - /path/to/target` | outbound (invoked from source .ai.ui) | thin bootstrap no-overwrite |
| `@ui-deploy-basic` (from target, post-bootstrap) | in-place | re-runs no-overwrite bootstrap + wiring audit report |
| `@ui-deploy-basic update` (from target) | in-place | no-overwrite + self-heal `.cursorrules` (re-sync pointer, append Source-resolution if missing) + wiring audit + merge-candidate list |
| `@ui-deploy-basic verify` | audit | strict `.cursorrules` wiring audit (exit 1 on blocking gap): pointer reachability, Source-resolution section, sister framework paths, `.work.ui/` |
| `@ui-deploy-basic verify --fix` | audit+fix | as `verify`, plus fills machine-fixable gaps: pins `REPLACE:AGENT_OS_PATH` / `REPLACE:AI_BIZ_PATH` / `REPLACE:AI_SOC_PATH` from on-disk discovery, appends missing Source-resolution section |
| `@ui-deploy-basic status` | report | read-only (always exit 0): same checks as `verify` in report form |

**Default:** `status` if no verb matches. **Aliases:** `bootstrap-thin`, `thin-ui` → bare `@ui-deploy-basic`.

**Target path is REQUIRED when invoked from the source UI Design OS dir (Scenario #2 / outbound).** When omitted, the shell falls back to cwd (`.`) — correct for in-place invocation, wrong for outbound. The agent must prompt the user for the target rather than guessing.

---

## What gets copied (the local surface)

| Path | Source | If target exists |
|------|--------|-------------------|
| `.cursorrules` | `templates/cursorrules.ui.template` with `AI_UI_SOURCE=<source>` substituted and source-resolution section appended | skip (preserve); `force` overwrites |
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
| Target resolves to the source framework itself | **Block**: refusing to deploy the source into itself |
| Target already has local `.ai.ui/skills/` | **Block** fat-client leak (use `force` to override, or remove local `.ai.ui/` first) |
| Target `.cursorrules` exists + lacks the Source-resolution section | In `update` mode → **auto-appended** by the script (thin-client wiring); in default mode → skip (preserve) and report that source-resolution is not wired |

---

## I1 — Bootstrap protocol

1. Resolve source `AI_UI_ROOT` (explicit `AI_UI_ROOT` env, else script's parent). Validate `templates/cursorrules.ui.template` exists.
2. Resolve target = `REPO_ROOT` of the consumer (cwd for in-place, or the named path for outbound).
3. Write `.cursorrules` into the target from the template, substituting `AI_UI_SOURCE=REPLACE_BASICUI_SOURCE` → `AI_UI_SOURCE=<absolute AI_UI_ROOT>`. **No-overwrite** if `.cursorrules` exists; `force` overwrites. If the template lacks a source-resolution section, append it.
4. Run the `.work.ui/` + `DOCS_UI_STACK.md` scaffold via `REPO_ROOT=<target> AI_UI_ROOT=<source> bash <source>/templates/bootstrap.sh` (bootstrap's `copy_if_missing` enforces no-overwrite).
5. Run the **wiring audit** (`scripts/cursorrules-verify.sh --report`) so every deploy ends with evidence of the target's `.cursorrules` state.
6. Report: source pointer value, `.work.ui/` presence, fat-client leak check, next steps.

**No local `opencode.json`.** UI Design OS does not ship or sync `opencode.json` in consumer repos. When co-installed with Agent OS, register skills via the parent `.ai/opencode.json` (or your host's coding-agent config).

**Idempotent re-run.** Safe to re-run; no-overwrite preserves target customizations. The source pointer is re-synced only in `update` mode (or `force`).

---

## I2 — update-merge protocol (`@ui-deploy-basic update` only)

After I1 (no-overwrite) the script **self-heals** the target `.cursorrules`, then lists remaining merge candidates:

1. **Appends the Source-resolution section** if the existing `.cursorrules` lacks it entirely (e.g. Agent OS base rules or a fat-client template) — extracted from the current template with `AI_UI_SOURCE=<source>` substituted. Append-only: no target content is touched.
2. **Re-syncs the source pointer** if the target `.cursorrules` carries a stale `AI_UI_SOURCE` value (e.g. source moved). Performed in-place on the assignment line(s) only — preserves all other target edits.
3. **Lists merge candidates** among the local surface: existing-but-differing files vs the current source templates (substituted). Candidates:
   - `.cursorrules` (differs from current `template-with-source`)
   - `.work.ui/<file>` (target has user content; templates are skeletons)
   - `DOCS_UI_STACK.md` (preserve target stack pins)
4. The **agent** then performs a rules-aware merge per candidate (this is agent work, not script work).

### Merge rules per file class

| Class | Merge rule |
|-------|------------|
| `.cursorrules` | Update framework sections (UI Skills table, Core principles, **Source resolution** section, Placeholder map). Preserve target-filled `REPLACE:` tokens, target customizations, and target-specific protected-file paths. Never wholesale-replace. |
| `.work.ui/<file>` skeletons | Append new template sections absent in target; **preserve all user content** (HANDOFF_UI rows, NEXT_UI iteration blocks, UNKNOWNS entries). Never drop target rows. |
| `.work.ui/<dir>/.gitkeep` + new scaffold dirs | Create any NEW scaffold dir that didn't exist; do not touch existing. |
| `DOCS_UI_STACK.md` | Preserve target stack pins; append new template-only sections if any. Never replace user values. |

### Preserve invariants (never drop)
- Target's filled `REPLACE:` tokens (the merge keeps target values, not source `REPLACE:*` placeholders).
- Target's `AI_UI_SOURCE` line, in-place value (synced, not reset to `REPLACE_BASICUI_SOURCE`).
- Target's date-stamped filenames, custom skills, and any `.work.ui/` content the user/session-control produced.
- Target's git history, `.gitignore`, app code — all untouched.

---

## I3 — status / verify (`.cursorrules` wiring audit)

Both delegate to `scripts/cursorrules-verify.sh`; `status` is report-only (always exit 0), `verify` is strict (exit 1 on blocking gap), `verify --fix` additionally repairs machine-fixable gaps.

| Check | Pass condition |
|-------|----------------|
| `.cursorrules` present | file exists at target root |
| UI Design OS rules present | `UI_DESIGN_OS_BEGIN` block or standalone template markers |
| Client mode | thin (`AI_UI_SOURCE` set) / fat (local `.ai.ui/`) / framework-root — each validated |
| `AI_UI_SOURCE` value + assets | resolves to a dir containing `skills/README.md` |
| Source-resolution section present | `## Source resolution` heading (`--fix` appends from template) |
| Sister framework paths | `REPLACE:AGENT_OS_PATH` / `REPLACE:AI_BIZ_PATH` / `REPLACE:AI_SOC_PATH` filled, or sister dir (`.ai`, `.ai.biz`, `.ai.soc`) discoverable next to the framework (`--fix` pins them); configured values must resolve to a dir with `skills/README.md` |
| `.work.ui/` present | `.work.ui/context/` exists (warning only) |
| Fat-client leak | no local `.ai.ui/skills/` in thin mode (warning) |
| `REPLACE:` tokens remaining | reported as inventory — operator-filled `REPLACE:UI_*` pins are **not** a failure |

---

## Completion

| # | Check | Result |
|---|-------|--------|
| 1 | Source `templates/cursorrules.ui.template` readable | pass |
| 2 | Target `.cursorrules` exists with valid `AI_UI_SOURCE` (resolves to a dir with `skills/README.md`) | |
| 3 | Source-resolution section present in target `.cursorrules` | |
| 4 | Sister framework paths resolvable (pinned or auto-discovered) | |
| 5 | `.work.ui/` skeleton present (HANDOFF_UI, NEXT_UI, UNKNOWNS at minimum) | |
| 6 | No-overwrite honored (existing target files preserved; `force` only when explicitly requested) | |
| 7 | `update`: pointer re-synced if stale; Source-resolution appended if missing; merge candidate list produced; no wholesale replaces | |
| 8 | `verify` exits 0 (or gaps reported; `verify --fix` applied where offered) | |
| 9 | Fat-client leak checked (no unexpected local `.ai.ui/skills/`) | |
| 10 | User informed that skills load from `$AI_UI_SOURCE` at runtime + next steps | |

## Next commands (in target project)

```text
# Strict wiring audit (exit 1 on blocking gap; add --fix to auto-fill):
bash "$AI_UI_SOURCE/scripts/cursorrules-verify.sh" .

# Verify the source is reachable from the target's perspective:
test -d "$(grep -oE 'AI_UI_SOURCE=[^ ]*' .cursorrules | head -1 | cut -d= -f2-)"

# Fill remaining REPLACE tokens in .cursorrules (NOT AI_UI_SOURCE — ui-deploy-basic set it):
#   rg 'REPLACE:' .cursorrules

# First skill invocation — loads from source:
@session-control start
```

---

## Critical interactions

| When | Ask / do |
|------|----------|
| Invoked from target with no source pointer yet (greenfield, no `.cursorrules`) | The skill itself can't be loaded in thin-client mode before bootstrap. Tell the user to run the shell directly: `bash /abs/path/to/source/.ai.ui/scripts/ui-deploy-basic.sh .` — chicken-and-egg escape. |
| Bootstrap target already has `.ai.ui/skills/` (fat-client) | Warn; ask: convert to thin (delete local `.ai.ui/`)?, keep mixed (skills resolve local-first per fat-client rule — unexpected)?, or abort? Do not silently leave a mixed state. |
| `update` finds `.cursorrules` with no Source-resolution section | The script appends it automatically (thin-client wiring) — no agent action needed; verify in the post-update audit output. |
| Source moved since last bootstrap | `update` re-syncs the pointer in-place; report old→new. If source unreachable, report `ui-design-os source unreachable` and stop. |

---

## Anti-patterns

- Copying `skills/`/`standards/`/`concepts/` into the target (that defeats thin-client; use `@ui-deploy-files` instead).
- Wholesale-replacing `.cursorrules` or `.work.ui/HANDOFF_UI.md` on `update`.
- Resetting `AI_UI_SOURCE` to `REPLACE_BASICUI_SOURCE` instead of the resolved path.
- Running `@ui-deploy-basic` and expecting skills to work offline — thin-client requires the source path to remain reachable.
- Failing to verify `$AI_UI_SOURCE` is readable before claiming bootstrap complete — run `verify` (strict), not just a visual scan of the report.
- Invoking `@ui-deploy-basic -` from the source dir **without** a target path — the shell falls back to cwd, which is the **source itself** and is blocked by the self-deploy guard; the agent must prompt for the target rather than guessing or defaulting to the source's own cwd.
- Using `ui-deploy-basic` to "upgrade" a fat-client repo without first removing the local `.ai.ui/` (creates a mixed state; skills resolve fat-client first).
