#!/usr/bin/env bash
# cursorrules-verify.sh — Verify that a deployed target repo's .cursorrules is
# fully wired to the UI Design OS framework and its sister frameworks.
#
# Shared backend for the deploy skills (ui-deploy-basic / ui-deploy-files);
# also usable standalone:
#
#   bash scripts/cursorrules-verify.sh <repo-root>            # strict audit, exit 1 on blocking gap
#   bash scripts/cursorrules-verify.sh <repo-root> --fix      # audit + fix what is machine-fixable
#   bash scripts/cursorrules-verify.sh <repo-root> --report   # same output, always exit 0
#
# Checks:
#   1. .cursorrules present and carries UI Design OS rules
#   2. Client mode: thin (AI_UI_SOURCE set) vs fat (vendored .ai.ui/) vs
#      framework-root (the repo IS the framework checkout)
#   3. Framework assets resolvable (thin: $AI_UI_SOURCE/skills/README.md;
#      fat: .ai.ui/skills/README.md; framework-root: skills/README.md)
#   4. Source-resolution section present in .cursorrules
#      (--fix appends it, extracted from the mode-appropriate template)
#   5. Sister framework paths (Frameworks registry: .ai / .ai.biz / .ai.soc /
#      .ai.cto / .ai.flutter / .ai.mlt) resolvable from their configured values
#      or on-disk auto-discovery — family naming (`pilo.ai.<fw>.logicbison`)
#      first, then legacy `.ai.<fw>` (see scripts/sister-discovery.sh);
#      --fix fills REPLACE:*_PATH tokens when the sister exists on disk and
#      repoints stale absolute cells
#   6. .work.ui/ working tree present (warning only)
#
# Exit 0 = wired (warnings allowed), 1 = blocking gap, 2 = usage error.
set -euo pipefail

FIX=0
REPORT=0
TARGET=""
for a in "$@"; do
  case "$a" in
    --fix)    FIX=1 ;;
    --report) REPORT=1 ;;
    -)        ;;  # agent-syntax separator, ignored
    --*)      echo "ERROR: unknown flag: $a" >&2; exit 2 ;;
    *)        if [[ -z "$TARGET" ]]; then TARGET="$a"; else echo "ERROR: unexpected argument: $a" >&2; exit 2; fi ;;
  esac
done
TARGET="${TARGET:-.}"

if [[ ! -d "$TARGET" ]]; then
  echo "ERROR: target directory does not exist: $TARGET" >&2
  exit 2
fi
ROOT="$(cd "$TARGET" && pwd)"
RULES="${ROOT}/.cursorrules"

# Source framework root + shared sister-framework discovery lib (family naming
# `pilo.ai.<fw>.logicbison` + legacy `.ai.<fw>` — see scripts/sister-discovery.sh).
AI_UI_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${AI_UI_ROOT}/scripts/sister-discovery.sh"

FAIL=0
ok()   { echo "  ok: $*"; }
bad()  { echo "  FAIL: $*"; FAIL=1; }
warn() { echo "  warn: $*"; }
note() { echo "  note: $*"; }

echo "=== cursorrules verify → ${ROOT} ==="

# ── 1. .cursorrules present + carries UI rules ────────────────────────
if [[ ! -f "$RULES" ]]; then
  bad ".cursorrules: MISSING — nothing to verify (run a deploy/bootstrap first)"
  echo ""
  echo "cursorrules-verify: FAIL"
  [[ "$REPORT" -eq 1 ]] && exit 0
  exit 1
fi
ok ".cursorrules: present"

if grep -qE 'UI_DESIGN_OS_BEGIN|UI Design OS|ui-component-build' "$RULES" 2>/dev/null; then
  ok "UI Design OS rules: present"
else
  bad "UI Design OS rules: absent (no UI_DESIGN_OS_BEGIN block, no standalone UI template markers)"
fi

# ── 2. Client mode detection ──────────────────────────────────────────
SRC="$(grep -oE 'AI_UI_SOURCE=[^ ]*' "$RULES" 2>/dev/null | head -1 | cut -d= -f2- || true)"
MODE=""
BASE=""          # dir whose children are the sister framework dirs
ASSETS=""        # dir that must contain skills/README.md + templates/
if [[ -n "$SRC" && "$SRC" != "REPLACE_BASICUI_SOURCE" ]]; then
  MODE="thin"
  BASE="$(dirname "$SRC")"
  ASSETS="$SRC"
  ok "mode: thin-client (AI_UI_SOURCE=$SRC)"
elif [[ -f "${ROOT}/.ai.ui/skills/README.md" ]]; then
  MODE="fat"
  BASE="$ROOT"
  ASSETS="${ROOT}/.ai.ui"
  ok "mode: fat-client (vendored .ai.ui/)"
elif [[ -f "${ROOT}/skills/README.md" && -f "${ROOT}/templates/cursorrules.ui.template" ]]; then
  MODE="framework-root"
  BASE="$(dirname "$ROOT")"
  ASSETS="$ROOT"
  ok "mode: framework-root (this repo IS the .ai.ui checkout)"
