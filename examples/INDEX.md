# Examples index

**Last reviewed:** 2026-07-03 · **PNG files:** gitignored (large); **manifests** are the agent source of truth. Clone without PNGs → use manifest columns only; vision agents need local `examples/**/*.png`.

## Value matrix (for agents)

| Folder | Count | Archetype | Actionable today | Notes |
|--------|-------|-----------|------------------|-------|
| [websites](websites/manifest.md) | 9 | marketing-site | **High** (W1–W9) | All individually annotated; PNGs optional |
| [websites-tecnology](websites-tecnology/manifest.md) | 8 | saas-product | **High** (T1–T8) | All individually annotated; PNGs optional |
| [dashboards](dashboards/manifest.md) | 13 | admin-dashboard | **High** (D1–D13) | Full row schema; D9–D13 are text-only (no PNG) |
| [mobile](mobile/manifest.md) | 9 | mobile-app | **High** (M1–M9) | All individually annotated; PNGs optional |
| [mobile-controls](mobile-controls/manifest.md) | 6 | mobile-app | **High** (C1–C6) | Controls / surfaces / primitives |

**Critical:** Filenames (`image copy N.png`) are not semantic. Use manifest **id** column (`C1`, `D1`, `W1`, …).

**Vision agents:** Open PNG paths cited in manifests. **Text-only agents:** Use manifest **extractedRules**, **primitives**, **surfaces** columns + [`standards/20260523-SURFACE-AND-CONTROL-CRAFT.md`](../standards/20260523-SURFACE-AND-CONTROL-CRAFT.md).

## External inspiration (URLs)

Curated links: [`resources/README.md`](../resources/README.md)

## Example → implementation playbook

Use on **every** project (any website, app, responsive UI):

```text
Phase A — Pick references
  1. @ui-project-approach - <one sentence>
  2. Pick 2–4 ids from table above (not whole folders)
  3. Vision agent: annotate PNG → inputs/design-references/ (optional)

Phase B — Bind to foundation
  4. @ui-design-foundation greenfield — craft tier in doc 01
  5. Doc 02: --surface-* tokens · doc 03: example id + primitive rows
  6. @ui-design-system init → add P0 primitives from doc 03 (behavior: [`resources/control-platforms.md`](../resources/control-platforms.md))

Phase C — SPECs as contracts
  7. @ui-screen-spec create - <slug> — copy extractedRules → §11 + §13
  8. @ui-screen-spec review → Approved

Phase D — Build & verify
  9. @ui-component-build plan - S0 (primitives) then S1 (screens)
 10. @ui-concept-run - UIS-07 (tier ≥ refined) + UIS-06 (agent diffs) + UIS-09 (analytical dashboards)
 11. @ui-visual-verify milestone — §13 craft checklist
```

**Invalid:** SPEC cites `mobile-controls/C1` but ships native `<input type="range">` without waiver.
