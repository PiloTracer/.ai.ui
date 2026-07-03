# Creative direction — agent procedure (UIS-10)

**Role:** Creative reviewer for **marketing, landing, and storytelling surfaces** — the positive complement to UIS-06 (anti-generic).

**In scope:** Homepages, landing pages, hero sections, marketing scroll narratives, brand-expression screens.

**Out of scope:** Admin dashboards, settings, forms (use UIS-07 for craft on those). Only applies when archetype is `marketing-site`, `hybrid` (marketing shell), or SPEC explicitly tags a screen as creative/brand-expression.

## Inputs

- Screen SPEC §4, §5, §13 (exampleIds, extractedRules)
- Foundation doc 01 (brand voice, craft tier, personality attributes)
- Active style stack
- Screenshot, Storybook, or rendered output

## Procedure

### 1. Hero differentiation

Identify the hero pattern in use. Name it:

| Pattern | Signature | When it works |
|---------|-----------|---------------|
| **Immersive photography** | Full-bleed image/video; text overlay with scrim | Strong visual brand, lifestyle products |
| **Split layout** | Text left, image/illustration right (or inverse) | Product demos, SaaS, balanced information density |
| **Typographic hero** | Oversized display type IS the visual; minimal or no imagery | Bold brand voice, editorial, luxury |
| **Product-in-context** | Product screenshot/mockup in environment (device frame, desk, hand) | SaaS, apps, tools — "see it working" |
| **Illustrated narrative** | Custom illustration or animation as centerpiece | Playful brands, developer tools, startups |
| **Editorial whitespace** | Generous negative space; sparse elements create tension | Premium, luxury, minimal-brand identity |
| **Video background** | Looping ambient video; text overlay | Lifestyle, travel, events — high production value required |

Flag if: no identifiable pattern (layout is generic card grid or centered text blob), or pattern doesn't match brand/product type.

### 2. Typographic drama

Marketing pages use typography as a *design element*, not just information delivery.

Check:
- **Contrast ratio in type scale** — is the headline dramatically larger than body? (≥3:1 size ratio recommended for hero headlines vs body)
- **Font pairing intentionality** — display + body pair documented? Serif + sans creates tension; mono signals technical; all-sans needs weight contrast
- **Hierarchy depth** — at least 3 distinct visual levels in the hero (headline, subhead/tagline, CTA label)
- **Whitespace as typography** — is there enough breathing room that the type *reads as design*, not as "text on a background"?

Flag if: all text is the same weight/family, headline is <2x body size, or type choices are framework defaults with no SPEC justification.

### 3. Scroll narrative & section rhythm

Landing pages are sequential stories. Evaluate pacing:

- **Contrast-rest pattern** — sections alternate between high-energy (hero, CTA, social proof) and low-energy (whitespace, single message, breathing room). Three high-energy sections in a row = fatigue
- **Visual anchors** — each scroll section has one dominant element (image, stat, testimonial, product shot). No section should feel like "more of the same"
- **Progressive disclosure** — information builds: hook → value prop → proof → details → CTA. Check the order makes emotional sense, not just logical sense
- **Section transitions** — background color shifts, spacing changes, or visual elements create rhythm. Flat same-background stacking = monotonous

Flag if: all sections have identical structure (card grid repeated), no visual rhythm, or CTA appears only at top and bottom with nothing compelling in between.

### 4. Visual tension & personality

Great marketing pages have *tension* — deliberate contrast that creates energy:

- **Scale contrast** — some elements are dramatically large, others deliberately small (oversized headline + tiny caption, massive hero + compact nav)
- **Color temperature** — warm vs cool, saturated vs muted used to create focal points. All-neutral = flat
- **Asymmetry** — intentional off-center layouts, overlapping elements, broken grids create dynamism. Perfectly centered everything = static
- **Brand personality expression** — does the page *feel* like the brand? A playful product shouldn't look corporate; an enterprise tool shouldn't look like a candy store
- **One memorable detail** — is there at least one element a user would remember or describe to someone? ("the one with the huge rotating product shot" or "the one where the headline types itself")

Flag if: layout is perfectly symmetrical, all elements are medium-sized, color is monochromatic without accent drama, and nothing is unexpected.

### 5. Anti-template check

Score honestly:

| Question | Yes = good | No = flag |
|----------|-----------|-----------|
| Could this page belong to only THIS brand/product? | Distinct | Generic |
| Would removing the logo make the brand unrecognizable? | Bad — too generic | Good — visual identity is embedded |
| Does the page make you want to scroll? | Engaging | Static |
| Is there visual surprise anywhere below the fold? | Creative | Predictable |
| Does the hero work without reading the text? | Strong visual story | Text-dependent |

If ≥3 answers are flagged, recommend creative revision before shipping.

## Output

```markdown
## UIS-10 Creative direction
- Archetype: marketing-site | hybrid | other
- Hero pattern: <named pattern> — effective | weak | generic
- Typographic drama: strong | adequate | flat — <notes>
- Scroll narrative: compelling | adequate | monotonous — <section count, rhythm>
- Visual tension: present | minimal | absent — <what creates/lacks energy>
- Anti-template: <score>/5 — <flags>
- Memorable detail: <describe> | none identified
- Recommendation: ship | enhance — <top 1-3 specific creative improvements>
evidence: measured | estimated | assumption
```

**Pair with:** `@ui-concept-run - UIS-06` (run after UIS-10 — creative intent informs whether UIS-06 flags are real issues). `@ui-concept-run - UIS-01` for structural hierarchy.
