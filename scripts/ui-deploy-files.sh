#!/usr/bin/env bash
# ui-deploy-files.sh — Deploy .ai.ui (UI Design OS) files into a target project
#
# Copies ONLY files git considers (tracked + untracked-not-ignored). Skill-level
# excludes (.github/, .gitignore, .cursorrules, deploy scripts) are omitted;
# ui-deploy-repo covers the full-repo case.
#
# Default = NO-OVERWRITE. Use force for legacy overwrite, or update for merge
# candidates when source files differ from target copies.
#
# Flag equivalence: verbs work WITH or WITHOUT the "--" prefix, in any
# position relative to the target path — these are identical:
#   bash scripts/ui-deploy-files.sh /path/to/target update
#   bash scripts/ui-deploy-files.sh /path/to/target --update
# The agent-syntax separator "-" between verb and path is ignored.
#
# status / verify audit the target's wiring without copying anything:
#   status — read-only report (always exit 0)
#   verify — strict .cursorrules + asset audit (exit 1 on blocking gap);
#            verify --fix also fills machine-fixable gaps (sister paths,
#            missing Source-resolution section).
#
# Usage:
#   bash scripts/ui-deploy-files.sh <target-path>              # no-overwrite
#   bash scripts/ui-deploy-files.sh <target-path> force        # overwrite existing
#   bash scripts/ui-deploy-files.sh <target-path> update       # no-overwrite + merge list
#   bash scripts/ui-deploy-files.sh <target-path> status       # read-only report
#   bash scripts/ui-deploy-files.sh <target-path> verify [--fix] # strict audit
#   AI_UI_ROOT=/path/.ai.ui bash scripts/ui-deploy-files.sh <target-path>
#
set -euo pipefail

# ── Argument parsing (verb == --verb, any position; "-" ignored) ──────
MODE="skip"
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
    --*)             echo "ERROR: unknown flag: $1" >&2; exit 1 ;;
    *)               if [[ -z "$RAW_TARGET" ]]; then RAW_TARGET="$a"; else echo "ERROR: unexpected argument: $a" >&2; exit 1; fi ;;
  esac
done
RAW_TARGET="${RAW_TARGET:-.}"

if [[ -n "${AI_UI_ROOT:-}" ]]; then
  AI_UI_ROOT="$(cd "$AI_UI_ROOT" && pwd)"
elif [[ -n "${AI_SOURCE:-}" ]]; then
  AI_UI_ROOT="$(cd "$AI_SOURCE" && pwd)"
else
  AI_UI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
fi
VERIFY="${AI_UI_ROOT}/scripts/cursorrules-verify.sh"

# ── status / verify (read-only; verify --fix is the only mutation) ────
if [[ "$MODE" == "status" || "$MODE" == "verify" ]]; then
  RT="$RAW_TARGET"
  [[ "$RT" == *.ai.ui ]] && RT="$(dirname "$RT")"
  if [[ ! -d "$RT" ]]; then
    echo "ERROR: target directory does not exist: $RT" >&2
    exit 1
  fi
  REPO="$(cd "$RT" && pwd)"
  echo "=== ui-deploy-files ${MODE} → ${REPO} ==="
  if [[ -d "${REPO}/.ai.ui/skills" ]]; then
    echo "  .ai.ui/: present ($(find "${REPO}/.ai.ui" -type f | wc -l | tr -d ' ') files)"
  else
    echo "  .ai.ui/: missing (run ui-deploy-files copy first)"
  fi
  if [[ "$MODE" == "status" ]]; then
    bash "$VERIFY" "$REPO" --report
  elif [[ "$FIX" -eq 1 ]]; then
    bash "$VERIFY" "$REPO" --fix
  else
    bash "$VERIFY" "$REPO"
  fi
  exit $?
fi

# ── Copy modes below this point ───────────────────────────────────────

if [[ "$RAW_TARGET" == *.ai.ui ]]; then
  DEST_DIR="$RAW_TARGET"
else
  DEST_DIR="${RAW_TARGET}/.ai.ui"
fi

