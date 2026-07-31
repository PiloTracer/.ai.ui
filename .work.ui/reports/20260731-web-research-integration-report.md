# Web research integration — verification report (2026-07-31)

**Scope:** Audit and integration of `resources/web-research-2026.md` into the UI Design OS (`.ai.ui`) framework — license compliance, static-first verify policy, browser opt-in authorization, and skill/director wiring.

**Canonical catalog:** [`resources/web-research-2026.md`](../../resources/web-research-2026.md)

---

## Executive summary

| Gate | Result | Evidence |
|------|--------|----------|
| `bash scripts/framework-verify.sh` | **PASS** | Link scan, bootstrap, deploy selftests |
| In-repo availability | **PASS** | `resources/web-research-2026.md` + `resources/README.md` index |
| `ui-director` wiring | **PASS** | skill §6 + `reference.md` §9–10 |
| Skill consistency | **PASS** | 5 mapped skills + `ui-component-build` verify policy |
| Static-first verify | **PASS** | Browser policy + §8.2 in doc and skills |
| License compliance | **PASS** | §7 exclusions; commercial-safe policy enforced |
| Local link integrity | **PASS** | `framework-verify` markdown scan |

**Uncommitted at report time:** 15 modified files + 1 new (`resources/web-research-2026.md`). No commit performed.

---

## Framework wiring

| Entry point | Status | What was added |
|-------------|--------|----------------|
| `resources/web-research-2026.md` | ✅ New canonical catalog | 6 topic §§ + license + browser policies |
| `resources/README.md` | ✅ Index | Pointer + policies |
| `README.md` | ✅ Root map | Row in framework assets table |
| `START_HERE.md` | ✅ Operator tree | §7 verify policy + reading order step 7 |
| `skills/README.md` | ✅ Registry | External research pointer |
| `SKILL_DEPENDENCIES.md` | ✅ Redirect | Research → `web-research-2026.md` |
| `ui-director` | ✅ Orchestrator | §6 resources/verify policy + See also |
| `ui-director/reference.md` | ✅ §9–10 | Resource index + skill→§ map |
| `ui-process-router` | ✅ Router | `research` bucket |
| `ui-design-foundation` | ✅ §1 link | External resources block |
| `ui-accessibility-audit` | ✅ §2 + tiers | Static default / browser opt-in |
| `ui-visual-verify` | ✅ §3+§6 + tiers | Verification tiers |
| `ui-design-system` | ✅ §4 link | External resources block |
| `ui-copy` | ✅ §5 link | §8.1 + §8.2 aligned |
| `ui-component-build` | ✅ Verify policy | Static-first at `complete` gate |

All functionality is **in-repo** at `resources/web-research-2026.md` — discoverable from director, router, START_HERE, and mapped skills without external fetch to discover them.

---

## Policies encoded

### License (commercial-safe baseline)

- **Accept:** MIT, Apache-2.0, BSD, CC0, MPL-2.0 (unmodified audit deps), W3C TR, free-read articles (principles only)
- **Reject:** CC-BY-NC, paid books, required paid SaaS tiers, GPL/LGPL as platform baseline

### Browser control (agent sessions)

| Tier | Examples | Agent default |
|------|----------|---------------|
| **Static (preferred)** | WCAG/APG rubrics, jest-axe, token-lint, color.js, Storybook build | ✅ Use without asking |
| **CI / project scripts** | `REPLACE:UI_VISUAL_TEST`, `REPLACE:UI_A11Y_TOOL` | Run only when project defines them |
| **Agent browser control** | Playwright MCP, DevTools MCP, `playwright-cli`, live navigate/screenshot | ❌ Requires **explicit operator authorization** (§8.2) |

---

## Skill → research § map

| Research § | Primary `@` skills | Static default | Browser opt-in |
|------------|-------------------|----------------|----------------|
| §1 Tokens/color | `ui-design-foundation`, UIS-04 | DTCG JSON, OKLCH, color.js, token-lint | — |
| §2 Accessibility | `ui-accessibility-audit` | jest-axe, WCAG/APG rubric, manual checklist | `@axe-core/playwright`, Lighthouse, Playwright MCP |
| §3 Visual QA | `ui-visual-verify`, `ui-concept-run` (UIS-01/08/09) | NN/g, Laws of UX, GoodUI, FT Vocabulary | Playwright snapshots, Chromatic (CI) |
| §4 Design systems | `ui-design-system` | Storybook MCP, Open UI, Style Dictionary | Framelink Figma MCP |
| §5 UX writing | `ui-copy` | Polaris/Google/Microsoft tone rubrics | — |
| §6 Agent verify | `ui-visual-verify`, `ui-plan-verify` | Static checklists, Design2Code metrics | Playwright MCP, DevTools MCP (authorized) |
| Behavior OSS | `ui-design-system`, `ui-component-build` | `control-platforms.md` | — |

