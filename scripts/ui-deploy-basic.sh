#!/usr/bin/env bash
# ui-deploy-basic.sh — Thin-client bootstrap of UI Design OS into a target project.
#
# Copies ONLY the minimal scaffold into the target:
#   - .cursorrules (from templates/cursorrules.ui.template, with AI_UI_SOURCE
#     token substituted to the absolute path of THIS source .ai.ui, and
#     source-resolution section appended)
#   - .work.ui/ skeleton (HANDOFF_UI, NEXT_UI, UNKNOWNS, plans dirs, READMEs)
#   - DOCS_UI_STACK.md
#
# Framework assets (skills/, standards/, concepts/, docs/, scripts/, templates/)
# are NOT copied — the target's .cursorrules carries an AI_UI_SOURCE pointer so
# the agent resolves them from the source .ai.ui at runtime (thin-client mode).
#
# Default = NO-OVERWRITE: existing target files are preserved by construction.
# update: no-overwrite + re-syncs the source pointer + appends the Source-
#   resolution section when missing + lists existing-but-differing local-surface
#   files as merge candidates for agent rules-aware merge.
# force: idempotent overwrite of the local scaffold surface only.
# verify: strict audit of the target's .cursorrules wiring (via
#   scripts/cursorrules-verify.sh); verify --fix also fills machine-fixable
#   gaps (sister framework paths, missing Source-resolution section).
#
# Flag equivalence: verbs work WITH or WITHOUT the "--" prefix, in any
# position relative to the target path — these are identical:
#   bash scripts/ui-deploy-basic.sh /path/to/target update
#   bash scripts/ui-deploy-basic.sh /path/to/target --update
#   bash scripts/ui-deploy-basic.sh --update /path/to/target
# The agent-syntax separator "-" between verb and path is ignored.
#
# Source resolution: AI_UI_ROOT is derived from this script's location, so the
# script can be invoked from a TARGET using an external source .ai.ui:
#   bash /mnt/work/Projects/.ai.ui/scripts/ui-deploy-basic.sh /path/to/target-project
# Override the source with AI_UI_ROOT=/abs/path/.ai.ui if needed.
#
# Usage:
#   bash scripts/ui-deploy-basic.sh <target-path>              # no-overwrite (skip existing)
#   bash scripts/ui-deploy-basic.sh <target-path> status       # read-only report (always exit 0)
#   bash scripts/ui-deploy-basic.sh <target-path> verify [--fix] # strict .cursorrules audit
#   bash scripts/ui-deploy-basic.sh <target-path> update       # no-overwrite + self-heal + merge list
#   bash scripts/ui-deploy-basic.sh <target-path> force        # overwrite local scaffold (legacy)
#   AI_UI_ROOT=/path/.ai.ui bash scripts/ui-deploy-basic.sh <target-path>
#
set -euo pipefail

# ── Argument parsing (verb == --verb, any position; "-" ignored) ──────
MODE=""
FIX=0
RAW_TARGET=""
for a in "$@"; do
  case "$a" in
    status|--status) MODE="status" ;;
    verify|--verify) MODE="verify" ;;
    update|--update) MODE="update" ;;
    force|--force)   MODE="force" ;;
    --fix)           FIX=1 ;;
    -)               ;;  # agent-syntax separator
    --*)             echo "ERROR: unknown flag: $a" >&2; exit 1 ;;
    *)               if [[ -z "$RAW_TARGET" ]]; then RAW_TARGET="$a"; else echo "ERROR: unexpected argument: $a" >&2; exit 1; fi ;;
  esac
done
MODE="${MODE:-skip}"

# Source .ai.ui root: explicit override wins, else derive from script location.
if [[ -n "${AI_UI_ROOT:-}" ]]; then
  AI_UI_ROOT="$(cd "$AI_UI_ROOT" && pwd)"
else
  AI_UI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
VERIFY="${AI_UI_ROOT}/scripts/cursorrules-verify.sh"

# Target = repo root of the consumer (the dir that will hold .cursorrules + .work.ui/).
RAW_TARGET="${RAW_TARGET:-.}"
if [[ "$RAW_TARGET" == "." || "$RAW_TARGET" == "$PWD" ]]; then
  DEST_ROOT="$(pwd)"
else
  if [[ ! -d "$RAW_TARGET" ]]; then
    echo "ERROR: target directory does not exist: $RAW_TARGET" >&2
    exit 1
  fi
  DEST_ROOT="$(cd "$RAW_TARGET" && pwd)"
fi

