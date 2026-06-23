# Director quick reference — free-text UI entry points

**When to open:** You have a UI/design goal but don't know which `ui-*` skill to invoke. Use a director to route for you.

---

## Which director?

| If your request is about… | Invoke |
|---------------------------|--------|
| UI, design, screens, components, tokens, a11y | `@ui-director - <describe what you want>` |
| Spans UI + engineering + business | `@x-director - <describe what you want>` |

---

## Common free-text requests

```text
@ui-director - I need a login screen for the app
  → checks screen-spec-ready → @ui-screen-spec create - login → build

@ui-director - Set up the design foundation for a SaaS dashboard
  → @ui-project-approach - B2B SaaS dashboard
  → @ui-style-stack set - tailwind
  → @ui-design-foundation greenfield

@ui-director - Build out the dashboard home screen
  → @ui-component-build status → @ui-component-build plan - S1 → start → continue

@ui-director - Check the visuals before we ship
  → @ui-visual-verify milestone → @ui-accessibility-audit milestone

@ui-director - I'm not sure which components we need
  → @ui-design-foundation probe

@x-director - Build a signup feature with backend API and UI
  → @ai-director - create backend signup API with database schema
  → @ui-director - design and build signup UI screen
```

---

## What the director does

1. **Captures** your exact wording.
2. **Loads** `{HANDOFF_UI}` and `{UI_ITERATION_CARRIER}` for context.
3. **Classifies** intent into a UI bucket (foundation, screen, build, verify, etc.).
4. **Checks** prerequisite gates in `SKILL_DEPENDENCIES.md`.
5. **Invokes** the correct `ui-*` skill chain with canonical syntax.
6. **Records** the action in `{HANDOFF_UI}` and updates `{UI_ITERATION_CARRIER}` when the cycle advances.

---

## Syntax reminders

- ASCII hyphen `-` between verb and argument: `@ui-screen-spec create - login`
- Free-text mode: `@ui-director - <anything>`
- Status mode: `@ui-director status`
- Help mode: `@ui-director help`

---

**Full protocol:** `skills/ui-director/skill.md` · `skills/x-director/skill.md` (in `.ai/`)