else
  MODE="unknown"
  BASE="$ROOT"
  bad "client mode: unresolvable — AI_UI_SOURCE unset AND no local .ai.ui/skills/README.md (no UI framework assets findable)"
fi

# Framework dir S — relative registry cells resolve against S (sister = S/../<fw>);
# parent = S/.. is the sibling search base (see .cursorrules § Frameworks registry).
FW_DIR="$ROOT"
case "$MODE" in
  thin) FW_DIR="$SRC" ;;
  fat)  FW_DIR="${ROOT}/.ai.ui" ;;
esac

# ── 3. Framework assets resolvable ────────────────────────────────────
if [[ "$MODE" == "thin" ]]; then
  if [[ -d "$SRC" && -f "${SRC}/skills/README.md" ]]; then
    ok "AI_UI_SOURCE reachable with skills registry (${SRC})"
  else
    bad "AI_UI_SOURCE unreachable or invalid: ${SRC} (expected a dir containing skills/README.md)"
  fi
  if [[ -d "${ROOT}/.ai.ui/skills" ]]; then
    warn "local .ai.ui/skills/ also present — mixed thin+fat state (skills resolve fat-first; unexpected)"
  fi
elif [[ "$MODE" == "fat" || "$MODE" == "framework-root" ]]; then
  ok "framework assets: ${ASSETS}/skills/README.md readable"
fi

# ── 4. Source-resolution section ─────────────────────────────────────
append_source_resolution() { # $1 = template path, $2 = source value (thin) or ""
  local tpl="$1" srcval="${2:-}" esc=""
  [[ -f "$tpl" ]] || return 1
  if [[ -n "$srcval" ]]; then esc="${srcval//\//\\/}"; fi
  {
    echo ""
    if [[ -n "$esc" ]]; then
      awk '/^## Source resolution/{f=1} f&&/^---$/{exit} f' "$tpl" \
        | perl -pe "s/AI_UI_SOURCE=REPLACE_BASICUI_SOURCE/AI_UI_SOURCE=${esc}/"
    else
      awk '/^## Source resolution/{f=1} f&&/^---$/{exit} f' "$tpl"
    fi
  } >> "$RULES"
}

if grep -q '^## Source resolution' "$RULES" 2>/dev/null; then
  ok "Source-resolution section: present"
else
  fixed=0
  if [[ "$FIX" -eq 1 ]]; then
    case "$MODE" in
      thin)           append_source_resolution "${SRC}/templates/cursorrules.ui.template" "$SRC" && fixed=1 ;;
      fat)            append_source_resolution "${ASSETS}/templates/cursorrules.ui.template" "" && fixed=1 ;;
      framework-root) note "Source-resolution section: not applicable to a framework checkout — skipped" ;;
    esac
  fi
  if [[ "$fixed" -eq 1 ]]; then
    ok "Source-resolution section: appended by --fix"
  elif [[ "$MODE" == "thin" ]]; then
    bad "Source-resolution section: MISSING (thin-client target cannot resolve .ai.ui paths without it — run verify --fix)"
  elif [[ "$MODE" != "framework-root" ]]; then
    warn "Source-resolution section: absent (fat-client/merged rules — run verify --fix to append, or ignore if intentional)"
  fi
fi

# ── 5. Sister framework paths (Frameworks registry) ──────────────────
if ! grep -q 'Frameworks registry' "$RULES" 2>/dev/null; then
  note "Frameworks registry section: absent (merged-snippet rules?) — sisters resolve by on-disk auto-discovery only"
fi

