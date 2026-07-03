# Responsive & Breakpoint Standard — template

> Binding breakpoints, container strategy, and touch-target rules for all UI shipped through UI Design OS.

**Pairs with:** UIS-02 (`responsive-layout/`), `REPLACE:UI_DESIGN_TOKENS_FILE`, screen SPECs §4 (Layout & hierarchy)

---

## 1. Breakpoint scale (required in foundation doc 02)

Define a single canonical breakpoint scale. Skills emit responsive code against these names — not ad-hoc pixel values.

| Token | Default | Purpose |
|-------|---------|---------|
| `--bp-sm` | `640px` | Phone → large phone |
| `--bp-md` | `768px` | Large phone → tablet |
| `--bp-lg` | `1024px` | Tablet → desktop |
| `--bp-xl` | `1280px` | Desktop → wide |
| `--bp-2xl` | `1536px` | Wide → ultra-wide (optional) |

Override defaults in foundation doc 02; document rationale when deviating by >10%.

## 2. Approach

| Rule | Detail |
|------|--------|
| **Mobile-first** | Base styles target `--bp-sm` and below; `min-width` media queries add complexity upward |
| **Container queries** | Preferred for component-level responsiveness when browser support permits; document fallback |
| **No device targeting** | Use breakpoint tokens, not `@media (device-width: 375px)` |
| **Orientation** | Handle portrait ↔ landscape only when SPEC §4 documents layout shift |

## 3. Layout primitives

- Grid: `repeat(auto-fill, minmax(<min>, 1fr))` for card/widget grids — min from SPEC §4
- Stack: vertical flow with spacing token between children
- Cluster: horizontal wrap with gap token
- Sidebar: fixed + fluid split documented in SPEC §4

Document chosen layout primitives in foundation doc 03 or design-system `CATALOG.md`.

## 4. Touch targets

| Context | Minimum size | Source |
|---------|-------------|--------|
| Mobile interactive | 44×44 px | WCAG 2.5.8 / Apple HIG |
| Desktop interactive | 24×24 px (recommended 32×32) | WCAG 2.5.8 |
| Spacing between targets | ≥8 px | Prevent mis-taps |

Verify with UIS-02 at milestone.

## 5. Content reflow

- No horizontal scroll on any breakpoint unless SPEC §4 explicitly allows (e.g. data tables with horizontal overflow affordance)
- Images: `max-width: 100%; height: auto` baseline; art direction via `<picture>` when SPEC requires
- Typography: fluid type scale or breakpoint-stepped — document in token file
- Tables: responsive strategy per screen SPEC (scroll, stack rows, or hide columns)

## 6. Testing

- `REPLACE:UI_VISUAL_TEST` must capture at least `--bp-sm`, `--bp-md`, `--bp-lg` viewports
- Screen SPECs list responsive states in §3 (loading/empty/error per breakpoint when layout differs)
- UIS-02 required on every mobile-app screen and recommended on all others

## 7. Forbidden

- `@media (max-width: …)` in mobile-first codebases (use `min-width`)
- Breakpoint values as magic numbers in component source — use tokens or config
- `display: none` to hide content from small screens without `aria` alternative
- Fixed-width containers that prevent reflow below `--bp-lg`
