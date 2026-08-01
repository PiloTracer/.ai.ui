# Framework improvement plan — UIX & website-design capabilities (2026-07-31)

**Purpose:** Detailed, sequenced plan to extend UI Design OS with verified, license-safe integrations and skill improvements that measurably improve **UIX quality** (rendered-UI verification, accessibility, consistency, copy) and **website design** (brand systems, token truth, design-to-code, data-viz). Companion to [`20260707-ui-improvement-plan.md`](20260707-ui-improvement-plan.md) (change-safety track) and [`20260731-web-research-integration-report.md`](20260731-web-research-integration-report.md) (research catalog track).

**Derived from:** `tmp/feedback.md` (verified — see Part A) + web-research catalog (`resources/web-research-2026.md`) + framework skill audit.

**License rule (binding) — scope:** governs only 3rd-party source code **vendored into** `standards/`, `practices/`, `skills/` (or bundled framework assets): anything bundled must permit **commercial use + free distribution without source disclosure** → permissive OSS only (**MIT, Apache-2.0, BSD, CC0, W3C open standards**). **MPL-2.0** = consumer-side dependency only, never vendored. **CC-BY-NC, GPL/LGPL, paid books, required paid SaaS** = excluded from *vendored* code. Copyrighted articles = link-only. **Does NOT govern:** libraries the framework's *generated code* depends on (FLET, PySide6, PyQt6) — those are installed and licensed by the adopter's project; nor does it restrict which UI libraries a skill may target.

---

## Part A — Verified suggestion backlog (from `tmp/feedback.md`)

Verified 2026-07-31 by fetching each repo + doc site. All verdicts confirmed.

| Repo | License | Feedback verdict | Verified? | Integrate as |
|------|---------|------------------|-----------|--------------|
| `web-infra-dev/midscene` | MIT | Highly integratable: vision-driven `aiAct`/`aiQuery`/`aiAssert` | ✅ | Phase 1 — vision-verify tier |
| `copilotkit/copilotkit` | MIT | Integratable: `useCopilotAction` frontend skills (verified in npm README) | ✅ | Reference/pattern only — consumer-app SDK, not a framework skill |
| `abi/screenshot-to-code` | MIT | Integratable: FastAPI backend extractable as tool | ✅ | Phase 4 — reference-image intake (self-hosted runbook) |
| `nexu-io/open-design` | Apache-2.0 | Integratable: DESIGN.md contract + skills + daemon adapter pattern | ✅ | Phase 3 — brand design-system contract (pattern adoption) |
| `stackblitz-labs/bolt.diy` | MIT source ⚠ | Standalone WebContainer env; MCP confirmed | ✅ | **Excluded** — WebContainers API needs commercial license for production |
| `OpenCoworkAI/open-codesign` | MIT | Standalone Electron desktop app | ✅ | **Excluded** — standalone UI, not headless library |

**Gaps the file missed (now covered):** bolt.diy's WebContainers commercial-license catch; Open CoDesign *does* ship skill modules + Decompose-to-UI-Kit (useful as a *reference* for handoff bundle shape, Phase 3/4).

---

## Part B — Integration inventory (license-safe additions beyond the file)

