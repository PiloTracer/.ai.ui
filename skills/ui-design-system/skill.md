---
name: ui-design-system
description: >-
  Maintain primitives catalog, Storybook coverage, and variant API consistency.
  Use init, add - <component>, status.
---

# ui-design-system

## Modes

| Mode | Action |
|------|--------|
| `init` | Create or refresh `<repo-root>/.work.ui/design-system/CATALOG.md` from foundation doc 03 — seeds from the brand doc (`*-03-design-system.brand.md` §3/§6) when present |
| `add - <component>` | Add primitive: file + story + catalog row per COMPONENT_STANDARD |
| `status` | Missing stories, deprecated components |

## Prerequisites

- Tokens doc exists (`ui-design-foundation` doc 02)

## Hard rules

- New primitives need Storybook default + a11y note
- Variants documented in CATALOG before use in screens
- Cite **example id** from manifests when visual target exists
- Craft tier ≥ refined: optional **behavior source** from [`resources/control-platforms.md`](../../resources/control-platforms.md) in CATALOG; style stays project tokens
- **Token compile:** DTCG `tokens.json` → Style Dictionary v4 → platform files; CATALOG rows reference token **names**, never literals

## External resources

Curated references: [`resources/web-research-2026.md`](../../resources/web-research-2026.md) §4 — apply its license policy + rules ([§8.1](../../resources/web-research-2026.md#81-verify-resource-urls-skill-rule), [§8.2](../../resources/web-research-2026.md#82-browser-control-authorization-skill-rule)). Query Storybook MCP before inventing primitives.
