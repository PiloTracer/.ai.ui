# Brand design system contract — optional extension of foundation doc 03

> Optional brand-grade extension. Copy to `.work.ui/plans/foundation/YYYYMMDD-03-design-system.brand.md` when the project needs on-brand, non-generic UI (craft tier ≥ refined or `design-system` archetype). Sections map to tokens + CATALOG so agent output obeys the brand. Handoff-shape reference: Open CoDesign Decompose-to-UI-Kit (`ui_kits/<slug>/` = index + components + tokens + manifest).

## 1. Brand essence & positioning

- **One line:** `REPLACE:UI_BRAND_ONE_LINER`
- **Proof points:** `REPLACE:UI_BRAND_PROOF_POINTS` (2–4 concrete claims a viewer can verify)
- **Anti-brand:** what the UI must **never** look like (e.g. generic bootstrap, neon gradients)

## 2. Logo & asset usage

- Safe area / minimum size: `REPLACE:UI_LOGO_SAFE_AREA`
- Misuse rules (never: recolor, outline, stretch, drop-shadow)
- Asset inventory: `REPLACE:UI_ASSET_PATHS` — each asset **must** record its license (commercial-safe per INTEGRATION_LICENSE_STANDARD; no unlicensed assets)

## 3. Color tokens (semantic)

- Map brand colors → semantic tokens (`--color-accent`, `--surface-*`) in DTCG `tokens.json` (OKLCH; contrast-by-construction — Leonardo/Radix pattern, §1 research)
- Text steps must pass contrast (WCAG 2.2 AA) in **every** theme

## 4. Typography

- Scale (fluid via `clamp()` — Utopia pattern) + pairing + weights
- Font source: `REPLACE:UI_FONT_SOURCE` (prefer Fontsource; record font license)

## 5. Spacing & layout

- Fluid spacing scale, grid, breakpoints (UIS-02) — bound to `--space-*` tokens

## 6. Components (primitives → CATALOG)

- Primitive list → `.work.ui/design-system/CATALOG.md` binding (each row: token names only, no literals)
- Handoff shape per Open CoDesign Decompose-to-UI-Kit (components + tokens + manifest)

## 7. Voice & tone

- Point to `COPY_STANDARD` §1 (tone definition) — do not duplicate; add brand-specific do/don't copy samples

## 8. Motion

- Duration/easing tokens per `MOTION_STANDARD` (UIS-03); brand-approved transitions only

## 9. Provenance & licenses

- Every asset/font/icon listed with license + source URL; anything failing the license policy is excluded, not "forgotten"
