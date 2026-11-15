---
name: site-raymond-post
description: >-
  Authors Everyone ❤️ Raymond single-panel strips under
  content/cognitive-memetics/raymond/: pitches gags from reference.md catalog,
  generates Nano Banana art prompts, drafts EN/ES front matter and teasers
  (Dawg Raymond / Raymond el perro), creates art-brief.txt, and builds
  linkedin.txt sidecars. Use when the user asks for Raymond strips, pitches,
  prompts, or bundles.
---

# Everyone ❤️ Raymond Strip Authoring

## Goal

End-to-end authoring of single-panel corporate satire strips starring **Raymond**, the junior dog from *Cube-Cows* (*Just smaller*), published on Fridays under `content/cognitive-memetics/raymond/`.

This skill owns:
1. **Gag ideation and pitching** using the corporate pathology catalog in `reference.md`.
2. **Nano Banana image prompts** using the proven square prompt template.
3. **Bundle scaffolding** (`index.md`, `index.es.md`, `art-brief.txt`, `linkedin.txt`, and image conversion).

---

## Author Premise & Core Satire Engine

> Raymond is the junior dog from *Cube-Cows* (*Just smaller*), fresh out of uni, as he walks into corporate shenanigans with a notebook open.
> He does not fix the system. He takes notes. Each strip is one office move he cannot unsee: out of uni, straight back to preschool.

The comedy is **innocent forensic compliance**. Raymond does not yell, lecture, or rebel. He complies literally with management's grand announcements, and his calm, handwritten field notes expose the empty ritual underneath.

### The Three-Beat Gate

Every Raymond strip must satisfy this contrast:

```text
 [1. The Corporate Mandate]
   Management or HR announces an abstract virtue or policy
             |
             v
 [2. The Literal Void]
   The actual physical environment shows an empty room, a loop, or zero evidence
             |
             v
 [3. The Forensic Note]
   Raymond quietly records the reality in his notepad with deadpan compliance
```

---

## References

| File | Role |
|------|------|
| **`reference.md`** | Catalog of corporate pathologies (`R-T1` through `R-T14`), mandates, and satire engines |
| **`characters-and-world.md`** | Character profiles (Raymond, Cow Managers, Hyenas), office environments, and approved color palette |
| **`.cursor/skills/site-cognitive-memetics-content/SKILL.md`** | Cognitive-Memetics umbrella section rules and metadata conventions |
| **`.cursor/skills/site-linkedin-post/SKILL.md`** | Fold-first LinkedIn sidecar formatting rules |

---

## Core Constraints

**CONSTRAINT:** Gag pitches MUST cite a theme id (`R-T#`) from `reference.md` and MUST name all three beats of the engine (Mandate, Literal Void, Forensic Note).
- Enforcement: Each pitch candidate fills the pitch gate before presentation to the user.
- Violation: STOP, rewrite the pitch or discard.

**CONSTRAINT:** Character casting MUST follow `characters-and-world.md`.
- Raymond is a small tan cartoon dog with a forest-green collar, brass tag, pencil, and notepad.
- Coworkers and managers are anthropomorphic cows and bulls in business-casual attire.
- Specialist presenters (slick consultants, AI hype peddlers) may be hyenas.
- MUST NOT use ants, frogs, lizards, or snakes (strictly reserved for *Reptilocracy*).

**CONSTRAINT:** Schedule, folder, and numbering rules:
- Published bundles MUST use a **Friday calendar date** in the folder name and `date` front matter (`YYYY-MM-DD`).
- Sequential `heading_code` (e.g. `R1`, `R2`, ..., `R15`).
- `project: 'Everyone ❤️ Raymond 🐕📓'`.
- `type: panel`.
- `categories: ["Cognitive-Memetics", "Raymond"]`.

**CONSTRAINT:** Mandatory tags in front matter:
- MUST include: `"EveryoneLovesRaymond"`, `"PetLife"`, `"TheCutestDog"`, `"OfficeCulture"`, `"OfficeSatire"`.
- MUST include 1 or 2 episode-specific tags (e.g. `"AdminNightmare"`, `"BuzzwordHell"`, `"PerformanceReview"`, `"ReturnToOffice"`).
- MUST NOT add bare `"Raymond"`, `"Dog"`, or `"Dogs"`.