# ── status / verify (read-only; verify --fix is the only mutation) ────
if [[ "$MODE" == "status" || "$MODE" == "verify" ]]; then
  echo "=== ui-deploy-basic ${MODE} → ${DEST_ROOT} ==="
  if [[ "$MODE" == "status" ]]; then
    bash "$VERIFY" "$DEST_ROOT" --report
  elif [[ "$FIX" -eq 1 ]]; then
    bash "$VERIFY" "$DEST_ROOT" --fix
  else
    bash "$VERIFY" "$DEST_ROOT"
  fi
  exit $?
fi

# ── Write modes below this point ──────────────────────────────────────

# Never deploy the source framework into itself.
if [[ "$DEST_ROOT" == "$AI_UI_ROOT" ]]; then
  echo "ERROR: target resolves to the source framework itself ($DEST_ROOT) — refusing to deploy into the source." >&2
  exit 1
fi

# .cursorrules template + .work.ui/ skeleton templates come from source.
TPL_CURS="${AI_UI_ROOT}/templates/cursorrules.ui.template"
if [[ ! -f "$TPL_CURS" ]]; then
  echo "ERROR: source .ai.ui missing templates/cursorrules.ui.template at $AI_UI_ROOT" >&2
  exit 1
fi

# Scaffold file set (the thin-client local surface).
CURS_DEST="${DEST_ROOT}/.cursorrules"
STACK_DEST="${DEST_ROOT}/DOCS_UI_STACK.md"
WORK_UI_FILES=(
  "README.md" "context/HANDOFF_UI.md" "plans/NEXT_UI.md" "plans/ASSUMPTIONS.md"
  "plans/RISK_REGISTRY.md" "plans/UNKNOWNS.md" "screens/README.md"
  "decisions/README.md" "prompts/README.md" "design-system/CATALOG.md"
)


echo "=== ui-deploy-basic (UI Design OS) → $DEST_ROOT (thin-client bootstrap) ==="
echo "  source: $AI_UI_ROOT"
echo "  mode:   $MODE (no-overwrite by default)"

if [[ -d "${DEST_ROOT}/.ai.ui/skills" ]]; then
  echo "  WARN: target has local .ai.ui/skills/ directory (fat-client leak)"
  if [[ "$MODE" != "force" ]]; then
    echo "  BLOCKED: use force to confirm thin-client on a fat-client target,"
    echo "    or remove the local .ai.ui/ directory first."
    exit 1
  fi
  echo "  force: proceeding (mixed state accepted by operator)"
fi

AI_UI_ROOT_ESC="${AI_UI_ROOT//\//\\/}"

