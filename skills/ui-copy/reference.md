# ui-copy — rubric reference

Companion to `skill.md` and `standards/20260523-COPY_STANDARD.md` (the binding core — this file adds detailed rubrics, principles only; sources are © link-only, never pasted).

## 1. Error-message formula (NN/g error guidelines; Polaris)

A user-facing error = **what happened + why it matters + what to do next**.

| Rule | Example |
|------|---------|
| State the problem in plain language | "We couldn't save your changes." not "Error 500" |
| Add why (if known) + a remedy | "Your internet connection may have dropped. Try again." |
| Never blame the user | "We couldn't update the profile" not "You entered invalid data" |
| Preserve input on failure | keep the form values; offer retry/undo where sensible |
| No internal jargon | no stack traces, error codes, or IDs in user-facing text |

**Banned words:** invalid, illegal, failed, "please try again" (bare), "an error occurred".

## 2. Tone grading (Google voice & tone)

Classify output against three columns; target **just-right**:

| Too informal | Just right | Too formal |
|--------------|------------|------------|
| "Hey! Just click the thing!" | "Save changes to continue." | "The operation could not be completed due to an unspecified error condition." |

- 2nd person, active voice; read-aloud self-check; no exclamation marks in functional text; no "simply/quickly/easy".

## 3. Inclusive language & i18n (Microsoft; COPY_STANDARD §8)

- Bias-free term list per Microsoft (e.g. avoid "whitelist/blacklist" → "allowlist/blocklist"); no gender-coded examples.
- 40% text-expansion allowance; RTL via logical properties; pluralization per locale (never `count === 1 ? "item" : "items"`).

## 4. Action-label dictionary + cross-screen consistency (WCAG 3.2.4)

- **One verb per action** across the whole product: maintain a label dictionary (e.g. `save`, `delete`, `export`, `cancel`, `retry` — not "Save" here and "Store" there).
- Same functionality = same accessible name everywhere (WCAG 2.2 SC 3.2.4 — a11y requirement, not style).
- `audit` mode runs this check across all screens in scope.
