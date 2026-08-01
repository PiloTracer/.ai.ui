---
name: ui-copy
description: >-
  Plan, write, review, or audit UI copy — microcopy, labels, error messages,
  empty states, tooltips, confirmations, help text, headings, button text,
  alt text, and onboarding copy. Produces concise, audience-aware, inclusive,
  action-oriented text calibrated to the host project's brand voice, user
  personas, and screen SPEC. Use this skill for any UI text task because
  microcopy quality directly affects usability, trust, and conversion.
  ui-copy write, ui-copy plan, ui-copy review, ui-copy audit, ui-copy tone,
  ui-copy status.
---

# ui-copy

**Canonical path:** `.ai.ui/skills/ui-copy/skill.md`

Every word in the UI earns its place. Buttons say what they do. Errors tell the user what went wrong and how to fix it. Empty states guide, not just report absence. Microcopy is the UI's voice — make it plain, specific, and helpful.

This skill is **model-agnostic** and **gate-independent**: it can run at any stage. Use early (during screen SPEC authoring) or late (pre-ship audit).

---

## Parse invocation

| User says | Mode |
|-----------|------|
| `@ui-copy write - <element or screen>` | Author copy for one element/state/screen (default). |
| `@ui-copy write - <type> for <screen or element>` | Author with explicit type (button, label, empty-state, error, tooltip, confirmation, heading, help-text, alt-text, onboarding). |
| `@ui-copy plan - <screen or milestone>` | Plan all copy needs for a screen or milestone from its SPEC. |
| `@ui-copy review - <path>` | Evaluate existing screen copy against quality bar. |
| `@ui-copy audit - <path>` | Full copy audit: tone, consistency, accessibility, completeness. |
| `@ui-copy tone - <description>` | Define or reload brand voice for UI copy. |
| `@ui-copy status` | Report what brand/voice context is loaded and what's missing. |

**Default:** `write` if no verb matches.

---

## I0 — Project Context Contract (run before writing)

Load context in priority order. Stop when you have enough.

### Priority 1 — UI project memory

| File | What it gives you |
|------|-------------------|
| `.work.ui/context/HANDOFF_UI.md` | Active milestone, recent decisions |
| `.work.ui/plans/NEXT_UI.md` | Current iteration tasks |
| Screen SPEC §5 Content | Existing copy keys, labels, empty states |

### Priority 2 — Brand & audience

| Source | What it gives you |
|--------|-------------------|
| Foundation doc 01 (vision & principles) | Brand voice in UI copy, target user |
| `.cursorrules` `REPLACE:UI_VOICE` tokens | Voice guidance (plain, direct, operator-friendly, etc.) |
| `.work.biz/strategy/target-buyer-profile.md` (if present) | Who reads this UI, what they value |

### Priority 3 — Standards

| Standard | What it gives you |
|----------|-------------------|
| `UI-CONVENTIONS.md` | i18n method, user-visible string rules |
| `UI-PATTERNS.md` | Per-screen-type copy expectations |
| `ACCESSIBILITY_STANDARD.md` | Label association, error association, required-field marking |
| `SURFACE-AND-CONTROL-CRAFT.md` | Label positioning, proximity rules |
| `COMPONENT_STANDARD.md` | Primitives must not contain domain copy |

### Priority 4 — Existing UI

Scan the built UI (or designs) for existing copy patterns to maintain consistency.

### Context summary

```
LOADED CONTEXT
  Project:      <name or "unnamed">
  Voice:        <voice description or "unspecified — professional defaults">
  Audience:     <target user or "general">
  Existing patterns: <yes/no/were read>
  Gaps:         <what could improve output>
```

---

## I1 — `write` mode

### Step 1 — Understand the assignment

Resolve from conversation or screen SPEC:

