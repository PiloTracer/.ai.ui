# Motion & Animation Standard — template

> Binding rules for transitions, animations, and loading states. Complements UIS-03 (`motion-design/`) and the design tokens motion section.

**Pairs with:** `REPLACE:UI_DESIGN_TOKENS_FILE` §motion, `REPLACE:UI_ACCESSIBILITY_FILE` §3, screen SPECs §6 (Interactions)

---

## 1. Motion tokens (required in foundation doc 02)

| Token | Default | Use |
|-------|---------|-----|
| `--duration-instant` | `100ms` | Hover, focus, toggle feedback |
| `--duration-fast` | `200ms` | Dropdowns, chips, small reveals |
| `--duration-normal` | `300ms` | Modals, drawers, page transitions |
| `--duration-slow` | `500ms` | Skeleton fade-out, onboarding |
| `--easing-default` | `cubic-bezier(0.4, 0, 0.2, 1)` | General movement |
| `--easing-enter` | `cubic-bezier(0, 0, 0.2, 1)` | Elements appearing |
| `--easing-exit` | `cubic-bezier(0.4, 0, 1, 1)` | Elements leaving |

Override defaults in token file; do not use bare `ms` values in component source.

## 2. Classification

| Class | Examples | Duration | Required |
|-------|----------|----------|----------|
| **Micro-feedback** | Button press, toggle, hover | `--duration-instant` | Always — users expect immediate response |
| **Reveal / collapse** | Accordion, dropdown, tooltip | `--duration-fast` | Recommended for spatial continuity |
| **Transition** | Page change, modal enter/exit, drawer | `--duration-normal` | When SPEC §6 documents transition |
| **Decorative** | Parallax, ambient loops, illustration | `--duration-slow` or custom | Only when SPEC explicitly allows |

## 3. Reduced motion (mandatory)

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important;
  }
}
```

- Apply at global reset level or per-component — document approach in foundation doc 02
- Skeleton loading states remain (static, no pulse) so users see feedback
- Chart enter animations disabled; data still renders immediately
- Exceptions: progress indicators where motion conveys essential information — use `aria-live` alternative

## 4. Loading states

| Pattern | When | Motion |
|---------|------|--------|
| **Skeleton** | Content shape known, data pending | Pulse at `--duration-slow` (disabled under reduced-motion) |
| **Spinner** | Shape unknown, brief wait expected | Rotate, `aria-label="Loading"` |
| **Progress bar** | Duration estimable (upload, export) | Linear fill, percentage if available |
| **Optimistic** | Action likely to succeed (toggle, like) | Instant visual → revert on failure |

Screen SPECs §3 must specify which pattern per state.

## 5. Page / route transitions

- Shared-element transitions only when SPEC §6 documents anchor element
- Avoid full-page fade-in/out unless brand requires — prefer instant swap with skeleton
- Navigation must not block on exit animation — route change is immediate, animation is cosmetic

## 6. Chart & data animation

- Enter animation: stagger bars/lines over `--duration-normal` max
- Update animation: interpolate values over `--duration-fast`
- Both disabled under `prefers-reduced-motion`
- Tooltips appear instantly (`--duration-instant`) — no delayed fade

## 7. Forbidden

- `transition: all` — enumerate properties explicitly
- Animation duration > 1s without SPEC waiver and decorative classification
- Motion that blocks interaction (user cannot click during animation)
- Infinite loops on non-progress elements (no "breathing" buttons)
- `animation-delay` > `--duration-normal` on essential UI (perceived as broken)