# Build the substituted .cursorrules content (AI_UI_SOURCE → absolute source path).
# Also appends the source-resolution section if the template doesn't already have it.
subst_cursorules() {
  local tmp
  tmp="$(mktemp)"
  # Substitute AI_UI_SOURCE token
  perl -pe "s/AI_UI_SOURCE=REPLACE_BASICUI_SOURCE/AI_UI_SOURCE=${AI_UI_ROOT_ESC}/" "$TPL_CURS" > "$tmp"
  # Append source-resolution section if not already present
  if ! grep -q '## Source resolution' "$tmp" 2>/dev/null; then
    cat >> "$tmp" << 'SRCEOF'

## Source resolution — fat-client vs thin-client (UI Design OS)

This repo was bootstrapped in one of two modes. The agent MUST apply the matching resolution rule before reading any `.ai.ui` path.

AI_UI_SOURCE=REPLACE_BASICUI_SOURCE

*(If the line above still shows `REPLACE_BASICUI_SOURCE`, the repo is **fat-client** — see below.)*

| Mode | Bootstrapped via | Where framework assets live | `AI_UI_SOURCE` |
|------|------------------|----------------------------|----------------|
| **Fat-client** (vendored) | `@ui-bootstrap init` or `@ui-deploy-files` | this repo's `.ai.ui/` | unset (token left as `REPLACE_BASICUI_SOURCE`) |
| **Thin-client** (remote) | `@ui-deploy-basic` | the **source** UI Design OS; this repo holds only `.cursorrules` + `.work.ui/` | set to an absolute path (e.g. `/mnt/work/Projects/.ai.ui`) |

**Resolution rule (agents MUST apply before reading any `.ai.ui/...` reference):**

1. `.cursorrules` (this file) and `.work.ui/**` — read from the **local** project (this repo), always, in both modes.
2. **Thin-client** (`AI_UI_SOURCE` is set and readable as a directory): read every other `.ai.ui/<path>` reference from `$AI_UI_SOURCE/<path>` — i.e. `skills/<id>/skill.md`, `skills/README.md`, `standards/**`, `concepts/**`, `docs/**`, `scripts/**`, `templates/**`, `START_HERE.md`, `COHABITATION.md`. **Never** assume a local `.ai.ui/` exists. When you invoke `@<skill>`, read `$AI_UI_SOURCE/skills/<id>/skill.md`; inside it, any `.ai.ui/<x>` reference resolves to `$AI_UI_SOURCE/<x>`.
3. **Fat-client** (`AI_UI_SOURCE` is unset or still `REPLACE_BASICUI_SOURCE`): read `.ai.ui/<path>` locally in this repo.
4. `.work.ui/...` references and project app code resolve locally in this repo in both modes.
5. **Thin-client + unreachable source:** if `$AI_UI_SOURCE` is set but the directory does not exist or `skills/README.md` is unreadable, **stop** and report `ui-design-os source unreachable: $AI_UI_SOURCE` — do **not** silently fall back to a local `.ai.ui/` (there isn't one) and do **not** guess a different path.

**First bootstrap in thin-client mode** is a chicken-and-egg escape: before `@ui-deploy-basic` runs, the target has no local skill to invoke. Bootstrap is initiated either (a) from the **source** repo — `@ui-deploy-basic - /abs/path/to/target` — or (b) by invoking the shell directly from the target: `bash /abs/path/to/source/.ai.ui/scripts/ui-deploy-basic.sh .` After that, the source pointer in `.cursorrules` lets the local agent load `@ui-deploy-basic update` and every other UI skill from source.

SRCEOF
  fi
  cat "$tmp"
  rm -f "$tmp"
}

write_cursorules() {
  local force="$1"
  if [[ "$force" == "force" ]] || [[ ! -f "$CURS_DEST" ]]; then
    subst_cursorules > "$CURS_DEST"
    echo "  cursorules: wrote (subst AI_UI_SOURCE=$AI_UI_ROOT)"
  else
    echo "  cursorules: skip (exists) — keeping existing target .cursorrules"
  fi
}

# Pre-scan: detect whether target already has a thin-client pointer set.
existing_source=""
if [[ -f "$CURS_DEST" ]]; then
  existing_source="$(grep -oE 'AI_UI_SOURCE=[^ ]*' "$CURS_DEST" | head -1 | cut -d= -f2- || true)"
fi

# Step 1: .cursorrules (no-overwrite by default; force overwrites).
if [[ "$MODE" == "force" ]]; then
  write_cursorules force
else
  if [[ -f "$CURS_DEST" ]]; then
    echo "  cursorules: skip (exists) — keeping existing target .cursorrules"
  else
    write_cursorules skip
  fi
fi

# update self-heal #1: append the Source-resolution section when the existing
# .cursorrules lacks it entirely (e.g. fat-client template or Agent OS base).
if [[ "$MODE" == "update" ]] && [[ -f "$CURS_DEST" ]] && ! grep -q '^## Source resolution' "$CURS_DEST"; then
  {
    echo ""
    awk '/^## Source resolution/{f=1} f&&/^---$/{exit} f' "$TPL_CURS" \
      | perl -pe "s/AI_UI_SOURCE=REPLACE_BASICUI_SOURCE/AI_UI_SOURCE=${AI_UI_ROOT_ESC}/"
  } >> "$CURS_DEST"
  echo "  cursorules: appended Source-resolution section (thin-client wiring, AI_UI_SOURCE=$AI_UI_ROOT)"
fi

# update self-heal #2: re-sync the source pointer when the existing .cursorrules
# still carries REPLACE_BASICUI_SOURCE or a stale path.
existing_source="$(grep -oE 'AI_UI_SOURCE=[^ ]*' "$CURS_DEST" 2>/dev/null | head -1 | cut -d= -f2- || true)"
if [[ "$MODE" == "update" ]] && [[ -f "$CURS_DEST" ]] && grep -q 'AI_UI_SOURCE=' "$CURS_DEST" && [[ "$existing_source" != "$AI_UI_ROOT" ]]; then
  if [[ -n "$existing_source" ]]; then
    perl -i -pe "s{AI_UI_SOURCE=\Q${existing_source}\E}{AI_UI_SOURCE=${AI_UI_ROOT_ESC}}" "$CURS_DEST" 2>/dev/null || \
      perl -i -pe "s/AI_UI_SOURCE=[^\n]*/AI_UI_SOURCE=${AI_UI_ROOT_ESC}/" "$CURS_DEST"
    echo "  cursorules: re-synced AI_UI_SOURCE → $AI_UI_ROOT (was: ${existing_source})"
  else
    # Line exists but empty — replace it
    perl -i -pe "s/AI_UI_SOURCE=[^\n]*/AI_UI_SOURCE=${AI_UI_ROOT_ESC}/" "$CURS_DEST"
    echo "  cursorules: set AI_UI_SOURCE → $AI_UI_ROOT"
  fi
fi

# Step 2: .work.ui/ skeleton + DOCS_UI_STACK.md via bootstrap.sh (no-overwrite),
# pointing at the source .ai.ui templates.
BOOTSTRAP_SKIP_CURSERRULES=1 REPO_ROOT="$DEST_ROOT" AI_UI_ROOT="$AI_UI_ROOT" bash "$AI_UI_ROOT/templates/bootstrap.sh" \
  > /tmp/ui-deploy-basic-ui-bootstrap.$$.log 2>&1 || { cat /tmp/ui-deploy-basic-ui-bootstrap.$$.log; rm -f /tmp/ui-deploy-basic-ui-bootstrap.$$.log; exit 1; }
grep -E '(created:|skip )' /tmp/ui-deploy-basic-ui-bootstrap.$$.log | sed 's/^/  work.ui: /' || true
rm -f /tmp/ui-deploy-basic-ui-bootstrap.$$.log

# Step 3: update — list existing-but-differing local-surface files as merge candidates.
if [[ "$MODE" == "update" ]]; then
  echo ""
  echo "=== update merge candidates ==="
  # .cursorrules vs the freshly-substituted template
  if [[ -f "$CURS_DEST" ]]; then
    tmp_cur="$(mktemp)"
    subst_cursorules > "$tmp_cur"
    if ! cmp -s "$tmp_cur" "$CURS_DEST"; then
      echo "  merge: .cursorrules  (differs from current template-with-source)"
    fi
    rm -f "$tmp_cur"
  fi
  # .work.ui/ skeleton files vs source templates (strip .template suffix)
  TPL_WORK_UI="${AI_UI_ROOT}/templates/work.ui"
  for f in "${WORK_UI_FILES[@]}"; do
    src="${TPL_WORK_UI}/${f}.template"
    dest="${DEST_ROOT}/.work.ui/${f}"
    [[ -f "$src" && -f "$dest" ]] || continue
    if ! cmp -s "$src" "$dest"; then
      echo "  merge: .work.ui/${f}  (target has user content — agent appends new template sections only; preserves user edits)"
    fi
  done
  # DOCS_UI_STACK.md vs source template
  if [[ -f "${AI_UI_ROOT}/templates/DOCS_UI_STACK.md.template" && -f "$STACK_DEST" ]] && \
     ! cmp -s "${AI_UI_ROOT}/templates/DOCS_UI_STACK.md.template" "$STACK_DEST"; then
    echo "  merge: DOCS_UI_STACK.md  (preserve target stack pins)"
  fi
  echo ""
  echo "  (agent performs rules-aware merge — append new sections, preserve target"
  echo "   customizations + REPLACE tokens + AI_UI_SOURCE. See skill ui-deploy-basic § update-merge.)"
fi

echo ""
echo "=== Done: thin-client bootstrap (UI Design OS) → $DEST_ROOT ==="
echo "  .cursorrules: $([ -f "$CURS_DEST" ] && echo present || echo MISSING)"
echo "  AI_UI_SOURCE: $(grep -oE 'AI_UI_SOURCE=[^ ]*' "$CURS_DEST" 2>/dev/null | head -1 | cut -d= -f2- || echo '<unset — fat-client>')"
echo "  .work.ui/: $([ -d "${DEST_ROOT}/.work.ui" ] && echo present || echo MISSING)"
echo "  skills (local): $([ -d "${DEST_ROOT}/.ai.ui/skills" ] && echo "present — fat-client (unexpected for basic)" || echo 'absent — thin-client (skills load from source)')"

# Post-deploy wiring audit (read-only report — strict form: ui-deploy-basic verify).
echo ""
bash "$VERIFY" "$DEST_ROOT" --report || true

echo ""
echo "Next steps in target project:"
echo "  1. Edit ${DEST_ROOT}/.cursorrules — fill every REPLACE: token EXCEPT AI_UI_SOURCE (ui-deploy-basic set it)"
echo "  2. Strict wiring audit:  bash $VERIFY $DEST_ROOT   (add --fix to auto-fill)"
echo "  3. Run @session-control start  (if Agent OS .ai/ present)"
echo "  4. First UI skill: @ui-design-foundation greenfield (loaded from \$AI_UI_SOURCE/skills/)"
