# ui-visual-verify — vision assertion catalog

Companion to `skill.md` § Vision tier. Copy-paste assertion statements for rendered-UI verification (Midscene-style `aiAssert` / vision-model queries). **Opt-in only** — requires explicit operator authorization (§8.2 browser policy); BYOK multimodal model; atomic assertions (one check per statement) for stable pass/fail.

## Usage rules

1. Authorize first: tool name + route(s) + actions; wait for operator confirmation.
2. One assertion per statement; pin the model; record model + date in the report.
3. Report each assertion as `pass` / `fail` / `blocked (auth)`. Include a screenshot for every `fail`.
4. Honest verdicts: a fix that introduces a new drift must be reported, not hidden.

## Layout

| Assertion (paraphrase) | Good when |
|------------------------|-----------|
| No horizontal overflow | page scrolls only vertically at 375 / 768 / 1440 px widths |
| Primary CTA above the fold | main action visible without scrolling (desktop + mobile) |
| Sticky header does not cover content | scrolled content top clears the header height |
| No overlapping elements | sibling blocks do not intersect (spot-check key sections) |
| Grid aligns | cards/columns share consistent gutters and edges |

## Color / contrast

| Assertion | Good when |
|-----------|-----------|
| Text contrast ≥ 4.5:1 (3:1 large) on rendered pixels | body + labels on their actual background |
| Chart palette matches tokens | categorical series colors equal foundation doc 02 chart tokens |
| Focus ring visible | `:focus-visible` outline visible on every interactive element |
| No generic chrome palette | no un-tokened neon/vendor-default colors in the render |

## State

| Assertion | Good when |
|-----------|-----------|
| Skeleton → content completes | loading placeholder is replaced by real content |
| Empty state guides | empty/zero-data state shows heading + next action (COPY_STANDARD §4) |
| Error message follows formula | error text = what happened + why + what to do next (§ Phase 5 rubrics) |
| Loading text is specific | spinner has a label ("Loading reports…"), not a bare spinner |

## Behavior

| Assertion | Good when |
|-----------|-----------|
| Scroll position persists | returning from detail restores list scroll (if SPEC requires) |
| Modal focus trap | Tab cycles inside the open modal; Esc closes it |
| Tab order matches visual layout | keyboard focus follows reading order (manual confirmation listed too) |
| Toast announces success | one-line success toast appears on save/delete (COPY_STANDARD §5) |

## Report shape

```markdown
### Vision report — <route> — <date>
**Tool/model:** <tool> · <model> · **Authorization:** operator-confirmed <scope>
| Assertion | Result |
|-----------|--------|
| No horizontal overflow @375 | pass |
| Text contrast ≥ 4.5:1 | fail — <screenshot ref> |
**Fixes applied:** …
**New drift introduced:** none | <list>
```
