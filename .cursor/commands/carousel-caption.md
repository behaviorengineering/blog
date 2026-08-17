# LinkedIn carousel caption (Gemma 4)

Draft a short LinkedIn document caption from `carousel.json`. **Show three variants first; write `linkedin-carousel.txt` only after the user picks.**

Full skill: **`.cursor/skills/carousel-linkedin-caption/SKILL.md`**.

---

## Procedure

1. Resolve the bundle:
   - Path the user names, or
   - Focused `carousel.json`, or
   - Sibling of the focused post under `content/`.

2. Run (from repo root):

```bash
python3 .cursor/skills/carousel-linkedin-caption/scripts/draft_caption.py \
  <path-to-carousel.json>
```

3. Show the three numbered captions. Do not overwrite `linkedin.txt`.

4. After they pick `1` / `2` / `3`:

```bash
python3 .cursor/skills/carousel-linkedin-caption/scripts/draft_caption.py \
  <path-to-carousel.json> \
  --pick N
```

Env: `LOCAL_LLM_BASE_URL` (default `http://127.0.0.1:1320/v1`), `LOCAL_LLM_MODEL`, `LOCAL_LLM_API_KEY`.

---

## Constraints

- MUST NOT treat this as the full LinkedIn essay (`linkedin.txt`).
- MUST fail loudly if the gateway is down.
- MUST NOT use the em dash (U+2014).