---

## §1 — Tokens & color → `ui-design-foundation`, DESIGN_TOKENS_STANDARD, UIS-04

| Resource | URL | Notes |
|----------|-----|-------|
| W3C DTCG Design Tokens (2025.10) | https://www.designtokens.org/TR/2025.10/format/ | ✔ Pin 2025.10 — not `tr.designtokens.org` preview |
| OKLCH in CSS (Evil Martians) | https://evilmartians.com/chronicles/oklch-in-css-why-quit-rgb-hsl | ✔ |
| color.js | https://colorjs.io/ | ✔ |
| APCA contrast | https://apcacontrast.com/ | ✔ Cross-check only; WCAG 2.x remains gate |
| Radix Colors | https://www.radix-ui.com/colors | ✔ |
| Leonardo | https://leonardocolor.io/ | ✔ npm `@adobe/leonardo-contrast-colors` |
| Utopia (fluid type/space) | https://utopia.fyi/ | ✔ |
| Style Dictionary | https://styledictionary.com/ | ✔ |
| Tailwind v4 colors | https://tailwindcss.com/docs/colors | ✔ OKLCH `--color-*` |
| Tokens Studio | https://tokens.studio/ | ▶ SaaS — pipeline concepts only |

---

## §2 — Accessibility → `ui-accessibility-audit`, ACCESSIBILITY_STANDARD

| Resource | URL | Agent default |
|----------|-----|---------------|
| WCAG 2.2 | https://www.w3.org/TR/WCAG22/ | ✅ static |
| WCAG 3.0 draft | https://www.w3.org/TR/wcag-3.0/ | ✅ static (direction only) |
| ARIA APG | https://www.w3.org/WAI/ARIA/apg/ | ✅ static |
| jest-axe v11 | https://www.npmjs.com/package/jest-axe | ✅ **agent default** |
| axe-core | https://github.com/dequelabs/axe-core | ✅ static (MPL-2.0) |
| @axe-core/playwright | https://www.npmjs.com/package/@axe-core/playwright | CI / authorized 🌐 |
| Lighthouse a11y | https://developer.chrome.com/docs/lighthouse/accessibility/scoring | CI / authorized 🌐 |
| A11Y Project checklist | https://www.a11yproject.com/checklist/ | ✅ static |
| WebAIM WCAG 2 checklist | https://webaim.org/standards/wcag/checklist | ✅ static |
| WebAIM Million 2026 | https://webaim.org/projects/million/ | ✅ static |
| WAI-ARIA 1.2 | https://www.w3.org/TR/wai-aria-1.2/ | ▶ docs-only |

**Manual checklist blind spots:** focus trap/tab order, `aria-live`, 200% zoom/reflow, contrast over images/video.

---

## §3 — Visual QA → `ui-visual-verify`, UI-PATTERNS, UIS-01/08/09

| Resource | URL | Agent default |
|----------|-----|---------------|
| NN/g 10 Usability Heuristics | https://www.nngroup.com/articles/ten-usability-heuristics/ | ✅ **agent default** |
| Laws of UX | https://lawsofux.com/ | ✅ static © link-only |
| NN/g Principles of Visual Design | https://www.nngroup.com/articles/principles-visual-design/ | ▶ docs-only |
| Baymard Institute (free) | https://baymard.com/free-ux-research | ✅ static § account |
| GoodUI | https://goodui.org/ | ✅ static |
| FT Visual Vocabulary | https://github.com/Financial-Times/chart-doctor/tree/main/visual-vocabulary | ✅ static |
| Datawrapper Academy | https://academy.datawrapper.de/ | ✅ static |
| Storybook visual tests | https://storybook.js.org/docs/writing-tests/visual-testing | CI / authorized 🌐 |
| Playwright snapshots | https://playwright.dev/docs/test-snapshots | CI / authorized 🌐 |
| Chromatic | https://www.chromatic.com/features/visual-test | optional SaaS 🌐 |

---

## §4 — Design systems → `ui-design-system`, `control-platforms.md`, CATALOG

