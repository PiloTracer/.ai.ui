# Copy & Microcopy Standard — template

> Binding rules for UI text: labels, errors, empty states, confirmations, tooltips, and onboarding. Complements `@ui-copy` skill and screen SPECs §5 (Content).

**Pairs with:** `@ui-copy` skill, screen SPECs §5, `REPLACE:UI_I18N_METHOD`, `REPLACE:UI_ACCESSIBILITY_FILE`

---

## 1. Tone definition (required in foundation doc 01)

Document tone in foundation doc 01 using this shape:

| Attribute | Value | Example |
|-----------|-------|---------|
| **Voice** | `REPLACE:UI_BRAND_VOICE` (e.g. "professional, warm, concise") | — |
| **Person** | 2nd person ("you") for actions; 1st person ("my") for possessives when personal context | "Your changes have been saved" |
| **Formality** | Casual / neutral / formal | Neutral: no slang, no jargon |
| **Humor** | Never in errors; sparingly in empty states if brand allows | — |

## 2. Labels and actions

| Rule | Detail |
|------|--------|
| **Button labels** | Verb + object: "Save changes", "Delete account" — not "Submit", "OK", "Yes" |
| **Link text** | Descriptive: "View billing history" — not "Click here", "Learn more" (a11y) |
| **Form labels** | Visible, noun-phrase: "Email address" — not placeholder-only |
| **Toggle labels** | Describe the ON state: "Show notifications" — not "Notifications toggle" |
| **Menu items** | Verb or noun matching the destination: "Settings", "Export as CSV" |

## 3. Error messages

| Component | Rule |
|-----------|------|
| **Structure** | What happened + why (if known) + what to do next |
| **Tone** | Neutral, never blaming: "We couldn't save" — not "You entered invalid data" |
| **Specificity** | Field-level when possible: "Email must include @" — not "Invalid input" |
| **Recovery** | Always include a path forward: retry, edit, contact support |
| **Technical** | No stack traces, error codes, or internal IDs in user-facing copy; log reference ID if needed |

## 4. Empty states

| Context | Required elements |
|---------|-------------------|
| **First use** | Explain value + primary CTA to get started |
| **No results** | Acknowledge search/filter + suggest adjustment |
| **Cleared data** | Confirm action + offer undo or next step |
| **Permission** | Explain what they'd see + how to get access |

Never show a blank screen or bare "No data" — see UIS-08 §empty-state.

## 5. Confirmation and destructive actions

| Action type | Copy pattern |
|-------------|-------------|
| **Reversible** | Toast: "Item archived" + "Undo" link — no modal |
| **Irreversible** | Modal: state what will happen, name the object, confirm button repeats the verb ("Delete project") |
| **Bulk** | Include count: "Delete 3 items? This cannot be undone." |

## 6. Tooltips and help text

- Tooltips: one sentence max; no essential information (keyboard/screen-reader users may miss them)
- Help text below fields: `aria-describedby` linked; present tense ("Must be at least 8 characters")
- Info icons: use `aria-label` on trigger; tooltip content duplicated in accessible description

## 7. Numbers, dates, and units

| Element | Rule |
|---------|------|
| **Numbers** | Locale-aware formatting via `REPLACE:UI_I18N_METHOD`; thousand separators; abbreviate large values (1.2K, 3.4M) with tooltip for exact |
| **Dates** | Relative ("2 hours ago") for recent; absolute for historical; show both on hover |
| **Currency** | Symbol + value from locale; never truncate cents on financial screens |
| **Percentages** | One decimal max in UI; full precision in export/tooltip |

## 8. Internationalization

- All user-visible strings via `REPLACE:UI_I18N_METHOD` — no hardcoded English in shared components
- Accommodate 40% text expansion (German, Finnish) in layout
- RTL: mirrored layout via logical properties; icons with directional meaning flip
- Pluralization rules per locale (not just `count === 1 ? "item" : "items"`)

## 9. Review and audit

- `@ui-copy write` before `@ui-component-build` for dedicated copy work
- `@ui-copy audit` at milestone to catch placeholder text, inconsistent terminology, or tone drift
- Screen SPEC §5 is the source of truth for copy keys — components implement, not invent
- Glossary: maintain key terms in `.work.ui/plans/foundation/` or HANDOFF_UI to prevent synonyms (e.g. "workspace" vs "project" vs "space")
- Detailed rubrics (error formula, tone grading, inclusive/i18n, action-label dictionary + WCAG 3.2.4 consistency) live in `skills/ui-copy/reference.md` — the standard above is the binding core