| Question | Why it matters |
|----------|----------------|
| **Element type** | Button, label, error, empty state, tooltip, confirmation, heading, help text, alt text, onboarding step, notification |
| **Screen / context** | Where does this appear? What state (loading, empty, error, success)? |
| **User goal** | What is the user trying to do at this point? |
| **Tone** | Match brand voice by default; override if specified |
| **Constraints** | Max length (pixel or character), i18n requirements, a11y requirements |
| **Audience** | Technical level, domain knowledge, primary vs secondary users |

### Step 2 — Write

#### Universal microcopy rules

Bind to `standards/20260523-COPY_STANDARD.md` §2–§8 (labels & actions, errors, empty states, confirmations, tooltips, numbers, i18n) — do not restate them here. Only rules the standard does **not** cover:

1. **Headings answer "Where am I? What is this section for?".** Every section needs a heading that distinguishes it from adjacent content.
2. **One action per button/link.** Two actions → two controls.
3. **Alt text describes what's depicted, not the file.** Decorative images get `alt=""`.
4. **Numbers and specifics beat generalities** ("Last updated 3 min ago" > "Recently updated"; "3 members online" > "Some members online").
5. **Skip confirmation bias.** "Join 10,000+ users" is marketing copy, not microcopy — reserve for marketing surfaces.

#### Element-type guidelines