| Resource | URL | Notes |
|----------|-----|-------|
| Storybook MCP | https://storybook.js.org/docs/ai/mcp | ✔ Query before inventing primitives |
| Framelink MCP (Figma) | https://github.com/GLips/Figma-Context-MCP | ✔ MIT OSS repo |
| Open UI | https://open-ui.org/ | ✔ |
| Style Dictionary v4 | https://styledictionary.com/ | ✔ |
| Iconify | https://iconify.design/ | ✔ Verify per-set license |
| Fontsource | https://fontsource.org/ | ✔ |
| W3C Web Components | https://www.w3.org/TR/custom-elements/ | ▶ docs-only |
| Design Better handbook | https://www.designbetter.co/design-systems-handbook | ⚠ unverified this run |
| EightShapes | https://eightshapes.com/ | ⚠ unverified this run |

---

## §5 — UX writing → `ui-copy`, COPY_STANDARD

| Resource | URL | Notes |
|----------|-----|-------|
| NN/g Error Messages | https://www.nngroup.com/articles/error-message-guidelines/ | ✔ |
| Shopify Polaris content | https://polaris.shopify.com/content | ✔ |
| Google style — tone | https://developers.google.com/style/tone | ✔ |
| Microsoft Writing Style Guide | https://learn.microsoft.com/en-us/style-guide/welcome/ | ✔ |
| WCAG 3.2.4 Consistent ID | https://www.w3.org/WAI/WCAG22/Understanding/consistent-identification.html | ✔ |
| Writing Microcopy (Porter) | http://bokardo.com/archives/writing-microcopy/ | ✔ © link-only |

**Do not cite:** NN/g empty-states article (404) — https://www.nngroup.com/articles/empty-states/

---

## §6 — Agent integration → `ui-visual-verify`, eval harness

### 6.1 Static verify & eval (preferred)

| Resource | URL |
|----------|-----|
| Claude Code Best Practices | https://www.anthropic.com/engineering/claude-code-best-practices |
| screenshot-to-code | https://github.com/abi/screenshot-to-code |
| Design2Code benchmark | https://github.com/NoviScl/Design2Code |

### 6.2 Browser control (opt-in — operator authorization required)

| Resource | URL |
|----------|-----|
| Playwright MCP | https://github.com/microsoft/playwright-mcp |
| Chrome DevTools MCP | https://github.com/ChromeDevTools/chrome-devtools-mcp |
| VisualWebArena | https://github.com/web-arena-x/visualwebarena |

---

## §7 — Excluded (documented, not incorporated)

| Resource | URL | Reason |
|----------|-----|--------|
| Mailchimp Content Style Guide | https://styleguide.mailchimp.com/ | CC-BY-NC 4.0 |
| Microcopy: The Complete Guide (Yifrah) | https://microcopybook.com/ | Paid / all-rights-reserved |
| Percy | https://www.percy.io | Commercial SaaS |
| Baymard paid catalog | https://baymard.com/pricing | Full library requires subscription |

---

## License audit fixes applied

| Resource | Issue | Resolution |
|----------|-------|------------|
| Mailchimp Style Guide | CC-BY-NC | Moved to §7 exclusions |
| Yifrah Microcopy book | Paid / © | Moved to §7 exclusions |
| Percy | Commercial SaaS | Moved to §7 exclusions |
| Baymard | Full catalog paid | Retargeted to `/free-ux-research`; `§ account` tag |
| Chromatic | Commercial hosted | Tagged SaaS; Playwright/static rubric default |
| Tokens Studio | Commercial product | Tagged SaaS; Style Dictionary OSS baseline |
| Porter microcopy URL | Original path 404 | Fixed → `bokardo.com/archives/writing-microcopy/` |
| axe-core | MPL-2.0 | Explicitly tagged; acceptable as audit dep |

---

## Uncommitted files (at report generation)

| File | Change |
|------|--------|
| `resources/web-research-2026.md` | New |
| `resources/README.md` | Modified |
| `README.md` | Modified |
| `START_HERE.md` | Modified |
| `skills/README.md` | Modified |
| `skills/SKILL_DEPENDENCIES.md` | Modified |
| `skills/ui-accessibility-audit/skill.md` | Modified |
| `skills/ui-component-build/skill.md` | Modified |
| `skills/ui-copy/skill.md` | Modified |
| `skills/ui-design-foundation/skill.md` | Modified |
| `skills/ui-design-system/skill.md` | Modified |
| `skills/ui-director/reference.md` | Modified |
| `skills/ui-director/skill.md` | Modified |
| `skills/ui-process-router/reference.md` | Modified |
| `skills/ui-visual-verify/skill.md` | Modified |
| `.gitignore` | Modified (host/tooling artifacts) |