**CONSTRAINT:** Teaser and character naming rules:
- English `description` MUST start with `"This week, ..."` and MUST include the exact character label **`Dawg Raymond`** (not "Raymond the dog").
- English `description` MUST apply Markdown `**bold**` on 3 to 5 key joke-spine words per `revise-emphasis`.
- Spanish `description` in `index.es.md` MUST include **`Raymond el perro`** (or `perros`).
- MUST NOT use the em dash (U+2014) in any output.

**CONSTRAINT:** LinkedIn sidecar (`linkedin.txt`) formatting:
- Line 1: Plain-text copy of English `description` (with Markdown bold stripped).
- Blank line.
- Line 3: `🟣 {heading_code}: Everyone ❤️ Raymond 🐕📓`.
- Blank line.
- Exact "But why" block from `i18n/en.toml` (`raymondProjectAboutTitle` and `raymondProjectAboutBody`).
- Blank line.
- Hashtags mirroring all front matter tags.
- Blank line.
- Closing links: `🧷 Full post (site) →` with EN and ES permalinks, blank line, then `🔗 Everyone ❤️ Raymond (English) → https://behaviorengineering.ai/categories/raymond/`.

---

## Nano Banana Prompt Recipe

Nano Banana requires high specificity in setting, wardrobe, character posture, and palette. Always format art prompts using this exact schema:

```text
IMAGE RATIO: 1:1 (square)

SCENE & VARIATION DIRECTIVE:

Scenario / Setting: [Specific corporate space: e.g. Executive strategy room with a dusty-rose accent wall, slate-gray carpet, and a large mounted glass whiteboard showing...]

Wardrobe / Palette:

[Manager / Cow / Hyena]: [Species, clothing style and colors, accessories like badge or lanyard, posture, facial expression]

Raymond: Forest-green collar with a round brass tag, small tan cartoon dog, spiral notepad, and pencil. [Specific posture, where he sits or stands]

Palette: Dusty rose, slate blue, charcoal gray, cream, forest green, [1-2 accent colors], dry-erase black.

Gag & Dialogue:

[Detailed visual action: What the manager is pointing at or announcing. The exact text on the whiteboard, screen, or flyer. Raymond's quiet forensic reaction and the exact words written on his notepad.]
```

---

## Authoring Workflow

### Step 1: Scan Shipped Episodes & Pick Themes
Check existing episodes under `content/cognitive-memetics/raymond/` to ensure the next episode uses the next Friday date and next `R#` code, and avoids repeating a recently shipped mechanism.

### Step 2: Pitch Gags (Gate)
For each pitch candidate, evaluate in working memory:

```text
Candidate: [Working title]
Theme: [R-T# from reference.md]
Corporate Mandate: [What management announces]
Literal Void: [The visual reality or loop in the room]
Forensic Note: [What Dawg Raymond writes in his notepad]
Visual Centerpiece: [Dominant prop: screen, whiteboard, flyer, basket]
Cast: [Cow manager, hyena, peers]
Decision: PITCH | REVISE
```

Present 2 to 4 clean pitches with:
- Title and Theme ID
- Scene and Visual Centerpiece
- Manager statement / dialogue
- Raymond's notepad line

### Step 3: Generate Nano Banana Art Prompt
Once the user selects a pitch, produce the 1:1 square prompt using the prompt recipe above.

### Step 4: Convert and Scaffolding Bundle
When the user supplies the generated image:
1. Convert to WebP: `cwebp -q 85 <source-image> -o content/cognitive-memetics/raymond/<folder>/<slug>.webp`.
2. Write `index.md` (EN panel).
3. Write `index.es.md` (ES panel with Spanish translation of description).
4. Write `art-brief.txt` (summary of panel for repo reference).
5. Write `linkedin.txt` (fold-first LinkedIn social post).

### Step 5: Verification & Quality Gates
1. Run `go tool task calendar` to update `static/calendar/publish-calendar.json`.
2. Run Spanish gate: `python3 scripts/evaluate_spanish.py --scope site` on `index.es.md`.
3. Check em dashes: Confirm zero instances of U+2014 across all files.
