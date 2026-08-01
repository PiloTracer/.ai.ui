#!/usr/bin/env bash
# token-schema-verify.sh — Validate a DTCG (W3C Design Tokens) JSON file.
# Checks: valid JSON; every token has $type + $value; $type in the DTCG set;
# aliases ({path}) resolve to an existing token. Uses python3 stdlib only.
# Usage: token-schema-verify.sh <tokens.json>  (exit 0 = valid)
set -euo pipefail

FILE="${1:-}"
if [[ -z "${FILE}" ]] || [[ ! -f "${FILE}" ]]; then
  echo "usage: token-schema-verify.sh <tokens.json>" >&2
  exit 2
fi

python3 - "$FILE" <<'PY'
import json, re, sys

path = sys.argv[1]
ALLOWED = {
    "color", "dimension", "fontFamily", "fontWeight", "fontSize", "letterSpacing",
    "lineHeight", "duration", "cubicBezier", "easing", "number", "strokeStyle",
    "border", "transition", "shadow", "gradient", "typography",
}
try:
    doc = json.load(open(path))
except Exception as e:
    print(f"FAIL: {path}: invalid JSON — {e}")
    sys.exit(1)

flat = {}   # full path -> node
errors = []

def walk(node, prefix):
    if isinstance(node, dict) and "$type" in node:
        flat[prefix] = node
        return
    if not isinstance(node, dict):
        errors.append(f"{prefix}: expected group (object) or token (with $type)")
        return
    for k, v in node.items():
        if k.startswith("$"):
            errors.append(f"{prefix}.{k}: stray property outside a token")
            continue
        walk(v, f"{prefix}.{k}" if prefix else k)

walk(doc, "")

if not flat:
    errors.append("no tokens found (no leaf with $type)")
    print("FAIL: " + "\n".join(errors))
    sys.exit(1)

for name, node in flat.items():
    if node.get("$type") not in ALLOWED:
        errors.append(f"{name}: unknown $type '{node.get('$type')}'")
    val = node.get("$value")
    if val is None:
        errors.append(f"{name}: missing $value")
        continue
    if isinstance(val, str):
        m = re.fullmatch(r"\{([^{}]+)\}", val)
        if m and m.group(1) not in flat:
            errors.append(f"{name}: alias '{val}' does not resolve")

if errors:
    print("FAIL: " + "\n".join(errors))
    sys.exit(1)
print(f"ok: {path} — {len(flat)} tokens valid (DTCG shape, aliases resolve)")
PY