| Element | Principles |
|---------|------------|
| **Button** | Verb-first, outcome-oriented. 2–4 words. Never "Submit" (says nothing). |
| **Link** | Descriptive of destination. "View invoice #2042" not "click here". |
| **Label** | Short (1–3 words), distinct from adjacent labels. Required fields marked. |
| **Help text** | Below the field. Explains *why* the field exists or the expected format. |
| **Placeholder** | Example value ("e.g. janedoe@co.com") — never a label substitute. |
| **Error** | [What's wrong] + [how to fix]. Inline for the field + optional summary for forms >5 fields. |
| **Empty state** | [What's absent] + [what to do about it]. Icon + heading (1 line) + body (1–2 lines) + optional CTA. |
| **Confirmation** | [What will happen] + [consequences] + [two buttons: primary action + cancel]. |
| **Tooltip** | Context or rationale, never repeats the label. One sentence max (COPY_STANDARD §6). |
| **Toast/notification** | [What happened] in 1 line. Success = green, error = red, info = neutral. |
| **Loading** | What's loading ("Loading reports…"), not just a spinner. Under 2 words. |
| **Heading** | Distinguish from siblings. Screens get a page title; sections get H2/H3. |
| **Onboarding** | One message per step. "This is your dashboard. Your KPIs and active projects appear here." |
| **Alt text** | "Chart showing revenue trend: $12.4K in May, $14.1K in Jun, $13.8K in Jul" |

### Step 3 — Deliver

Provide the copy ready to paste into code or the screen SPEC:

```markdown
### <element> — <screen> — <state>
**Copy:** `<the text>`
**Max length:** <chars or px>
**Notes:** <rationale, i18n key, voice justification>
```

Below a divider, optionally offer:
1. **Alternate phrasings** (2–3 options for the key text)
2. **i18n considerations** (text expansion risk, RTL compatibility)
3. **One-sentence rationale** for the chosen wording

---

## I2 — `plan` mode

List all copy needs for a screen or milestone. Read the screen SPEC and produce a copy plan:

```
Screen: <slug>
State:  <loading / empty / error / success / typical>

| Element | Type | Notes | Priority |
|---------|------|-------|----------|
| Page title | heading | <rationale> | P0 |
| "Add item" button | button | visible in all states except loading | P0 |
| Empty state title + body | empty-state | guide user to add first item | P0 |
| "Item deleted" toast | notification | feedback after delete action | P1 |
| "Are you sure?" dialog | confirmation | guard on delete | P1 |
| Name field | label + help text | required field | P0 |
```

---

## I3 — `review` mode

Evaluate existing screen copy. Do **not** rewrite wholesale. Output:

1. **Verdict:** pass / needs revision / needs rewrite
2. **What works** (2–4 bullets, specific lines)
3. **What fails** (each tied to a microcopy rule — quote the text)
4. **Concrete fixes** (line-level: "replace X with Y because Z")
5. **Missing copy** (states or elements that have no text)

---

## I4 — `audit` mode

Full copy audit against all standards:

| Check | Pass/Fail | Notes |
|-------|-----------|-------|
| COPY_STANDARD §2–§8 conformance (labels, errors, empty states, confirmations, tooltips, numbers, i18n) | | |
| Cross-screen label consistency (WCAG 3.2.4 — one verb per action) | | |
| Required fields marked | | |
| No marketing filler in functional text | | |
| Brand voice consistent across screens | | |
| Alt text on all informative images | | |
| Text length fits constraints | | |

---

## I5 — `tone` mode

Define or reload the brand voice for UI copy. Read existing context and output:

```markdown
VOICE PROFILE — <project name>

**Voice principles:**
- <principle 1>: <what it means for copy>
- <principle 2>: <what it means for copy>

**Do:**
- <example of in-voice copy>

**Don't:**
- <example of out-of-voice copy>

**Tone by state:**
| State | Tone | Example |
|-------|------|---------|
| Success | <warm, direct> | "Changes saved" |
| Error | <blameless, helpful> | "We couldn't update your profile. Check the highlighted fields." |
| Empty | <encouraging, guiding> | "Set up your first project to get started." |
| Loading | <neutral, brief> | "Loading reports…" |
| Confirmation | <neutral, specific> | "Archive 'Q3 budget'?" |
```

---

## I6 — `status` mode

Report:
- What brand/voice context was loaded (or none)
- Whether a UI copy standard or screen SPEC exists
- Gaps that would improve output if supplied

---

## Quality check (run internally; do not output checkboxes)

- [ ] Is every button/action a clear verb phrase?
- [ ] Do error messages include what went wrong + how to fix?
- [ ] Do empty states guide the user to a next action?
- [ ] Do confirmations state the consequence, not just ask for permission?
- [ ] Are labels visible (not placeholder-only) and associated with controls?
- [ ] Is the text as short as it can be without losing meaning?
- [ ] Would the target user find this helpful and trustworthy?
- [ ] Are there any hollow words (amazing, seamless, robust — unquantified)?
- [ ] Is brand voice consistent throughout?
- [ ] Could any string be misinterpreted or cause confusion?

---

## Completion gate

All must be true:
1. Deliverable is written (or plan/audit produced).
2. Project context was loaded per I0; critical gaps surfaced.
3. Quality check passes.
4. A concrete next step is proposed.

---

## Time budget

| Mode | Time |
|------|------|
| `write` (element) | 5–10 min |
| `write` (screen) | 15–25 min |
| `plan` | 10–20 min |
| `review` | 10–20 min |
| `audit` | 20–30 min |
| `tone` | 15–25 min |
| `status` | < 2 min |

---

## Dependencies

This skill has **no hard prerequisite gate**. It can run at any stage. It improves when the screen SPEC exists (provides context) and brand voice is defined.

When `.ai.biz` is present and you need *external* marketing content (articles, blog posts, case studies), use `@content-writing` instead. This skill is for UI-internal copy only.

---

## Related

| Resource | When |
|----------|------|
| [`resources/web-research-2026.md`](../../resources/web-research-2026.md) §5 | Copy rubrics (error formula, tone, action-label dictionary) — apply license + verify rules ([§8.1](../../resources/web-research-2026.md#81-verify-resource-urls-skill-rule), [§8.2](../../resources/web-research-2026.md#82-browser-control-authorization-skill-rule)) |
| `@ui-screen-spec create` | Write copy during SPEC authoring (§5 Content) |
| `@ui-component-build` | Implement copy in components |
| `@ui-accessibility-audit` | Verify label association, error association, alt text |
| `@ui-concept-run - UIS-08` | Intuitive UX: error messages, confirmation copy, empty states |
| `UI-PATTERNS.md` | Copy checklists per screen type |
| `ACCESSIBILITY_STANDARD.md` | Label & error binding rules |
| `.ai.biz/skills/content-writing/skill.md` | Marketing content (sister project) |
