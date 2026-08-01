#!/usr/bin/env bash
# ui-eval.sh — approximate UI-quality metrics (directional signal only; never a
# pass/fail gate — humans decide on flags). Metric core runs on python3 stdlib;
# screenshot capture is the adopter's CI environment (Playwright), NOT a
# framework requirement. NOT CLIP/semantic similarity.
# Usage:
#   ui-eval.sh --self-test                      # validate metric math (exit 0)
#   ui-eval.sh --json A.json B.json             # compare two histogram descriptors
set -euo pipefail

case "${1:-}" in
  --self-test)
    python3 - <<'PY'
import sys

def hist_dist(a, b):
    if len(a) != len(b):
        return 1.0
    n = sum(a) or 1
    m = sum(b) or 1
    na = [x / n for x in a]
    nb = [x / m for x in b]
    return 0.5 * sum((x - y) ** 2 / (x + y + 1e-9) for x, y in zip(na, nb))

ok = True
# identical histograms -> distance 0
if hist_dist([1, 2, 3], [1, 2, 3]) > 1e-9:
    print("SELFTEST FAIL: identical histograms should match"); ok = False
# disjoint histograms -> high distance
if hist_dist([10, 0], [0, 10]) < 0.5:
    print("SELFTEST FAIL: disjoint histograms should differ"); ok = False
# different lengths -> 1.0
if hist_dist([1], [1, 2]) != 1.0:
    print("SELFTEST FAIL: length mismatch should be 1.0"); ok = False
print("ok: ui-eval metric core (histogram distance) self-test")
sys.exit(0 if ok else 1)
PY
    ;;
  --json)
    python3 - "$2" "$3" <<'PY'
import json, sys

def hist_dist(a, b):
    if len(a) != len(b):
        return 1.0
    n = sum(a) or 1
    m = sum(b) or 1
    na = [x / n for x in a]
    nb = [x / m for x in b]
    return 0.5 * sum((x - y) ** 2 / (x + y + 1e-9) for x, y in zip(na, nb))

try:
    A = json.load(open(sys.argv[1]))
    B = json.load(open(sys.argv[2]))
except Exception as e:
    print(f"FAIL: {e}"); sys.exit(1)

report = {
    "tool": "ui-eval.sh",
    "approx": "color-histogram + text-presence + geometry proxies; NOT CLIP/semantic; directional only",
    "color_hist_distance": hist_dist(A.get("histogram", []), B.get("histogram", [])),
    "text_presence": {
        "candidate_missing": [t for t in B.get("expected_text", []) if t not in A.get("text", [])],
    },
    "geometry": None,
}
if A.get("width") and B.get("width"):
    report["geometry"] = abs(A["width"] / A["height"] - B["width"] / B["height"])
flags = []
if report["color_hist_distance"] > 0.35:
    flags.append("color drift beyond threshold (0.35)")
if report["text_presence"]["candidate_missing"]:
    flags.append(f"missing text: {report['text_presence']['candidate_missing']}")
report["verdict"] = "flag" if flags else "pass (human review still required)"
report["flags"] = flags
print(json.dumps(report, indent=2))
sys.exit(0)
PY
    ;;
  *)
    echo "usage: ui-eval.sh --self-test | --json <candidate.json> <reference.json>" >&2
    echo "Note: screenshot capture is the adopter's CI environment (Playwright);" >&2
    echo "the framework itself requires no installation." >&2
    exit 2
    ;;
esac
