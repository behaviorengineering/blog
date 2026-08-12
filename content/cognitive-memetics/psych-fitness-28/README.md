---
draft: false
headless: true
_build:
  render: never
  list: never
---

# Psych-Fitness 28 Campaign

28 days of content supporting Australian Parliament petition EN9806 for psychological fitness checks for top leaders.

## Folder Structure

```
content/cognitive-memetics/psych-fitness-28/
├── _index.md                          # Section index (English)
├── _index.es.md                       # Section index (Spanish)
├── README.md                          # This file
├── 2026-05-04-day-03-clear-thinking/  # Day 3 bundle
│   ├── index.md                       # English post
│   ├── index.es.md                    # Spanish post
│   ├── 03.webp                         # Daily image
│   ├── linkedin.txt                   # LinkedIn post text
│   └── social-published               # Marker file (created after publishing)
├── 2026-05-05-day-04-.../             # Day 4 bundle
└── ...
```

## Creating a New Day

Use the archetype:

```bash
hugo new content cognitive-memetics/psych-fitness-28/2026-05-05-day-04-mental-fitness-flows/index.md --kind psych-fitness-28
```

Then:
1. Copy the daily image (`04.webp`) into the bundle folder
2. Update `featuredImage: "04.webp"` in both `index.md` and `index.es.md`
3. Fill in `heading_code: D4`
4. Write the English content in `index.md`
5. Write the Spanish content in `index.es.md`
6. Generate `linkedin.txt` using the LinkedIn post skill

## Publishing Workflow

1. **Hugo site**: Posts go live on the site based on `date` front matter
2. **Substack**: Use `substack-draft` command to create drafts
3. **LinkedIn**: Use `linkedin-draft` command (to be built) to create API drafts, then `linkedin-publish` to schedule

## Marker File Format

`social-published` tracks what has been published where:

```
# <target> <RFC3339-UTC>
substack-en 2026-05-04T01:00:00Z
substack-es 2026-05-04T01:00:00Z
linkedin 2026-05-04T09:00:00Z
```

## URL Structure

- Hub (English): `/categories/psych-fitness-28/`
- Day 3 (English): `/cognitive-memetics/psych-fitness-28/2026-05-04-day-03-clear-thinking/`
- Day 3 (Spanish): `/es/cognitive-memetics/psych-fitness-28/2026-05-04-day-03-clear-thinking/`

## Campaign Tags (Front Matter)

Always include:
- `PsychFitness` / `PsiqueFitness`
- `Leadership` / `Liderazgo`
- `EN9806`
- `MentalFitness` / `SaludMental`

Add 2-3 day-specific tags.
