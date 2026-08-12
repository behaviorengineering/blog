---
name: cognitive-memetics-content
description: >-
  Authors and edits Hugo posts under the cognitive-memetics section: type panel
  (cube-cows weekly) or type sayings (TLDR / Context), Por-Estas-Calles / Street Wisdom /
  Venezuelan sayings project tags and LinkedIn hashtags, T-Shirt Art hub posts (short teasers
  without meta openers; sayings card **`description`** derived from **`title`** + **`tldr`** +
  **`fluff`** when applying this skill; sayings **`**bold**`** per **`.cursor/skills/revise-emphasis/SKILL.md`**).
  Footer "But why" explainers share one gradient card in **`assets/css/_custom.scss`** (Cube-Cows hub, Street Wisdom, Reptilocracy, Pawtropolis); extend that block instead of duplicating styles.
  **Hybrid prose:** keep street/cartoon emotion, ban empty punch closers and poetic thesis remixes (see **Hybrid prose**).
  **Title** stays plain (no leading emoji; this section opts out of optional title emoji used in other site sections). **heading_code**, **categories**, featured images. Use when editing content/cognitive-memetics/,
  when the user mentions Cognitive-Memetics, cube-cows, Tales from the Cube Farm,
  T-Shirt Art, Por-Estas-Calles, Street Wisdom, Cultural Stopwatch, cartoon stopwatch,
  Venezuelan sayings, Reptilocracy, or Pawtropolis (Under Fire). MUST ask before changing existing author prose (except sayings emphasis markup on
  existing words in **`tldr`**/**`fluff`** per **revise-emphasis**, and except replacing sayings **`description`** per
  **Sayings card teaser**) unless the user explicitly requests rewrite, revise, tighten, or similar.
---

# Cognitive-Memetics section content

## What this section is

**Cognitive-Memetics** is a **Hugo section**: paths under `content/cognitive-memetics/...` (URL prefix `/cognitive-memetics/`). It is listed in **`hugo.toml`** `params.home.contentSections` so posts can appear on the home feed with other sections.

This section does **not** define a separate `type`. Posts use existing content types:

| `type` | Role | Typical use in this folder |
|--------|------|----------------------------|
| **`panel`** | **Cube-cows** / weekly-style pieces (Cows **storyboards**; each image a **panel**) | **`description`** carries the strip (Teaser on the single); optional markdown body below `<!--more-->` only when you need a real essay. Optional `heading_code`; optional **`project`** + unique **`title`** |
| **`sayings`** | Short **saying** entries with TLDR + Context | `tldr` and `fluff`; card **`description`** is derived from **`title`**, **`tldr`**, and **`fluff`** when applying this skill; optional `heading_code`; optional **`project`** (series line) + unique **`title`** (episode name), same hero pattern as **`panel`** |

**T-Shirt Art** hub posts also use **`panel`** or **`sayings`**; see [below](#t-shirt-art) for **`categories`**, **`project`**, and tags. **Reptilocracy** (`content/cognitive-memetics/reptilocracy/`) uses **`type: sayings`** or **`type: panel`** with category **`Reptilocracy`**; the footer explainer uses the same gradient card as the Cube-Cows hub and Street Wisdom, plus Reptilocracy-only CTA styling when applicable (see **Theme and style** → **Project "But why" explainer cards** in this skill). **Pawtropolis (Under Fire)** (`content/cognitive-memetics/pawtropolis/`) uses **`type: panel`** or **`type: sayings`** with category **`Pawtropolis-Under-Fire`**; copy lives in **`i18n/*`** and **`layouts/partials/pawtropolis-project-about.html`** (no petition CTA).

For **`type: claims`** (Claim / Thoughts / Grounding), use **`.cursor/skills/claims-content/SKILL.md`** and a section such as `social-protocols`, not this skill.

## Authoring rules (site-wide)

- When editing **`tags`**, MUST consult **`data/tag-register.txt`** and **`.cursor/skills/tag-register/SKILL.md`** (prefer existing tags when they fit; new tags allowed when none do).
- MUST NOT use the em dash character (U+2014). Use comma, semicolon, colon, or parentheses.
- MUST use Markdown **`**bold**`** for scan-style emphasis on key verbs and nouns in the body (restrained density per **`.cursor/skills/revise-emphasis/SKILL.md`**).
- MUST keep code, identifiers, and user-facing strings in **English** (see workspace AI protocol).

### Ask before changing existing copy

- Phrases like **apply this skill**, **check the post**, or **make it compliant** do **not** grant permission to rewrite the author’s prose.
- When a file already has author text in **`title`**, **`description`**, **`tldr`**, **`fluff`**, or the markdown body, MUST **ask first** before changing that text (including “fixing” tone, clarity, mismatches you think you see, or aligning fields). Wait for an explicit yes to prose edits (for example: rewrite, revise, tighten, change the title, fix the TLDR). **Exceptions for `type: sayings`:** (1) **Sayings emphasis** (adding, trimming, or adjusting **`**bold**`** on **existing** words in **`tldr`** and **`fluff`** per **`.cursor/skills/revise-emphasis/SKILL.md`**) is **not** a prose edit and MUST follow that skill when you apply this one. (2) **Sayings card teaser** (replacing **`description`** using only **`title`**, **`tldr`**, and **`fluff`** as sources) is **not** a prose edit of TLDR/context and MUST run when you apply this skill.
- If the user does not confirm prose edits, restrict changes to **mechanical** front matter, **`type: sayings` emphasis** (per **revise-emphasis**), **`type: sayings` card teaser** (see below), and structure only (see **Editing existing posts** below).

### Editing existing posts (preserve author copy)

- When the author already supplied prose in **`tldr`**, **`fluff`**, **`title`**, or the markdown body, MUST **keep their wording** unless they **explicitly** ask for a rewrite, revise, tighten, or similar. For **`type: panel`** and types other than **`sayings`**, the same applies to **`description`**.
- **Exception (`type: sayings`):** **`description`** is **not** protected author copy when you apply this skill. MUST replace it per **Sayings card teaser** (use **`title`**, **`tldr`**, and **`fluff`** only as sources).
- MAY apply **mechanical** fixes without asking: YAML safety (quoting, colons), required front matter fields, **`categories`** / **`tags`** / **`date`** / **`heading_code`**, featured image paths, and obvious **wrong-folder** mistakes (for example mismatched **`heading_code`** vs bundle name) when fixing structure.
- For **`type: sayings`**, when applying this skill, MUST apply **Sayings emphasis** (next subsection, **`.cursor/skills/revise-emphasis/SKILL.md`**) on **`tldr`** and **`fluff`** first, then **Sayings card teaser** on **`description`**. Do **not** wait for a separate request for bold or a new teaser.
- For **`type: panel`** and other types (and for markdown **body** copy on any type), when the author **already wrote** the words, MAY add Markdown **`**bold**`** around existing words or short phrases **for emphasis only** if the user asked for emphasis, revise, tighten, or similar; otherwise MUST ask before adding bold. MUST NOT change the underlying words, add sentences, or reorder paragraphs under this rule.

### Tone and nuance (`type: sayings`)

- A saying can carry **multiple tones** depending on context: **warning** (to a friend who hesitates), **advice** (from mentor to protégé), **criticism** (of the system), or **resignation** (after a loss).
- **`fluff`** should reflect these nuances in usage examples, not just the negative/cynical reading.
- Alternate between **positive/resourceful** framing (agility, ingenuity, being sharp) and **negative/opportunistic** framing when the saying supports both.

### Human-first narrative (`type: sayings`)

- Start with the **human and their emotion**, not abstract analysis.
- **Weak:** "This reflects a resigned view of broken systems..."
- **Strong:** "It is the sigh of someone who finally understands how broken systems work..."
- Use direct address ("you", "your") to connect with the reader.
- After the emotional hook, the **next clause** MUST name a situation, use, or who-does-what (see **Hybrid prose**). Emotion alone is not enough.

### Hybrid prose (emotion + claim)

Cognitive-Memetics is **not** essay prose. Punch and street feeling are allowed. Empty polish is not.

Essays / video / Substack use **Explanatory prose** in **`.cursor/rules/content-markdown-writing.mdc`**. This section uses a **hybrid**: one emotional or cartoon beat, then a clear claim or scene. Full essay paragraphs are optional only when a post deliberately adds body Article copy.

**Applies when drafting or when the user asks to rewrite, revise, or tighten** `description`, `tldr`, `fluff`, or body under `content/cognitive-memetics/`.

#### By field

| Field / format | Punchy by design? | MUST | MUST NOT |
|----------------|-------------------|------|----------|
| Cube-cows `description` | Yes (often the whole piece) | Name an office move or joke claim the strip pays off | Oracular closers with no workplace mechanism |
| Sayings `tldr` | Yes (short) | Name meaning, use, or scene | Trait-dictionary stacks only ("clever, astute, street-smart") |
| Sayings `fluff` | Situational context | Lead with emotion or **one** clarifying metaphor, then when/who uses it; concrete scenes | Metaphor-only fluff with no uses; metaphor stacks; mystical/abstract culture praise |
| Psych-Fitness `tldr` | Campaign vignette + lesson | End on the fitness/mechanism line when needed | Caption pivots: "The long view matters.", "The connection is direct.", "The eve of decision." |
| Reptilocracy `tldr` / `fluff` | Satire punch OK | Keep bait-and-switch / institution mechanism concrete | Aphorism quotes that restate the claim prettier after it is already clear |
| T-Shirt Art teaser / `tldr` | Merch line OK | Tie the slogan to one mechanism or threat | Slogan-only copy with no so-what |
| Project "But why" (`i18n`) | Manifesto-tinged OK | Name series mechanism once | Do not copy that lyric tone into every episode field |

#### Rules

- MUST keep **one** street/cartoon emotional hook when it helps; the **next** clause MUST name who does what, when someone says it, or what changes if true.
- MUST prefer one concrete scene or use-case over a prettier restatement of the same thesis.
- MUST cut or merge a line that fails: *If this stood alone, would it add a fact, scene, or use?*
- MUST NOT ship **punch closers** that only remix the claim ("The X matters.", "The connection is…", "The eve of…").
- MUST NOT write **revelation stacks** in episode copy (several one-line poetic beats with no mechanism). That ban is for essays in **revise-post** Step 2; here the hybrid still forbids empty stacks.
- MAY keep a short staccato teaser on cube-cows or shirt lines when the claim is still legible ("**Dream big**, commute **bigger**.").
- Project footers MAY stay manifesto-tinged; **episode** `tldr` / `fluff` / `description` MUST stay hybrid, not essay-oracle.

#### Street Wisdom `fluff` (looser metaphor)

For **`Por-Estas-Calles`** / Street Wisdom **`fluff` only**:

- MAY open with **one** literary or street metaphor when it clarifies feeling or stance (for example "warm, **polite fence paint**", "the **sigh** of someone who…").
- MUST follow that metaphor with **concrete uses** (when you say it, to whom, in what setting). If uses are missing, cut or rewrite the metaphor.
- MUST NOT stack two or more literary metaphors in the same `fluff` block.
- MUST NOT let the metaphor remix the thesis without adding a use ("harmony with names still legible" alone fails; pair it with "You reach for it when…").
- **`tldr`** stays tighter: meaning + scene first; save the optional literary beat for `fluff`.

#### Do / Don't (from shipped posts)

| Do (hybrid) | Don't (empty polish) |
|-------------|----------------------|
| "It is the **sigh** of someone who finally understands how broken systems work… You use it when someone **beat you to it**…" (`saying-19` fluff) | "extremely **clever**, **astute**, and **street-smart**… that kind of **street smarts**, that **practical intelligence**…" (`saying-01` fluff) |
| One metaphor + uses: "warm, **polite fence paint**… You reach for it when proximity is real but **fusion** would cost trust." (`saying-21` shape) | Metaphor stack with no uses: "fence paint… harmony with names still legible…" and stop |
| Sully vignette → "**Psychological fitness checks** help maintain that capacity." (`psych-fitness` day-03) | Mandela vignette → "The long view matters." (`psych-fitness` day-24) |
| "This week, management refreshes **Our Values**: **think big**… but don’t go overboard." (cube-cows) | "The connection is direct." / "The eve of decision." as standalone closers |
| Wage freeze → executive bonus; levy → consultant fees; then name the **bait-and-switch** (reptilocracy) | "We inherit the future from no one, so we spend it freely." as a floating aphorism after the mechanism is clear |

**Gold reference for Street Wisdom fluff:** `content/cognitive-memetics/sayings/2026-05-18-saying-19/` (`fluff`: emotion → uses → settings).  
**Gold reference for Psych-Fitness:** `content/cognitive-memetics/psych-fitness-28/2026-05-04-day-03-clear-thinking/` (scene → mechanism; no oracle coda).

### Sayings emphasis (`type: sayings`)

- MUST follow **`.cursor/skills/revise-emphasis/SKILL.md`** for how much and which words get **`**bold**`** in **`tldr`**, **`fluff`**, and (lightly) **`description`**. Default is **restrained** emphasis (a few strong hooks per block), not wall-to-wall bold.
- When wrapping author text, MUST wrap **only** substrings that already appear in the author’s text; MUST NOT change, add, or remove words, or reorder sentences.
- MUST NOT “fill” **`tldr`** or **`fluff`** with extra bold to match an older dense-scan style **unless** the user asks for that legacy style. If the user asks to **fix** or **reduce** bold, MUST trim per **revise-emphasis** (markup-only is allowed without a separate prose pass).

### Sayings card teaser (`description`, `type: sayings`)

- When applying this skill, MUST set or replace **`description`** with a **short** card teaser **derived only** from **`title`**, **`tldr`**, and **`fluff`** (if **`fluff`** is absent or empty, use **`title`** and **`tldr`** only). Read **`title`** as the episode anchor (often the Spanish saying); read **`tldr`** and **`fluff`** after **Sayings emphasis** so the teaser matches the list/detail copy.
- MUST NOT invent facts, examples, or tone that are not supported by those three fields together. MAY use **`**bold**`** on key phrases in the teaser you write. Follow **`.cursor/rules/content-markdown-writing.mdc`** (English, no em dash, short sentences).
- MUST NOT change **`title`**, **`tldr`**, or **`fluff`** while drafting the teaser unless the user asked for a prose edit to those fields.
- **No echo rule:** `description` MUST NOT repeat key words already in `title` or `tldr`. If `title` is "The rat and the cheese", `description` should not use "rat" or "cheese". Find an evocative pitch that complements without echoing.

## Front matter conventions

### Shared

- **`date`**, **`title`**, **`draft`** — **`date`** MUST follow **`.cursor/rules/content-markdown-writing.mdc`** → **Publish `date`** (default **`date: 'YYYY-MM-DDT01:00:00+11:00'`**).
- **`title`**: MUST **not** use **leading emoji** in **`title`**. **Cognitive-Memetics** opts out of **Optional leading emoji in `title`** in **`.cursor/rules/content-markdown-writing.mdc`** (which applies to **`social-protocols`**, **`human-condition`**, and **`mind-infrastructure`** only). Keep the episode or saying line in plain words; use optional **`heading_code`** when you want a compact prefix in the UI.
- **`heading_code`** (optional): short label before the title (e.g. `W6`, `W13`). Rendered via `layouts/partials/heading-title-markup.html` with class `heading-code--tldr`.
- **`categories`**: Use **two** terms so each post belongs to the section **and** to a **project hub** you can link to (Hugo taxonomy list pages under `/categories/<slug>/`).
  - **Umbrella:** always **`Cognitive-Memetics`** (this site area).
  - **Project (pick one):** **`Cube-Cows`** for **`type: panel`** (the **Tales from the Cube Farm** series; Hugo taxonomy term for the shareable hub at `/categories/cube-cows/`). **`Por-Estas-Calles`** for **Street Wisdom** **`type: sayings`** posts (Venezuelan sayings series). **`T-Shirt Art`** for visual / merch-style pieces (often **`type: sayings`** with art as featured image; **`type: panel`** if you want a longer essay under the same hub). **`Reptilocracy`** for the reptile-institutions satire line. **`Pawtropolis-Under-Fire`** for **Pawtropolis (Under Fire)** (pets in a cartoon war zone; hub slug is typically `/categories/pawtropolis-under-fire/`).
  Example YAML:

  ```yaml
  categories: ["Cognitive-Memetics", "Cube-Cows"]   # type: panel (cube-cow / Tales from the Cube Farm)
  ```

  ```yaml
  categories: ["Cognitive-Memetics", "Por-Estas-Calles"]       # Street Wisdom sayings
  ```

  ```yaml
  categories: ["Cognitive-Memetics", "Pawtropolis-Under-Fire"]   # Pawtropolis (Under Fire)
  ```

  Hugo flattens categories (no true parent/child in core), but two terms give a **shareable URL** for “everything in this project” while the section path still scopes content by folder.
- **`tags`**: Punchy **PascalCase** hooks (no placeholder terms). Prefer three to five tags; see **`content/cognitive-memetics/`** examples. Align with **`.cursor/skills/claims-content/SKILL.md`** *Tag voice* for shape and reuse, but topics here are cube-cows, sayings, and culture notes—not Claim/Grounding jargon unless you intend it.
- **Featured image**: Prefer **`featuredImage: "file.ext"`** and optional **`featuredImagePreview: "file.ext"`** (page-bundle local resource). Use this for the card / detail hero image (put the file in the page bundle). If you need advanced resource metadata, you MAY instead use `resources` with `name: "featured-image"` and `src: "file.ext"`.

### `type: panel`

- **`description`**: Teaser for cards / list; on the **detail** page it becomes the **Teaser** block (markdownified). For this site, **that is usually the whole piece**; do **not** add body copy unless you deliberately want a long follow-up.
- **`project`** (optional but recommended for **Tales from the Cube Farm**): The recurring **series line** on the detail hero (e.g. `Cube-Cows 🐮📈`). **`title`** must be a **unique episode name** (lists, prev/next links, browser tab). Without `project`, the layout falls back to `heading_code` + `title` everywhere (legacy one-line titles).
- **Optional** body markdown below `<!--more-->`: only when you need an **Article** section (`layouts/panel/single.html`). If the body is empty, the single shows **Teaser** only.

Archetype: **`archetypes/panel.md`**.

#### Tales from the Cube Farm (why cube-cows exist)

The **Hugo category** (second `categories` term) for these posts is **`Cube-Cows`**. The **series name** in copy stays **Tales from the Cube Farm**.

**Canonical series explainer** (site "But why" footer, Substack paste, LinkedIn **`🟣`** series block): **`cowsProjectAboutTitle`** / **`cowsProjectAboutBody`** in **`i18n/en.toml`** and **`i18n/es.toml`**. **MUST NOT** duplicate or paraphrase that body in this skill. LinkedIn generation: **`.cursor/skills/linkedin-post/SKILL.md`**.

**Publish day (Cube-Cows only):** New **`type: panel`** bundles under **`content/cognitive-memetics/cows/`** MUST use a **Wednesday** calendar day in the bundle folder name and in **`date`** (from **W13 / 2026-05-20** onward). Older episodes may stay on their original Thursday dates; do not retro-shift published weeks unless the author asks.

**Tags for `panel`:** Always include **`CubeCows`**. Add **recurring theme** tags when the joke fits (for example **`AGIHype`** when the strip is about AI hype). Add **one or two episode-specific** tags for that week’s punchline; do not force-reuse narrow joke tags across unrelated weeks.

**LinkedIn post format:** Use **`.cursor/skills/linkedin-post/SKILL.md`** (*Cube cows / Tales from the Cube Farm* **fold-first layout**): quoted `description` teaser on **line one** only, then **`🟣`** + **`{heading_code}: Cube-Cows 🐮📈`** and series paragraphs from **`cowsProjectAboutBody`** (no `❓ BUT WHY:` label on image-only strips), one hashtag line with **all** `tags` from front matter, **`🧷 Full post (site) →`** (EN then ES when bilingual), then **English** **`Cube-Cows`** category URL (`/categories/cube-cows/`). Save as `linkedin.txt` in the page bundle.

### `type: sayings`

- **`description`**: Short teaser for cards. When applying this skill, MUST set it per **Sayings card teaser** from **`title`**, **`tldr`**, and **`fluff`** (after **Sayings scan emphasis** on the latter two).
- **`tldr`**: Main “TLDR” block (shown in list and on the single layout). When applying this skill, MUST include restrained **`**bold**`** per **`.cursor/skills/revise-emphasis/SKILL.md`**.
- **`fluff`**: “Context” block (optional second column on list; shown on single). When present and when applying this skill, MUST include restrained **`**bold**`** per **revise-emphasis**.
- **`project`** (optional): Recurring **series line** on the detail hero. For **Por-Estas-Calles** / Street Wisdom sayings, use the canonical **`Street-Wisdom 💬🇻🇪`** (speech balloon + Venezuelan flag); keep **`ArepaContigo`** in **`tags`** only. **`title`** should be the **unique** episode name (Spanish saying, etc.) for lists, prev/next, and the tab. Without `project`, the layout uses one-line `heading_code` + `title` everywhere.

Archetype: **`archetypes/sayings.md`**.

### Por-Estas-Calles (Venezuelan sayings / Street Wisdom)

Some **`type: sayings`** posts translate **Venezuelan street wisdom** for an English audience. They usually use **`categories`**: **`Cognitive-Memetics`** and **`Por-Estas-Calles`** (shareable hub at `/categories/por-estas-calles/`). For the detail hero, set **`project: Street-Wisdom 💬🇻🇪`** on every bundle; **`linkedin.txt`** uses the **fold-first** Por-Estas-Calles layout (quoted saying, then **`❓`** / **`AND:`** / **`🔤 IN ENGLISH`**, then **`🟣`** + **`{heading_code}: {project}`**; see **`.cursor/skills/linkedin-post/SKILL.md`** → **Sayings / Street Wisdom**).

**Canonical series explainer** (site "But why" footer, Substack paste, LinkedIn **`🟣`** series block): **`sayingsProjectAboutTitle`**, **`sayingsProjectAboutP1`**, **`sayingsProjectAboutP2`** in **`i18n/en.toml`** and **`i18n/es.toml`**. **MUST NOT** duplicate or paraphrase that body in this skill.

**LinkedIn hashtags** (use on LinkedIn with `#`; in Hugo front matter use **PascalCase** and **no** `#` character):

| LinkedIn | Hugo `tags` value |
|----------|-------------------|
| `#StreetWisdom` | `StreetWisdom` |
| `#CulturalStopwatch` | `CulturalStopwatch` |
| `#TakeBackYourMcDonaldsCulture` | `TakeBackYourMcDonaldsCulture` |
| `#ArepaContigo` | `ArepaContigo` |

For Venezuelan saying posts, **include those four tags** when promoting the series, plus **`VenezuelanSayings`** and optional **post-specific** tags (one or two hooks for that saying). Keep total tags roughly **five to seven** if you add both series tags and a hook.

**LinkedIn post format:** Use **`.cursor/skills/linkedin-post/SKILL.md`** (sayings / Street Wisdom **fold-first layout**): quoted **`title`** only on line one; then **`❓`** + `tldr`, **`AND:`** + `fluff`, **`🔤 IN ENGLISH`**, **`🟣`** + **`{heading_code}: Street-Wisdom 💬🇻🇪`** + series paragraphs from **`sayingsProjectAboutP1`** / **`P2`**, hashtags, **`🖋️ Full post (site) →`** (ES then EN when bilingual), **`🔗 Por-Estas-Calles (English) →`** hub URL. Reference: `content/cognitive-memetics/sayings/2026-06-01-saying-21/linkedin.txt`.

### T-Shirt Art

Posts in this line use **`categories`**: **`Cognitive-Memetics`** and **`T-Shirt Art`**. The shareable hub lists everything with that category (URL slug is generated by Hugo from the label).

- **`type`:** Prefer **`sayings`** when you want **Teaser** / **TLDR** / **Context** plus a featured image of the graphic. Use **`panel`** when the piece is a longer essay with the art as hero.
- **`project`:** Set a recurring **series line** on the detail hero (for example **`T-Shirt Art`** or a short branded label). Match the voice you want on the card; **`title`** stays the unique episode name.
- **`description` (Teaser):** Same **Sayings card teaser** rules as other **`type: sayings`** posts (from **`title`**, **`tldr`**, **`fluff`**). Keep it **short**; **`project`** and **`categories`** already show the series; MUST NOT open with redundant meta like “T-Shirt Art piece,” “this post,” or “in this entry.” Jump straight into substance.
- **`tldr`:** Same **Sayings emphasis** rules as other **`type: sayings`** posts (**`.cursor/skills/revise-emphasis/SKILL.md`**). MUST NOT change the author’s words; only add, trim, or adjust **`**bold**`** on existing text.
- **`title`:** Unique **episode** name; **two-beat** parallels (for example *cheap X, expensive Y* or *prepare, then advance*) read well as a line without extra labels.
- **`tags`:** Include **`TShirtArt`** plus **two to four** post-specific hooks (themes, mood, format). Do **not** add the **Street Wisdom** LinkedIn set unless the post is also part of that project.
- **Footer explainer:** The Venezuelan **“But why”** block on **`type: sayings`** singles appears only when the post includes the **`Por-Estas-Calles`** category (`layouts/sayings/single.html`). **T-Shirt Art** sayings do not show that block.
- **Facebook friends copy:** **`.cursor/skills/facebook-post/SKILL.md`** (not LinkedIn shape); see **Sm(art) / T-Shirt Art (Facebook)** there.

## Layouts and list UI

- Singles: **`layouts/panel/single.html`**, **`layouts/sayings/single.html`**
- Section / home rows: **`layouts/partials/seven-style-row.html`** (claims vs sayings vs default teaser columns)

### Detail singles (parity with social-protocols / `type: claims`)

Single pages for **`panel`** and **`sayings`** follow the same UX pattern as **`layouts/claims/single.html`**:

- **`tags`**: Shown **under the featured image** (not duplicated in the article footer). Footer tag list is suppressed for these types via **`layouts/partials/single/footer.html`**.
- **`type: panel`**: When **`description`** is set, the detail page renders **Teaser** (`#section-teaser`). **Article** (`#section-essay`) appears only when the markdown body is non-empty; merged **Contents** use **`layouts/partials/cows-table-of-contents.html`** when there is a body with headings. With **`project`** set, the detail **h1** uses **`heading-series-single.html`**; lists use **`heading-series-list.html`** (via **`heading-title-markup.html`**).
- **`type: sayings`**: Same **`project`** / **`title`** split as **`panel`** when **`project`** is set (shared **`heading-series-*.html`** partials). Additionally:
  - **Teaser** (`description`), **TLDR** (`tldr`), and **Context** (`fluff`) are rendered as sections with stable anchors **`#section-teaser`**, **`#section-tldr`**, **`#section-context`** when present. Front-matter strings are **markdownified** like claims `description`.
  - If any of those blocks exist **and** the post has a non-empty body, the main markdown is introduced by an **Article** section with anchor **`#section-essay`** (i18n key **`sayingsArticle`**).
  - **Contents** is a **merged** nav: **`layouts/partials/sayings-table-of-contents.html`** combines Teaser / TLDR / Context links with body heading links from the built TOC; when Article wraps the body, in-body heading links nest under **Article** (same idea as **Thoughts** nesting on claims).

### Body extensions (`type: sayings`)

- Use `###` headings for body extensions (e.g. `### In English`, `### Why the devil, why the underwear`).
- Keep extensions concise: focus on cross-language mapping (English equivalents) and specific nuances (e.g. "forsaken" vs "far") rather than general cultural rhetoric.
- Use blockquotes (`>`) for lists of equivalent expressions, including the introductory line (e.g. `> Closest English equivalents include:`).
- MUST NOT use em dashes (—) in body copy; use semicolon or colon instead.

**Body complements, does not repeat:**
- The body should **add depth**, not restate what `tldr` and `fluff` already said.
- If `tldr` explained the structure (e.g., "either X or Y"), the body should explore **consequences** or **cultural context**, not repeat the binary structure.
- Eliminate "process-explaining" phrases: "This means that...", "The metaphor shows that...", "This exaggeration underscores...". Go straight to the impact.
- Plan **vocabulary variation**: if `tldr` uses "trap", `fluff` or body should use a different term ("bind", "dilemma", "squeeze") or a different angle on the same mechanism.

For **`type: claims`** (Claim / Thoughts / Grounding), authoring rules stay in **`.cursor/skills/claims-content/SKILL.md`**.

## Bundle layout

Use one folder per post with **`index.md`** and assets beside it, for example:

`content/cognitive-memetics/2006-04-02-cow-w06/index.md` + `agi.png`

## Theme and style

- Site overrides: **`assets/css/_custom.scss`** (prefer not editing `themes/LoveIt/`).
- LoveIt how-tos: **`themes/LoveIt/exampleSite/content/posts/`** (see **`.cursor/rules/always-rules-3-hugo.mdc`** index).

### Project "But why" explainer cards (detail footers)

- **Shared look (site-wide):** After the article on **`type: panel`**, **`type: sayings`** (when the Street Wisdom partial shows), **Reptilocracy** singles, and **Pawtropolis-Under-Fire** singles, the **"But why"** explainer is a **gradient card** (warm wash, left accent stripe, soft shadow, circular **❓** mark, slightly roomier body type). Styles live under **`assets/css/_custom.scss`** for **`.cow-project-about`** and **`.sayings-project-about`** together (same shell). Partials: **`layouts/partials/cows-project-about.html`**, **`layouts/partials/sayings-project-about.html`**, **`layouts/partials/reptilocracy-project-about.html`** (Reptilocracy also adds **`reptilocracy-project-about`** for extra rules only), **`layouts/partials/pawtropolis-project-about.html`**.
- **MUST NOT** add duplicate or conflicting card chrome for these explainers in other SCSS files or inline styles unless the user explicitly asks for an exception; extend the shared block in **`_custom.scss`** so Cube-Cows, Street Wisdom, Reptilocracy, and Pawtropolis stay visually aligned.
- **Reptilocracy-only:** After **`reptilocracyProjectAboutBody`** (markdown), **`layouts/partials/reptilocracy-project-about.html`** renders a small **CTA row**: **`reptilocracyProjectAboutCtaTitle`** as a **`span`** (not a paragraph, so it lines up cleanly with the pill) plus **`reptilocracyProjectAboutCtaButton`**; the petition URL lives in that partial. Companion styles use **`.reptilocracy-project-about__cta*`** in **`_custom.scss`**. Do not reuse that CTA pattern on Cube-Cows or Street Wisdom explainers.
- **Copy source (canonical; do not paraphrase in this skill):** Tales from the Cube Farm → **`cowsProjectAbout*`**; Street Wisdom → **`sayingsProjectAbout*`**; Reptilocracy → **`reptilocracyProjectAboutBody`** plus **`reptilocracyProjectAboutCtaTitle`** / **`reptilocracyProjectAboutCtaButton`**; Pawtropolis → **`pawtropolisProjectAboutTitle`** / **`pawtropolisProjectAboutBody`**. All live in **`i18n/en.toml`** / **`i18n/es.toml`**. LinkedIn series blocks: **`.cursor/skills/linkedin-post/SKILL.md`**.

## References in this repo

- **`hugo.toml`**: menu entry and `contentSections` for the home feed.
- **Emphasis (Markdown bold):** **`.cursor/skills/revise-emphasis/SKILL.md`**
- Examples: **`content/cognitive-memetics/2006-04-02-cow-w06/`** (`type: panel`), **`content/cognitive-memetics/2006-04-06-saying-13/`** (`type: sayings`).