| # | Integration | License | Capability added | UIX / website value | Phase |
|---|-------------|---------|------------------|---------------------|-------|
| I1 | Midscene vision assertions | MIT | Rendered-UI verification with natural-language assertions | Catches what DOM checks miss: overlap, live contrast, scroll/state, sticky chrome | 1 |
| I2 | Playwright snapshots + MCP | Apache-2.0 | CI pixel-diff baseline + opt-in agent browser loop | Regression-proof website design | 1, 7 |
| I3 | Design2Code metrics + self-revision loop | MIT | Eval metrics (block/text/position/color) + "generate→render→critique→revise" | Measured, self-improving UIX quality | 1, 6 |
| I4 | Style Dictionary + W3C DTCG | Apache-2.0 / W3C | Token JSON → code compile; schema-validated tokens | One token truth → consistent cross-screen UIX | 2 |
| I5 | color.js + Leonardo | MIT / Apache-2.0 | Perceptual contrast math + contrast-ratio palette generation | Accessible-by-construction color; no generic palettes | 2 |
| I6 | jest-axe | MIT | Component-level a11y matcher (static tier) | Accessible UIX from first render | 5/7 (already in catalog; default static a11y) |
| I7 | Open Design `DESIGN.md` schema | Apache-2.0 | Brand-grade design-system contract (9 sections) | Brand-consistent websites; anti-generic-chrome | 3 |
| I8 | screenshot-to-code (FastAPI) | MIT | Reference-image → initial code scaffold (self-hosted, BYOK) | Fast, faithful website redesigns from mockups | 4 |
| I9 | Copy rubrics (Polaris/Google/Microsoft) | © link-only | Error formula, tone 3-column rubric, bias-free/i18n, label dictionary | Non-robotic, consistent, accessible copy | 5 |
| I10 | FT Visual Vocabulary | MIT | Chart-type selection rubric | Correct, readable data-viz (UIS-09) | 6 |
| I11 | Storybook MCP | MIT | Agent queries existing primitives before generating | No re-invented components → consistent design system | 7 |
| I12 | Chrome DevTools MCP | Apache-2.0 | Post-build console/network/perf audit (opt-in §8.2) | Performance + console-clean websites | 7 |
| I13 | **FLET** (desktop UI) | Apache-2.0 ✓ | Python desktop/web/mobile UI: 150+ controls, Material/Cupertino, built-in packaging | Desktop UIX from a single Python codebase | 8 |
| I14 | **PySide6** (Qt for Python) | LGPL-3.0 ✓ | Full Qt 6 widget/graphics UI in Python | Native-feel desktop UIX; commercial-safe default Qt binding | 8 |
| I15 | **PyQt6** (Riverbank) | GPL-3.0-only OR commercial (adopter's choice) | Same Qt API as PySide6; corporate high-profile clients | Desktop UIX — **first-class stack**; license note: free in dev, commercial license when protecting source in production | 8 |

---

## Part C — The plan (phases)

Each phase: objective → value → legal → detailed changes → acceptance → risks. Each phase ships as its **own commit/PR** (per `blast-radius-check`, keep ≤2 areas per change — learned this session).

**Pre-flight (before Phase 0):** pre-populate per-phase entries so no phase forgets them — `CHANGELOG.md [Unreleased]` placeholder per phase (one bullet, e.g. "- **Phase N — <title>** <one-line outcome>"; final text lands as the phase ships) and a HANDOFF_UI session-note template per phase (date / work done / next recommended).

---

### Phase 0 — Integration license standard (enforce the rule)

**Objective:** Turn the license policy into a binding, machine-checked standard so every later integration is safe by construction.

**Value:** Compliance with the commercial-use/no-source-disclosure requirement; auditability.

**Legal:** N/A (framework-internal). W3C TR text and APG patterns remain citable.

**Changes:**
1. **New** `standards/20260523-INTEGRATION_LICENSE_STANDARD.md`:
   - Tier table: **Bundled/vendored** (MIT, Apache-2.0, BSD, CC0) · **Dependency** (adds MPL-2.0 — unmodified use only, never vendored; audit deps) · **Reference/link-only** (© articles — principles only, no paste; free-read) · **Excluded** (CC-BY-NC, GPL/LGPL baseline, paid books, required paid SaaS).
   - Rules: every URL added to `resources/` must carry a license tag (one of: `MIT` `Apache-2.0` `BSD` `CC0` `MPL-2.0-dep` `W3C` `© link-only` `SaaS` `🌐 browser`); untagged entries fail review.
2. **Enforcement:** extend `scripts/framework-verify.sh` with a self-test in **two sub-steps**: (2a) **URL extraction** — scan `resources/*.md` and extract every external URL; (2b) **license assertion** — assert each tagged resource's license is in an allowed class for its tier; fail on `CC-BY-NC`/paid/GPL anywhere in §1–§9. Add a **self-test case**: inject a fake `CC-BY-NC`-tagged entry and assert the check rejects it (and accepts a compliant entry).
3. Tag all **URL-bearing sections (§1–§9)** of `resources/web-research-2026.md` — including §7 exclusions/deprecations URLs (previously scoped §1–§6 only).

**Acceptance:** `framework-verify.sh` PASS with the new self-test; all §1–§6 entries tagged; §7 exclusion table complete.

**Risks:** False positives on ambivalent licenses → keep a documented `UNVERIFIED` tag; the §8.1 URL-verify rule already forces re-check on cite.

---

### Phase 1 — Vision-verify tier (rendered-UI verification) — *highest UIX value*

**Objective:** Let the agent verify **what users actually see**, not just markup: rendered state, geometry, contrast on live pixels, scroll/sticky behavior, responsive overflow.

**Value:** Directly targets UIX quality — the single biggest quality lever for websites; closes the "looks right in code, broken in render" gap.

**Legal:** Midscene **MIT** ✓ (BYO multimodal model keys: Qwen/Gemini/GLM/UI-TARS — self-hostable; never mandatory). Playwright **Apache-2.0** ✓. Design2Code **MIT** ✓ (metrics adopted as method, not code).

**Changes:**
1. **`skills/ui-visual-verify/skill.md`** — add mode `vision - <route>` (opt-in tier, governed by browser policy §8.2 — operator authorization required, state tool+scope+wait).
2. **New `skills/ui-visual-verify/reference.md`** — vision assertion catalog (copy-paste `aiAssert` statements), grouped:
   - *Layout:* no horizontal overflow at 375/768/1440; primary CTA above the fold; sticky header does not cover content; no orphaned overlapping elements.
   - *Color/contrast:* live text contrast ≥ 4.5:1 (3:1 large) on rendered pixels; chart categorical palette matches foundation tokens; focus ring visible.
   - *State:* skeleton → content transition completes; empty states show guidance text; error message follows "what+why+next" formula (Phase 5).
   - *Behavior:* scroll persistence; modal focus trap; tab order matches visual layout (manual, §2 checklist).
3. **`skills/ui-component-build/skill.md`** — task template gains the **self-revision loop**: `generate → render → assert → fix → re-assert (max 2 iterations)`; iteration results logged to task Notes (honest verdicts, incl. regression introduced by a fix — open-codesign lesson).
4. **`resources/web-research-2026.md`** §3/§6 — add Midscene row (currently only in §6.2 browser list) + reference the assertion catalog.
5. **Demo proof:** run `vision` assertions on one `examples/` screen; record pass/fail + screenshot in `.work.ui/reports/`.

**Acceptance:** demo run produces an honest pass/fail report; `framework-verify.sh` PASS; docs state BYOK + opt-in clearly.

**Risks:** API-key cost variance (mitigate: self-hostable Qwen-VL/UI-TARS via Ollama); assertion flakiness (pin models, keep assertions atomic); browser control is opt-in by policy — skill must never auto-launch a browser.

---

### Phase 2 — Token truth pipeline (DTCG + compile)

**Objective:** Make **one token source of truth** (DTCG JSON) that is machine-validated and compiled to platform code — eliminating token drift between design docs, CSS, and components.

**Value:** Cross-screen UIX consistency; token contract becomes checkable (extends `token-lint`); no magic values survive.

**Legal:** W3C DTCG (open standard) ✓; Style Dictionary **Apache-2.0** ✓; color.js **MIT** ✓; Leonardo **Apache-2.0** ✓; Tailwind v4 (MIT) as reference.

**Changes:**
1. **`skills/ui-design-foundation/skill.md`** — `greenfield` emits `.work.ui/design-system/tokens.json` in **DTCG 2025.10** shape (`$type`/`$value`, aliases, composite types: typography/border/shadow/gradient) as the canonical source; `tokens.css` becomes generated output (documented, not hand-edited).
2. **New `scripts/token-schema-verify.sh`** — validates `tokens.json` against the DTCG shape (required `$type`/`$value`, no duplicate names, aliases resolve, no raw hex outside color tokens — mirrors token-lint philosophy). Wired into `framework-verify.sh` self-tests + `@ui-visual-verify milestone`.
3. **`skills/ui-design-system/skill.md`** — document the Style Dictionary v4 compile step (`tokens.json` → CSS/JS via SD, custom transforms for naming conventions); CATALOG rows reference token names.
4. **`standards/20260523-DESIGN_TOKENS_STANDARD.md`** — add: "Source of truth = DTCG `tokens.json`; platform output (CSS/JS) is generated; authoring guidance: OKLCH, contrast-by-construction (Leonardo), fluid type via `clamp()` (Utopia)".

**Acceptance:** schema check passes on the demo `tokens.json`; token-lint unchanged (still passes); `framework-verify.sh` PASS; a generated token change is traceable to one JSON edit.

**Risks:** Migrating existing adopter `tokens.css` (mitigate: generation path ships in templates, documented upgrade note); DTCG preview-vs-published drift (pin 2025.10, per §7).

---

### Phase 3 — Brand design-system contract (DESIGN.md pattern)

**Objective:** Give the framework a **brand-grade design-system contract** so agent-generated UI matches a real brand — the direct answer to "no generic AI chrome".

**Value:** Website design that is on-brand, differentiated, and reusable; turns brand assets into enforceable tokens.

**Legal:** Open Design **Apache-2.0** — adopt the *schema pattern* (structure/ideas), keep attribution, do not copy their proprietary skills wholesale. Bundled template is our own original content.

**Changes:**
1. **New template** `templates/work.ui/plans/foundation/03-design-system.brand.template.md` (optional brand-grade extension of foundation doc 03), sections:
   1. Brand essence & positioning (one line + proof points)
   2. Logo & asset usage (safe areas, misuse rules, asset provenance + licenses)
   3. Color tokens (semantic, OKLCH, contrast targets)
   4. Typography (scale, pairing, font license per Fontsource)
   5. Spacing & layout (fluid scale, grid)
   6. Components (primitives → CATALOG binding)
   7. Voice & tone (link COPY_STANDARD §1)
   8. Motion (MOTION_STANDARD)
   9. Provenance & licenses (every asset's license — commercial-safe only)
   - **Handoff-shape reference:** Open CoDesign's Decompose-to-UI-Kit bundle (`ui_kits/<slug>/` = index + components + `tokens.css` + manifest) is cited as the reference shape for §6 component binding → handoff.
2. **`skills/ui-design-foundation/skill.md`** — `certify screen-spec-ready` accepts brand doc as optional input; `probe` dimension for brand clarity (dims D: brand/vision already covered — extend with brand-asset inventory).
3. **`skills/ui-design-system/skill.md`** — `init` can seed CATALOG from the brand doc (§3, §6).
4. **`APPROACH.md`** — design-system archetype: note optional brand doc.
5. **`skills/ui-component-build/skill.md`** — S0 primitives must bind to brand doc §3–§6 when present.

**Acceptance:** `bootstrap-test.sh` asserts the template ships; `framework-verify.sh` PASS; a demo brand doc renders a CATALOG with zero off-token values.

**Risks:** Over-strict branding for utilitarian projects (keep optional; craft tier ≥ refined / design-system archetype only); template must not balloon foundation docs (keep 9 compact sections).

---

### Phase 4 — Reference-image intake (design-to-code scaffold)

**Objective:** Optional fast path: reference image/mockup → initial code scaffold, then forced through UIS-06 re-skin + token-lint so output obeys the design system.

**Value:** Website redesigns and screen authoring start from real visuals instead of blank prompts — faster, more faithful.

**Legal:** screenshot-to-code **MIT** ✓ (self-hosted FastAPI, BYOK — OpenAI/Anthropic/Gemini; Gemini recommended for asset extraction). The agent never bundles their code; it runs a documented runbook against a self-hosted instance or the public API, output owned by the project.

**Changes:**
1. **`skills/ui-screen-spec/skill.md`** — new optional mode `intake - <image path/URL>` (distinct from text intake): classify → scaffold → re-skin → gate.
2. **New `docs/guides/reference-image-intake.md`** runbook:
   - Prereqs: self-hosted screenshot-to-code backend (MIT) or BYOK keys; documented in `REPLACE:UI_*` placeholders.
   - Flow: submit image → receive HTML/Tailwind/React scaffold → drop into `.work.ui/tmp/` → **mandatory re-skin gate**: map every color to tokens (token-lint, no raw hex), UIS-06 visual-quality pass, UIS-04 contrast check, responsive check UIS-02 → promote to `screens/<slug>/` only when gates pass.
   - Honesty rule: scaffold is a starting point, never a final artifact; asset extraction reuses real logos/images (screenshot-to-code pattern) but licenses must be verified (Phase 0). Handoff bundle structure mirrors Open CoDesign's Decompose-to-UI-Kit (see Phase 3 reference).
3. **`resources/web-research-2026.md`** §6 — already lists screenshot-to-code; add the runbook pointer.

**Acceptance:** runbook smoke test produces a scaffold that passes token-lint + UIS-06; `framework-verify.sh` PASS.

**Risks:** Quality varies by model (document: Gemini best for asset extraction; single-key setups degrade); image licensing — the intake prompt must assert the user owns rights to the reference image; never auto-commit scaffolds.

---

### Phase 5 — Copy quality rubric (encode, don't restate)

**Objective:** Move `ui-copy` from "write copy" to "write copy that passes known rubrics" — error formula, tone grading, inclusive language, cross-screen label consistency.

**Value:** Non-robotic, accessible, consistent UIX copy; label consistency becomes an a11y check (WCAG 3.2.4), not just style.

**Legal:** Polaris/Google/Microsoft/NN-g = **© link-only** (apply principles, no paste). WCAG = W3C. No CC-BY-NC sources (Mailchimp stays excluded).

**Changes:**
1. **New `skills/ui-copy/reference.md`** — rubric tables:
   - *Error formula:* what happened + why it matters + what to do next; banned words (invalid/illegal/failed/please try again); never blame; preserve input.
   - *Tone grading:* 3-column too-informal / just-right / too-formal (Google pattern) + "read aloud" self-check.
   - *Inclusive & i18n:* bias-free term list, 40% expansion allowance, RTL/logical-property rules (from COPY_STANDARD §8 + Microsoft).
   - *Action-label dictionary:* one verb per action; **cross-screen consistency check** (WCAG 3.2.4) — the same action must carry the same label everywhere.
2. **`standards/20260523-COPY_STANDARD.md`** — add one line: detailed rubrics in `ui-copy/reference.md`; standard remains the binding core.
3. **`skills/ui-copy/skill.md`** — `audit` mode checklist already condensed; add "cross-screen label consistency" row (Phase 5 rubric).

**Acceptance:** sample `ui-copy audit` on a demo screen reports consistent labels + tone grade; `framework-verify.sh` PASS.

**Risks:** Rubric bloat (keep tables tight; principles only); tone subjectivity (rubric anchors to concrete example pairs, not adjectives).

---

### Phase 6 — Eval harness + CI (measured quality)

**Objective:** Score agent UI output over time (Design2Code-style) and gate regressions at the UI boundary, not in prose grades.

**Value:** Turns "looks good" (prose, self-graded) into measured block/text/position/color match; data-viz rubric (FT Visual Vocabulary) gets automated backstop for UIS-09.

**Legal:** Design2Code **MIT** (metrics as method; approximate implementations documented honestly); FT Visual Vocabulary **MIT**; Playwright **Apache-2.0**; all browser use is CI/static tier (policy-compliant — no agent-driven browser).

**Changes:**
1. **New `scripts/ui-eval.sh`** — given a screen route + optional reference image: Playwright screenshot → metrics: block-match (bounding-box IoU), text-match, position-match, color-histogram match — **approximate** metrics (NOT CLIP/semantic similarity; directional signal only, never a pass/fail gate; humans decide on flags); output JSON to `.work.ui/reports/ui-eval-<screen>.json`; verdict pass/flag + human-review list.
2. **`.github/workflows/ui-eval.yml`** — nightly eval on `examples/` routes; fails on regression vs baseline (baseline stored in `.work.ui/reports/`); results posted to the workflow summary.
3. **`skills/ui-plan-verify/skill.md`** — new read-only mode `eval - <screen>`; feeds the `@ui-component-build complete` gate as advisory (never the sole gate).
4. **UIS-09 backstop:** chart-type rubric from FT Visual Vocabulary added to `concepts/data-visualization-quality/` (reject list: pie >3 segments, dual axes, truncated bar axes, radar misuse).

**Acceptance:** `ui-eval.sh` self-test inside `framework-verify.sh`; CI workflow green on the demo route; honest "approx metric" disclaimer in the report.

**Risks:** Metric noise on dynamic content (mask volatile regions like clocks/avatars via Playwright `stylePath`); false confidence — metrics flag, humans decide (verdict wording enforces this).

---


### Phase 7 — Agent MCP surface (ease of use)

**Objective:** Make the designer agent more capable and easier to use out of the box by documenting optional MCP tooling, with strict opt-in + license-safe defaults.

**Value:** One-config access to storybook query (design-system), browser verify (vision tier), and post-build audit; lowers the effort to adopt Phase 1/2/6.

**Legal:** Storybook MCP **MIT** ✓; Playwright MCP **Apache-2.0** ✓; Chrome DevTools MCP **Apache-2.0** ✓; all documented as optional config, nothing vendored. MPL-2.0 tools (axe-core/@axe-core/playwright) = consumer-dep only, never bundled (default a11y stays jest-axe **MIT**).

**Changes:**
1. **New `docs/guides/agent-mcp.md`** — config JSON snippets for the three MCP servers; tier table (static → CI → agent-browser, §8.2 gate); MPL-2.0 note; Framelink (MIT repo, commercial product) listed as reference-only.
2. **`skills/ui-bootstrap/skill.md`** — `init` output mentions the guide; no cursorrules edits (Agent OS owns base `.cursorrules`; UI additions only via the documented snippet path).
3. **`resources/web-research-2026.md`** §6 — pointer to the guide; `🌐 browser` tags on Playwright/DevTools MCP already present.

**Acceptance:** guide's JSON validates (JSON.parse in a framework-verify self-test optional); `bootstrap-test.sh` unchanged PASS; `framework-verify.sh` PASS.

**Risks:** MCP servers evolve fast (pin documented versions); token cost of accessibility-tree snapshots (README's own guidance — prefer CLI/SKILLS for coding agents; documented).

---

### Phase 8 — Python desktop UI skills (FLET + Qt) — *new capability*

**Objective:** Extend the `ui-*` skillset to design and build **Python desktop UIs** with **FLET** (Apache-2.0), **PySide6** (LGPL-3.0), and **PyQt6** (Riverbank — GPL/commercial, adopter's licensed choice) as **equal first-class stacks**. Same SPEC → tokens → build → verify loop as web/mobile; the framework itself requires **zero extra installations** — it only generates code; installing and running the generated app are documented adopter-environment steps.

**Value:** desktop-app coverage (native windows, tooling, data-heavy apps) with the same UIX quality gates (tokens, contrast, UIS-06/07/08); one design process across web, mobile, and desktop.

**Legal (verified 2026-07-31):**
- **FLET** — Apache-2.0 ✓ (bundled-safe; GitHub + LICENSE). Also ships its own `.agents/skills` — reference for our runbook.
- **PySide6** — LGPL-3.0-only ✓ (PyPI SPDX verified). Commercial + proprietary distribution allowed **without source disclosure** when used **unmodified** and **dynamically linked** (relink/header note documented in runbook). This is the **default Qt binding**.
- **PyQt6 (Riverbank)** — GPL-3.0-only OR commercial (PyPI SPDX verified). **First-class supported stack** — the framework license rule governs only *vendored* 3rd-party source, not the libraries generated code depends on. License note documented for adopters: free for development; for **production** or when **protecting source**, acquire Riverbank's **commercial PyQt license** (or release under GPL). The skill states this note but does **not** gate or discourage PyQt6.
- **Framework constraint:** skill = markdown + bash + **python3 stdlib only** (`py_compile`, `ast`) — no pip packages, no Qt/FLET needed for the framework itself to function and generate code. The skill **instructs** the adopter's install commands for all three stacks (`pip install flet[all]` / `pip install PySide6` / `pip install PyQt6`) in the runbook — nothing prevents these installations; they are user-environment steps (like other `REPLACE:UI_*` placeholders).

**Changes:**
1. **New skill `skills/ui-python-desktop/skill.md`** (registry id `ui-python-desktop`; `ui-{domain}-{role}` compliant), modes:
   - `stack set - flet | pyside6 | pyqt` — records `UI_DESKTOP_STACK` in HANDOFF_UI; **all three are first-class**; `pyqt` appends the license note (GPL vs commercial — dev/production) to the operator record, no gate.
   - `scaffold - <app-slug>` — generates runnable skeleton from tokens + approved screen SPEC: FLET (`app.py` + controls + `ft.Theme` from tokens) or Qt (`app.py` + `widgets/` + `QApplication` + QSS/palette from tokens); `py_compile`-clean by construction.
   - `component add - <name>` — primitive map: FLET controls (`ft.Button`, `ft.TextField`, `ft.DataTable`, `ft.NavigationRail`, dialogs…) / Qt widgets (`QPushButton`, `QLineEdit`, `QTableWidget`, `QListWidget`, `QDialog`…), styled with tokens, no default chrome (SURFACE-AND-CONTROL-CRAFT applies).
   - `verify - <path>` — **static tier**: `python3 -m py_compile` + `ast` parse + token-lint on `.py` (no raw hex) + UIS-06/07/08 rubric prompts; visual verify via runbook (user runs the app; optional Qt `QT_QPA_PLATFORM=offscreen` screenshot in the user env).
   - `status` — reports active desktop stack + catalog bindings.
2. **`ui-project-approach` + `APPROACH.md`** — new archetype `desktop-app` (Python) added to **both** the `APPROACH.md` §1 archetype table (row: `desktop-app` — native window, widgets, offline/data-heavy → chain via `@ui-python-desktop`) and `ui-project-approach/skill.md` classification; chain: `@ui-bootstrap` → approach → `@ui-design-foundation` → `@ui-screen-spec` → `@ui-python-desktop scaffold/component` → verify.
3. **`ui-director`** — new bucket `desktop` (signals: "desktop app", "PyQt", "FLET", "native window") → `ui-python-desktop`. **All three routing tables updated, not just the bucket:** `skills/ui-director/skill.md` bucket table + shortcut chains; `skills/ui-director/reference.md` §6 Common user request routing table (new row: "Build a desktop app" → `desktop` → `@ui-python-desktop scaffold - <slug>`); `skills/ui-process-router/reference.md` bucket list (new `desktop` bucket row); `skills/SKILL_DEPENDENCIES.md` dependency matrix + redirect cheat sheet.
4. **Exact registration rows** — `skills/README.md`: `| ui-python-desktop | ui-python-desktop/ | Design/build/verify Python desktop UIs (FLET, PySide6, PyQt6) | stack set · scaffold · component add · verify · status | Yes (code, HANDOFF_UI) | screen-spec-ready + tokens (Phase 2) |`. `SKILL_DEPENDENCIES.md`: dependency matrix row (`ui-python-desktop scaffold` → tokens doc + approved SPEC; `component add` → CATALOG binding), command vocabulary rows (`stack`, `scaffold`, `component`, `verify`), redirect cheat sheet row (`@ui-python-desktop scaffold - <slug>` → generates app skeleton).
8. **`skills/ui-style-stack/skill.md`** — `status` cross-reports `UI_DESKTOP_STACK` when set (desktop stack ownership stays with `ui-python-desktop stack set`; CSS stack contract unchanged). **`skills/ui-design-system/skill.md`** — `init`/`add` accept the desktop primitive map (FLET controls / Qt widgets) when `UI_DESKTOP_STACK` is set.
5. **`standards/20260523-DESIGN_TOKENS_STANDARD.md`** — desktop binding: tokens emitted as `tokens.py` constants / FLET `ThemeData` / Qt palette + QSS; **`scripts/token-lint.sh` extended to scan `.py`** (same no-raw-hex rule).
6. **New `docs/guides/python-desktop-runbook.md`** — adopter-env steps for all three stacks: `pip install flet[all]` / `pip install PySide6` / `pip install PyQt6`; `flet run app.py` / `python app.py`; screenshot for visual verify; packaging (FLET built-in build; PyInstaller GPL+exception note for Qt); PyQt6 license note (dev free; commercial license for production/protected source) — all clearly marked as **user environment, not framework requirement**; no rule prevents these installs.
7. **`resources/web-research-2026.md`** — new §10 "Python desktop" rows: FLET (Apache-2.0), PySide6 (LGPL-3.0), PyQt6 (GPL/commercial — license note; first-class stack, not an exclusion).

**Acceptance:** `framework-verify.sh` PASS; `bootstrap-test.sh` PASS (skill ships); generated skeletons for **all three stacks** (FLET, PySide6, PyQt6) `py_compile` clean and pass token-lint **with only python3 stdlib available** (no pip install — proves the framework-zero-install constraint); `ui-director` routes "desktop app" → `ui-python-desktop`; **18/18 skills locatable** (verified by `framework-verify.sh` skill-count derivation + `skills/README.md` row count).

**Risks:** Qt licensing nuance (LGPL relink obligation documented; PyQt GPL flagged before every use); platform-specific Qt runtime needs in user env (documented per-OS); FLET API churn (pin doc version; control map is small).

---

## Part D — Sequencing, effort, dependencies

| Order | Phase | Effort | Value (UXI/website) | Areas touched | Depends on |
|-------|-------|--------|---------------------|---------------|------------|
| 1 | **P0** license standard | S | compliance / safety | standards/, scripts/ | — |
| 2 | **P1** vision-verify | M | ★★★★★ rendered-UI truth | skills/, resources/, .work.ui/ | P0 (tags) |
| 2 | **P2** token pipeline | M | ★★★★ consistency | skills/, scripts/, standards/, templates/ | P0 |
| 3 | **P3** brand DESIGN.md | M | ★★★★★ brand-grade websites | templates/, skills/, APPROACH.md | P2 (tokens) |
| 4 | **P4** image intake | M | ★★★★ faithful redesigns | skills/, docs/, resources/ | P2 (token gate) |
| 5 | **P5** copy rubric | S | ★★★ copy quality | skills/, standards/ | — |
| 5 | **P7** MCP surface | S | ★★★ ease of use | docs/, skills/ | P0, P1 |
| 5 | **P8** python desktop (FLET/Qt) | M | ★★★★ desktop UIX + website-adjacent apps | skills/, standards/, scripts/, docs/, resources/ | P2 (tokens), P3 (brand) |
| 6 | **P6** eval harness | M | ★★★★ measured quality | scripts/, .github/, skills/, concepts/ | P1 (screenshots) |

Parallelizable: (P1 ∥ P2), (P5 ∥ P7). Total ≈ 8–12 focused work sessions, each independently shippable.

**Per-phase gates (mandatory):** `framework-verify.sh` PASS · `bash -n` on new scripts · touch-scope declared · **own commit** (≤2 blast-radius areas) · CHANGELOG `[Unreleased]` entry · HANDOFF_UI session note.

---

## Part E — Exclusions (documented, do not integrate)

| Item | Reason |
|------|--------|
| bolt.diy | WebContainers API needs a **commercial license** for production use (MIT source is not enough); standalone env by design |
| PyQt6 (Riverbank) **source vendored into skills/standards** | GPL-3.0-only — 3rd-party source must **not** be copied into framework files (license rule). As a **generated-code dependency** it is the adopter's licensed choice: free in development; commercial Riverbank license (or GPL release) for production/protected source |
| Open CoDesign | Standalone Electron desktop app; not a headless library (keep as *reference* for Decompose-to-UI-Kit handoff shape) |
| Mailchimp style guide | CC-BY-NC 4.0 — non-commercial |
| Microcopy book (Yifrah) | Paid, all-rights-reserved |
| Percy, Chromatic (required tier), Tokens Studio | Commercial SaaS without a free OSS baseline path (Playwright snapshots / Style Dictionary are the OSS defaults) |
| Framelink (Figma) | MIT OSS repo but commercial product — reference-only, never a framework dependency |
| axe-core / @axe-core/playwright (vendored) | MPL-2.0 — allowed only as consumer-side unmodified dependencies, never bundled into the framework |
| APCA / WCAG 3.0 | Drafts — direction only, never pass/fail gates (WCAG 2.2 stays the gate) |
| GPL/LGPL-licensed libraries | Copyleft conflicts with the commercial/no-disclosure rule |

---

## Part F — Assumption ledger

| Class | Items |
|-------|-------|
| **Confirmed** | All 6 feedback-file repo verdicts (fetched 2026-07-31); licenses: midscene MIT, copilotkit MIT, screenshot-to-code MIT, open-design Apache-2.0, bolt.diy MIT-source+WebContainers license, open-codesign MIT; jest-axe MIT, style-dictionary Apache-2.0, color.js MIT, leonardo Apache-2.0, playwright Apache-2.0, storybook MIT, design2code MIT, FT chart-doctor MIT, W3C TR citable; **FLET Apache-2.0, PySide6 LGPL-3.0-only, PyQt6 GPL-3.0-only/commercial** (all PyPI/GitHub-verified 2026-07-31). **Scope ruling (owner):** license rule applies to vendored 3rd-party source only — generated-code dependencies (FLET/PySide6/PyQt6) are the adopter's licensed choice; PyQt6 is a first-class stack (dev free; commercial license for production/protected source) |
| **Inference** | DESIGN.md 9-section schema transfers cleanly to our foundation-doc shape; vision assertions (midscene) are stable enough for a demo run; eval metric approximations (no CLIP) remain meaningful directional signals |
| **Unknowns** | Per-run API costs for the vision tier at team scale; model-dependent screenshot-to-code quality variance; future MCP-server API drift; DTCG spec evolution past 2025.10 |

## Part G — Completion criteria (whole plan)

- All phases landed with per-phase gates green; `framework-verify.sh` PASS on main.
- Every `resources/` entry license-tagged; §7 exclusions complete.
- Demo proof artifacts exist: vision-verify run report, DTCG token JSON + compiled CSS, one brand doc → CATALOG, one image-intake scaffold that passes token-lint + UIS-06, one eval report, MCP guide.
- CHANGELOG `[Unreleased]` + HANDOFF_UI document each phase.
- No commit/push without explicit owner request.