# check_sister <slot-id|''> <dir-name> <token-var> — one registry row.
# slot-id: FRAMEWORK_SLOTS id (family + legacy discovery via sister-discovery.sh);
# '' for `.ai` (Agent OS, legacy-only). On-disk discovery checks the source
# parent, then the target's parent, then the target root.
check_sister() {
  local fw="$1" sf="$2" var="$3" token="REPLACE:${3}" sister_dir=""
  if [[ -n "$fw" ]]; then
    sister_dir="$(find_sister_dir "$AI_UI_ROOT" "$fw" "$BASE" "$(dirname "$ROOT")" "$ROOT" || true)"
  else
    local p
    for p in "$BASE" "$(dirname "$ROOT")" "$ROOT"; do
      p="$(cd "$p" 2>/dev/null && pwd)" || continue
      if [[ -d "${p}/${sf}" && -f "${p}/${sf}/skills/README.md" ]]; then
        sister_dir="${p}/${sf}"
        break
      fi
    done
  fi

  if grep -q "$token" "$RULES" 2>/dev/null; then
    if [[ -n "$sister_dir" ]]; then
      if [[ "$FIX" -eq 1 ]]; then
        local fw_esc="${sister_dir//\//\\/}"
        perl -i -pe "s{${token} \\(default:? \\\`[^)]*\\)}{${fw_esc} (discovered at deploy time)}" "$RULES"
        if grep -q "$token" "$RULES" 2>/dev/null; then
          warn "${sf}: ${token} cell shape not matched by --fix — left for runtime auto-discover"
        else
          ok "${sf}: ${token} filled by --fix → ${sister_dir}"
        fi
      else
        warn "${sf}: installed on disk at ${sister_dir} but ${token} unset (auto-discovery covers it; run verify --fix to pin)"
      fi
    else
      note "${sf}: not installed here (${token} left unset — routing preflight will degrade)"
    fi
    return 0
  fi

  local row val
  row="$(grep -E "^\|.*\`${sf}\`" "$RULES" 2>/dev/null | head -1 || true)"
  if [[ -n "$row" ]]; then
    if [[ "$sf" == ".ai.ui" ]]; then
      ok "${sf}: self-hosted (this directory)"
      return 0
    fi
    val="$(printf '%s' "$row" | awk -F'|' '{print $4}' | sed 's/[[:space:]`]//g' | cut -d'(' -f1)"
    if [[ -n "$val" ]]; then
      local resolved="$val"
      [[ "$val" != /* ]] && resolved="${FW_DIR}/${val}"
      if [[ -d "$resolved" && -f "${resolved}/skills/README.md" ]]; then
        ok "${sf}: configured path resolvable (${val})"
        return 0
      fi
      if [[ "$val" =~ ^\*sourcevia([A-Za-z_][A-Za-z0-9_]*)\*$ ]]; then
        var="${BASH_REMATCH[1]}"
        varval="$(grep -E "^${var}=[^[:space:]]*" "$RULES" 2>/dev/null | head -1 | cut -d= -f2- || true)"
        if [[ -z "$varval" ]]; then
          varval="$(grep -E "^\| *\`?${var}\`? *\|" "$RULES" 2>/dev/null | head -1 | awk -F'|' '{print $3}' | sed 's/[[:space:]`]//g' || true)"
        fi
        if [[ -n "$varval" && -d "$varval" && -f "${varval}/skills/README.md" ]]; then
          ok "${sf}: '${val}' resolves via ${var}=${varval}"
        else
          bad "${sf}: '*source via ${var}*' resolves to '${varval}' which is not a framework dir with skills/README.md"
        fi
        return 0
      fi
      # Static path cell that does not resolve: repoint with --fix when the
      # sister is discoverable elsewhere (absolute cells only — relative cells
      # are the framework-root registry's machine-independent form).
      if [[ "$FIX" -eq 1 && -n "$sister_dir" && "$val" == /* && "$val" != "$sister_dir" ]]; then
        perl -i -pe "s{\Q${val}\E}{${sister_dir}}g" "$RULES"
        ok "${sf}: stale configured path '${val}' repointed by --fix → ${sister_dir}"
      elif [[ -n "$sister_dir" ]]; then
        warn "${sf}: configured path '${val}' does not resolve; installed at ${sister_dir} (run verify --fix to repoint)"
      else
        warn "${sf}: configured path '${val}' not found — ${sf} not installed here (routing preflight will degrade)"
      fi
      return 0
    fi
    if [[ -n "$sister_dir" ]]; then
      ok "${sf}: path cell empty — auto-discovered at ${sister_dir}"
    else
      note "${sf}: path cell empty, not installed — routing preflight will degrade"
    fi
  elif [[ -n "$sister_dir" ]]; then
    note "${sf}: installed at ${sister_dir} (no registry row — auto-discovery applies)"
  fi
}

# `.ai` (Agent OS) — legacy-only discovery (no family naming for the Agent OS itself).
check_sister "" ".ai" "AGENT_OS_PATH"
# The six framework slots (family naming first, then legacy — see sister-discovery.sh).
for fw in $FRAMEWORK_SLOTS; do
  FWU="$(echo "$fw" | tr '[:lower:]' '[:upper:]')"
  check_sister "$fw" ".ai.${fw}" "AI_${FWU}_PATH"
done

# ── 6. REPLACE token inventory (informational) ───────────────────────
total="$(grep -c 'REPLACE:' "$RULES" 2>/dev/null || true)"
total="${total:-0}"
ui_only="$(grep -c 'REPLACE:UI_' "$RULES" 2>/dev/null || true)"
ui_only="${ui_only:-0}"
note "REPLACE tokens remaining: ${total} (operator-filled UI_*: ${ui_only}) — UI_* tokens are project pins, not a failure"

# ── 7. .work.ui working tree ─────────────────────────────────────────
if [[ -d "${ROOT}/.work.ui/context" ]]; then
  ok ".work.ui/: present"
else
  warn ".work.ui/: missing (run @ui-bootstrap init or a deploy to scaffold)"
fi

echo ""
if [[ "$FAIL" -eq 0 ]]; then
  echo "cursorrules-verify: PASS$([[ "$FIX" -eq 1 ]] && echo " (fix mode)")"
else
  echo "cursorrules-verify: FAIL"
fi
[[ "$REPORT" -eq 1 ]] && exit 0
exit "$FAIL"
