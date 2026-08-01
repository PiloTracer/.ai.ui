---
name: ui-visual-verify
description: >-
  Visual and design-token verification: milestone, uncommitted. Use before
  ui-component-build complete and before UI PR merge.
---

# ui-visual-verify

**Craft standard:** `standards/20260523-SURFACE-AND-CONTROL-CRAFT.md` §7

## Modes

| Mode | When |
|------|------|
| `milestone` | End of UI milestone S{N} |
| `uncommitted` | Dirty UI paths before commit |
| `vision - <route>` | Rendered-UI assertions (opt-in §8.2 — requires explicit operator authorization) |
| `status` | Read-only last report |

## Checks (milestone)

**Verification tiers** (see [`web-research-2026.md`](../../resources/web-research-2026.md) browser policy): run **static** checks first (items 2–7 below, rubrics in §3). Item 1 (`REPLACE:UI_VISUAL_TEST`) runs only when the project defines it. **Do not** launch Playwright MCP, DevTools MCP, or live browser screenshots unless the operator has **explicitly authorized** browser control ([§8.2](../../resources/web-research-2026.md#82-browser-control-authorization-skill-rule)).

1. `REPLACE:UI_VISUAL_TEST` exit 0 when configured (or documented baseline update with owner approval) — typically CI/browser; not an agent default
2. **Token contract (machine):** `bash .ai.ui/scripts/token-lint.sh --tokens REPLACE:UI_TOKENS_FILE REPLACE:UI_APP_ROOT` exits 0 — no raw hex/color literals in component source (DESIGN_TOKENS_STANDARD). This is the deterministic backstop: an agent that hardcoded a color fails here, not in a prose grade. One-off exceptions need a trailing `token-lint-ignore` with a reason.
3. Token file unchanged without accompanying visual diff review
4. Storybook/build for UI package passes
5. UIS registry: no `Applies=yes` + `pending`
6. **Craft / §13 compliance** (per active screen SPECs in milestone):

| Check | Fail when |
|-------|-----------|
| exampleIds | Missing in §13 when craft tier ≥ refined (no HANDOFF waiver) |
| extractedRules | §11 bullets not reflected in UI (spot-check) |
| Native controls | Browser-default range/select/checkbox on flows where §8 requires catalog primitive |
| Surfaces | Flat-only page when tier ≥ refined and SPEC requires `--surface-elevated` cards |
| BEFORE compare | `beforeScreenshot` in §13 but no visible improvement on cited rules (manual/vision) |

7. **UIS-07** run when craft tier ≥ refined (`@ui-concept-run - UIS-07`)
8. **Vision tier (opt-in):** after **explicit operator authorization** (§8.2 — state tool, route(s), actions; wait for confirmation), run `vision - <route>` against the assertion catalog in [`reference.md`](reference.md) (layout, color/contrast, state, behavior groups). Report pass/fail per assertion; honest verdicts incl. regressions introduced by a fix. Never auto-launch a browser.

## Vision tier (rendered-UI assertions)

Validates **what users actually see** (rendered pixels + live behavior), which DOM/static checks cannot. Catalog: [`reference.md`](reference.md) § Vision assertion catalog.

**Gate:** browser control is opt-in-only — see browser policy ([§8.2](../../resources/web-research-2026.md#82-browser-control-authorization-skill-rule)). BYOK multimodal model (self-hostable Qwen-VL / UI-TARS via Ollama, or Qwen/Gemini/GLM API).

## Output

Verdict: **pass** | **pass with gaps** | **fail** — gaps need HANDOFF_UI waiver line.

Include section:

```markdown
### Craft compliance
- SPECs checked: …
- §13 exampleIds: ok | gaps
- Native control violations: none | …
- UIS-07: done | pending | N/A
```

**Does not** replace `@ui-accessibility-audit`.

**Encourage:** register BEFORE/AFTER in `inputs/design-references/` for regression context.

## External resources

Curated references: [`resources/web-research-2026.md`](../../resources/web-research-2026.md) §3 + §6 — apply its license policy + rules ([§8.1](../../resources/web-research-2026.md#81-verify-resource-urls-skill-rule), [§8.2](../../resources/web-research-2026.md#82-browser-control-authorization-skill-rule)). **Default path:** static rubrics + token-lint + Storybook build; browser control opt-in only.
