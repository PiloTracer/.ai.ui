# Reference-image intake runbook (optional, Phase 4)

**Purpose:** `@ui-screen-spec intake - <image path|URL>` — start a screen from a reference image/mockup, then force it through the framework's gates so output obeys the design system.

**Legal:** screenshot-to-code (MIT) — self-hosted FastAPI backend or BYOK keys; output is owned by the project. The framework requires **no installation** — this runbook is entirely adopter-environment.

---

## Prerequisites (user environment, not framework)

- Self-hosted [screenshot-to-code](https://github.com/abi/screenshot-to-code) (MIT, FastAPI) **or** API keys for a supported provider (OpenAI / Anthropic / Gemini — Gemini recommended for asset extraction).
- Operator **owns the rights** to the reference image (asserted in the intake prompt; never auto-commit).

## Flow

1. **Classify** the request with the standard 4-class intake table (`local` / `cross-cutting` / `brownfield` / `underspecified`).
2. **Scaffold** — submit the image to the screenshot-to-code backend → receive HTML/Tailwind/React scaffold → place under `.work.ui/tmp/` (gitignored scratch).
3. **Re-skin (mandatory gates before promotion):**
   - Map every color to tokens — `token-lint` must pass (no raw hex outside the token file).
   - `UIS-06` visual-quality pass (no generic chrome; spacing/alignment audit).
   - `UIS-04` contrast check on new color pairs.
   - `UIS-02` responsive check at the SPEC's breakpoints.
4. **Promote** — only when all gates pass, move to `screens/<slug>/YYYYMMDD-SCREEN-SPEC.md` + scaffold; otherwise return to step 3 or reject with honest gaps.

## Honesty rules

- Scaffold is a **starting point**, never a final artifact.
- Reuse real logos/images from the reference (asset-extraction pattern) — but each reused asset's license must be verified (INTEGRATION_LICENSE_STANDARD); unlicensed assets are excluded.
- Handoff bundle structure mirrors Open CoDesign's Decompose-to-UI-Kit (`ui_kits/<slug>/` = index + components + tokens + manifest).

## Failure modes

| Symptom | Handling |
|---------|----------|
| Model output has off-token colors | Re-skin fails token-lint → iterate or hand-edit before promotion |
| Reference image licensing unknown | Ask the operator to confirm ownership; do not proceed |
| Backend not configured | State that image intake needs the adopter's self-hosted backend / BYOK; fall back to text `intake` |
