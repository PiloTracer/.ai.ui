---
name: ui-accessibility-audit
description: >-
  WCAG-oriented audits per screen or milestone. Use screen - <slug> or milestone
  before ui-component-build complete.
---

# ui-accessibility-audit

**Standard:** `REPLACE:UI_ACCESSIBILITY_FILE` (ACCESSIBILITY_STANDARD template)

## Modes

| Mode | Action |
|------|--------|
| `screen - <slug>` | Audit against approved screen SPEC §9 |
| `milestone` | All screens in active NEXT_UI iteration |
| `status` | Last findings summary |

## Tooling

**Default (static):** jest-axe / axe rule review + WCAG/APG rubric + manual checklist (§2 of [`web-research-2026.md`](../../resources/web-research-2026.md)) — no live browser in agent session.

**CI / configured:** Run `REPLACE:UI_A11Y_TOOL` in container per `.cursorrules` when the project defines it.

**Browser control (opt-in):** `@axe-core/playwright`, Lighthouse, Playwright MCP — only after **explicit operator authorization** ([§8.2](../../resources/web-research-2026.md#82-browser-control-authorization-skill-rule)). State tool + scope; wait for confirmation.

## External resources

Curated references: [`resources/web-research-2026.md`](../../resources/web-research-2026.md) §2 — apply its license policy + rules ([§8.1](../../resources/web-research-2026.md#81-verify-resource-urls-skill-rule), [§8.2](../../resources/web-research-2026.md#82-browser-control-authorization-skill-rule)).

## Verdict

- **critical** findings → fail (block complete)
- **serious** → pass with gaps only if HANDOFF_UI documents waiver + owner

Pair with UIS-04 when color tokens changed in same milestone.