# Never deploy the source framework into itself.
DEST_CHECK="$(cd "$(dirname "$DEST_DIR")" && pwd)/$(basename "$DEST_DIR")"
if [[ "$DEST_CHECK" == "$AI_UI_ROOT" || "$DEST_CHECK" == "$AI_UI_ROOT"/* ]]; then
  echo "ERROR: destination $DEST_CHECK is inside the source framework ($AI_UI_ROOT) — refusing." >&2
  exit 1
fi

PARENT="$(dirname "$DEST_DIR")"
if [[ ! -d "$PARENT" ]]; then
  echo "ERROR: parent directory does not exist: $PARENT" >&2
  exit 1
fi

if [[ -e "$DEST_DIR" ]] && [[ ! -d "$DEST_DIR" ]]; then
  echo "ERROR: $DEST_DIR exists but is not a directory" >&2
  exit 1
fi

if ! (cd "$AI_UI_ROOT" && git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
  echo "ERROR: source $AI_UI_ROOT is not a git repo." >&2
  exit 1
fi

GIT_TOP="$(cd "$AI_UI_ROOT" && git rev-parse --show-toplevel)"
if [[ "$GIT_TOP" != "$AI_UI_ROOT" ]]; then
  echo "ERROR: $AI_UI_ROOT is not the git repo root (root is $GIT_TOP)." >&2
  exit 1
fi

echo "=== ui-deploy-files → $DEST_DIR ==="
echo "  source: $AI_UI_ROOT"
echo "  mode:   $MODE (no-overwrite by default)"
if [[ -d "$DEST_DIR" ]]; then
  echo "  exists: $DEST_DIR — re-copying (no-overwrite; preserves existing target files)"
fi

SKILL_EXCLUDE_REGEX='^(\.github/|\.gitignore$|\.gitattributes$|\.cursorrules$|scripts/ui-deploy-files\.sh$|scripts/ui-deploy-basic\.sh$|scripts/ui-deploy-repo\.sh$)'

TMP_LIST="$(mktemp)"
MERGE_CANDS="$(mktemp)"
trap 'rm -f "$TMP_LIST" "$MERGE_CANDS"' EXIT

( cd "$AI_UI_ROOT" \
  && git ls-files --cached --others --exclude-standard \
  | grep -vE "$SKILL_EXCLUDE_REGEX" \
  | while IFS= read -r f; do test -f "$AI_UI_ROOT/$f" && echo "$f"; done \
) > "$TMP_LIST"

COUNT="$(wc -l < "$TMP_LIST" | tr -d ' ')"
mkdir -p "$DEST_DIR"

SKIPPED=0
if [[ "$MODE" != "force" ]]; then
  while IFS= read -r rel; do
    [[ -z "$rel" ]] && continue
    if [[ -f "$DEST_DIR/$rel" ]]; then
      SKIPPED=$((SKIPPED+1))
      if [[ "$MODE" == "update" ]] && ! cmp -s "$AI_UI_ROOT/$rel" "$DEST_DIR/$rel"; then
        echo "$rel" >> "$MERGE_CANDS"
      fi
    fi
  done < "$TMP_LIST"
fi

if [[ "$MODE" == "force" ]]; then
  rsync -a --files-from="$TMP_LIST" "$AI_UI_ROOT"/ "$DEST_DIR"/
else
  rsync -a --ignore-existing --files-from="$TMP_LIST" "$AI_UI_ROOT"/ "$DEST_DIR"/
fi

COPIED=$((COUNT - SKIPPED))
echo "  copied: $COPIED files (git-ignored content excluded by policy)"
echo "  skipped (exists): $SKIPPED files"

if [[ "$MODE" == "update" ]] && [[ -s "$MERGE_CANDS" ]]; then
  MERGE_N="$(wc -l < "$MERGE_CANDS" | tr -d ' ')"
  echo ""
  echo "=== update merge candidates ($MERGE_N existing-but-differing files) ==="
  while IFS= read -r rel; do
    echo "  merge: $rel"
  done < "$MERGE_CANDS"
  echo "  (agent performs rules-aware merge — preserve target customizations.)"
fi

if [[ "$RAW_TARGET" == "." || "$RAW_TARGET" == "$PWD" ]]; then
  REPO_ROOT="$(cd "$PARENT" && pwd)"
  CR_MODE="create-cursorrules"
  if [[ -f "${REPO_ROOT}/.cursorrules" ]]; then
    CR_MODE=""
  fi
  REPO_ROOT="$REPO_ROOT" AI_UI_ROOT="$AI_UI_ROOT" \
    CURSORRULES_MODE="${CR_MODE:-status}" \
    bash "$AI_UI_ROOT/templates/bootstrap.sh" \
    > /tmp/ui-deploy-files-ui-bootstrap.$$.log 2>&1 || { cat /tmp/ui-deploy-files-ui-bootstrap.$$.log; rm -f /tmp/ui-deploy-files-ui-bootstrap.$$.log; exit 1; }
  grep -E '(created:|skip )' /tmp/ui-deploy-files-ui-bootstrap.$$.log | sed 's/^/  scaffold: /' || true
  rm -f /tmp/ui-deploy-files-ui-bootstrap.$$.log
  SCAFFOLD_DONE=1
fi

echo ""
echo "=== Done: files deployed to $DEST_DIR ==="
echo ""
if [[ -n "${SCAFFOLD_DONE:-}" ]]; then
  echo "  Scaffold created (.work.ui/, .cursorrules or merge hint, DOCS_UI_STACK.md)"
  echo ""
  # Post-deploy wiring audit (read-only report — strict form: ui-deploy-files verify).
  bash "$VERIFY" "$REPO_ROOT" --report || true
  echo ""
  echo "  Next: fill REPLACE:UI_* tokens in .cursorrules"
else
  echo "Next steps in target project:"
  echo "  1. Run @ui-bootstrap init merge-cursorrules (or create-cursorrules)"
  echo "  2. Run @ui-project-approach - <describe project>"
  echo "  3. Strict wiring audit: bash $VERIFY <target-repo>"
fi
echo "  4. Run @ui-design-foundation greenfield"