---

## Assumption ledger

| Class | Items |
|-------|-------|
| **Confirmed** | `framework-verify` PASS; Mailchimp CC-BY-NC; Yifrah paid; Porter archives URL HTTP 200; Baymard free page account-gated |
| **Inference** | NN/g, GoodUI, Polaris docs are `© link-only` (principles OK, no paste) — not individually re-fetched this session |
| **Unknowns** | External URL health beyond Porter/Baymard spot-checks — §8.1 requires per-cite fetch on use |

---

## Next steps (operator)

1. Review uncommitted diff; commit when ready (`feat: integrate web-research-2026 resources into framework`).
2. On framework release, re-run §8.1 URL verification for any newly cited external links.
3. Adopter repos: `web-research-2026.md` ships with `.ai.ui/` via `deploy-files` / `deploy-repo` — no separate install step.

---

## Deployment readiness assessment (2026-07-31)

Cross-checked against [`.work.ui/reports/20260707-ui-improvement-plan.md`](20260707-ui-improvement-plan.md) follow-up scan.

### Verdict matrix

| Layer | Ready? | Evidence |
|-------|--------|----------|
| **Committed HEAD (`b9b73c0`)** | ✅ **Yes** — adopter deploy | `framework-verify` PASS; deploy-files/repo/basic selftests PASS; CI workflow present; improvement-plan artifacts verified |
| **Pending web-research integration** | ⚠ **No** — pre-commit/release | 16 uncommitted paths across 5 areas; `blast-radius-check` FAIL; `CHANGELOG [Unreleased]` empty; integration report untracked |
| **Formal version tag (`release.sh`)** | ⚠ **No** — until release prep | Requires version section in CHANGELOG + clean tree; `[Unreleased]` has no entries for web-research |

### Improvement plan (2026-07-07) — consistency

| Claim in plan | Re-verified 2026-07-31 |
|---------------|------------------------|
| Change-safety scripts created | ✅ All 3 scripts + template exist |
| Git hooks + Co-authored-by enforcement | ✅ 4 hooks; `install-git-hooks` installs |
| 12 defect fixes applied | ✅ Spot-checked: post-commit path, gate-verify awk, blast-radius exit 1 |
| `framework-verify` passes | ✅ PASS (full run) |
| Deferred: `smoke-consumer.sh` | ✅ Still deferred — acceptable; CI runs `framework-verify` + bootstrap-test |

No regressions found against the 2026-07-07 plan on committed code.

### Congruence checks (framework operational)

| Area | Status |
|------|--------|
| Skill registry (17 `ui-*`) | ✅ `skills/README.md` + framework-verify skill count |
| Director → skills → resources | ✅ `ui-director` §6 + reference §9–10; 5 mapped skills + component-build |
| Process router `research` bucket | ✅ `ui-process-router/reference.md` |
| START_HERE reading order | ✅ Step 7 → `web-research-2026.md` (pending commit) |
| License + browser policies | ✅ In doc + skills (pending commit) |
| Local markdown links | ✅ framework-verify link scan PASS |

### Blockers before shipping pending work

1. **Commit** web-research integration (or split into ≤2-area PRs to satisfy blast-radius).
2. **CHANGELOG** — add `[Unreleased]` entries for `web-research-2026.md` + skill wiring.
3. **Track** `20260731-web-research-integration-report.md` (add to commit or keep as demo `.work.ui/` artifact per project policy).
4. **Optional:** Add `session-*.md` to `.gitignore` (untracked scratch at repo root).

### Recommended deploy path (today)

| Target need | Command | Ships |
|-------------|---------|-------|
| Full framework copy | `@deploy-files copy - <path>` or `deploy-repo clone` | Committed HEAD only (excludes uncommitted web-research) |
| Thin client | `@deploy-basic - <path>` | `.cursorrules` + `.work.ui/` skeleton |
| After web-research commit | Re-run `framework-verify` → deploy | Full catalog + skill wiring |

**Bottom line:** UI Design OS is **operationally ready to deploy at committed HEAD**. The framework is **not release-tag ready** for the web-research batch until committed, documented, and blast-radius resolved.
