# websites — manifest

**Archetype:** `marketing-site` · **Patterns doc:** UI-PATTERNS § marketing · **Craft:** [`standards/20260523-SURFACE-AND-CONTROL-CRAFT.md`](../../standards/20260523-SURFACE-AND-CONTROL-CRAFT.md)

| id | file | surfaces | controls | typography | spacing | extractedRules | primitives |
|----|------|----------|----------|------------|---------|----------------|------------|
| W1 | `image.png` | Full-bleed immersive hero (photo/video); minimal chrome; dark overlay | Central circular MENU hub; icon-only header (search, grid, bag); underline text CTA | Display serif headline + caps sans subcopy; logo centered | Edge-to-edge hero; bottom-center MENU affordance | Full-bleed hero imagery; serif headline + utility sans for tags/CTA; navigation can be non-standard (central MENU) — document in SPEC §6; dark immersive hero: contrast check on all overlay text (UIS-04); avoid generic AI gradient hero unless brand SPEC allows | `Hero`, `TextLink`, `IconButton`, `MenuHub` (pattern) |
| W2 | `image copy.png` | Split hero; light/dark sections; editorial whitespace | Standard top nav + hamburger; primary filled CTA | Large display + body copy pairing | Generous vertical sections | Alternate landing: split layout hero; clear H1 + single CTA; section rhythm with whitespace | `Hero`, `Button`, `NavBar` |
| W3 | `image copy 2.png` | Card grid for features; soft background | Multiple CTAs tiered (primary/secondary) | Feature titles bold; body regular | Feature grid 2–3 col desktop | Feature grid blocks below hero; secondary CTA ghost/outline | `Card`, `Button` |
| W4 | `image copy 3.png` | Pricing grid; alternating card highlights; badge on recommended tier | Toggle annual/monthly; tier CTA buttons (primary on featured, ghost on others); feature comparison expand | Tier name bold; price large display; feature list regular weight | 3-col pricing grid desktop; single-col stacked mobile; feature rows align across tiers | Pricing grid: highlight recommended tier with accent border + badge; toggle billing cycle without page reload; feature comparison collapsible below tiers; CTA hierarchy: primary on recommended, secondary on others | `Card`, `Badge`, `Button`, `Toggle` |
| W5 | `image copy 4.png` | Testimonial carousel; soft gradient background; avatar + quote cards | Carousel dots; auto-advance with pause on hover; swipe on mobile | Quote italic serif; attribution sans; company name muted | Carousel full-width; quote card centered max-width; avatar left of text on desktop, above on mobile | Testimonial carousel: one visible at a time; auto-advance 5s with pause on hover/focus; avatar + name + role + company; quote marks decorative not structural; dots navigation accessible (aria-label per slide) | `Card`, `Avatar`, `Carousel` |
| W6 | `image copy 5.png` | Blog / resource hub; card grid; category filter bar | Category pill filters; search input; pagination or infinite scroll; card click → article | Card title bold; excerpt two-line clamp; date muted; category badge | Filter bar above grid; 3-col grid desktop; 2-col tablet; 1-col mobile | Blog grid: cards with image + title + excerpt + date + category badge; category filter pills (active = filled); search filters in real-time; card hover elevates shadow; pagination preferred over infinite scroll for SEO | `Card`, `Chip`, `SearchBar`, `Pagination` |
| W7 | `image copy 6.png` | About / team page; full-bleed mission statement; team member grid | Team card hover reveals bio; social icon links; department filter tabs | Mission statement display; team names bold; role muted italic | Mission section full-width text; team grid 4-col desktop / 2-col mobile | About page: mission statement hero with brand typography; team grid with photo + name + role; hover/tap reveals short bio; social links as icon buttons; optional department tab filter; values section with icon + heading + paragraph | `Card`, `Tabs`, `IconButton`, `Avatar` |
| W8 | `image copy 7.png` | Contact page; split layout form + info; map embed | Form: name, email, subject dropdown, message textarea; submit CTA; office cards with address + phone | Form labels visible; office name bold; address regular | Split: form left, office info right on desktop; stacked on mobile; map spans full width below | Contact page: form with visible labels (not placeholder-only); subject dropdown for routing; success state replaces form (not just toast); office cards with icon + address + phone + hours; map embed optional, lazy-loaded; honeypot or captcha — no visible CAPTCHA unless fallback | `Button`, `Select`, `TextInput`, `TextArea`, `Card` |
| W9 | `image copy 8.png` | Legal / terms page; long-form content; sidebar table of contents | TOC scroll-spy highlights active section; back-to-top button; anchor links on headings | Heading hierarchy H2/H3; body optimized for reading (max 65ch); legal captions smaller | Sidebar TOC fixed on desktop; collapses to top dropdown on mobile; content centered max-width | Legal / long-form: sticky TOC with scroll-spy active state; heading anchors for deep linking; reading-optimized line length (max 65ch); back-to-top appears after first scroll; print stylesheet optional; last-updated date visible | `Sidebar`, `TextLink`, `Button` |

## Creative columns (UIS-10)

| id | heroPattern | mood | tensionTechnique | scrollRhythm |
|----|-------------|------|------------------|--------------|
| W1 | Immersive photography | Dark, cinematic, luxury | Scale contrast: massive hero image vs minimal nav; asymmetric MENU placement | HIGH → hero only; rest of site implied off-screen |
| W2 | Split layout | Clean, confident, balanced | Light/dark section alternation; generous whitespace creates breathing room | HIGH (hero) → LOW (whitespace) → repeat |
| W3 | *(sub-hero section)* | Friendly, approachable | Card grid creates rhythm through repetition with variation; tiered CTAs add hierarchy | Part of larger page — feature section energy |
| W4 | *(pricing section)* | Clear, trustworthy, decisive | Highlighted recommended tier breaks grid uniformity; toggle adds interactivity | Mid-page decision point — needs LOW section before it |
| W5 | *(social proof section)* | Warm, personal, credible | Carousel motion adds life; serif quotes vs sans attribution create font tension | LOW energy — trust-building pause between features and CTA |
| W6 | *(content hub)* | Informative, explorable | Filter interaction creates engagement; card hover elevation adds depth | App-like energy — not a scroll narrative |
| W7 | Typographic hero | Warm, human, mission-driven | Full-bleed mission text vs dense team grid creates scale contrast | HIGH (mission) → LOW (values) → HIGH (team grid) |
| W8 | Split layout | Helpful, accessible | Form vs info split creates asymmetric tension; map adds environmental context | Functional — creative tension in form design quality |
| W9 | Editorial whitespace | Professional, authoritative | Long-form reading rhythm; TOC creates interactive layer on top of passive content | Steady LOW — reading mode, not marketing mode |

**Extracted rules (W1):**

- Typography pairing: display serif + utility sans for tags/CTA
- Navigation can be non-standard (central MENU) — document in SPEC §6
- Dark immersive hero: contrast check on all overlay text (UIS-04)
- Avoid generic AI gradient hero unless brand SPEC allows

**External refs:** `resources/webdesign/concept.design.txt`
