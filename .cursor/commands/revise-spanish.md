# Revise Spanish (local Gemma evaluate)

Spanish naturalness **and meaning-load** audit via the local OpenAI-compatible gateway (default **Gemma 4**). **Diagnose only; do not edit `content/` until the user confirms.** Soft “improvements” that dilute contrasts or drop verb objects fail `conceptual_fidelity` (see skill).

**Index first:** prefer `--scope site` (or `body`) until `index.es.md` is Ready; sidecars are reflections and come after.

Full skill: **`.cursor/skills/revise-spanish/SKILL.md`**.

---

## Procedure

1. Resolve target bundle:
   - Path the user names (`index.es.md`, sidecar, or folder), or
   - Bundle of the focused Spanish file, or
   - Sibling of focused English `index.md` if `index.es.md` exists, or
   - Ask if unclear.

2. Run (from repo root). **Default for urgent repair: `--scope site`**. Use `--scope full` after the index is stable:

```bash
python3 .cursor/skills/revise-spanish/scripts/evaluate_spanish.py \
  <path-to-index.es.md-or-bundle> \
  --scope site
```

Optional:

- `--scope full|list|body|facebook|linkedin|substack`
- `--mode whole` for a single full-text pass
- `--model @cf/zai-org/glm-4.7-flash` (second opinion)
- `--out docs/research/YYYY-MM-DD-local-es-<slug>.md`
- Env: `LOCAL_LLM_BASE_URL` (default `http://127.0.0.1:1320/v1`), `LOCAL_LLM_MODEL`, `LOCAL_LLM_API_KEY`

**Line-by-line author edits:** apply surgical patches to `index.es.md` first; sync sidecars after. Do **not** call Gemma to “fix” intentional author calques.

3. Surface the **full report** (per-unit + Overall synthesis). Do not silently rewrite Spanish files.

4. Hand off after user confirms (`y` / `aplica` / *aplica* in same message):

- Apply quoted high-impact fixes to **`index.es.md` first**; then sync ES sidecars
- Full re-adapt: **revise-post-es**
- English bar-test twin: `/revise-prose`

---

## Constraints

- MUST NOT edit `content/` without confirmation (unless user already said apply).
- MUST NOT soft-rewrite precision terms (*patrón*, *clínico*) into generics just to sound smoother.
- MUST keep author micro-edits and conceptual contrasts when applying fixes.
- MUST NOT accept progressive rewrite output that bleeds body into `title`/`subtitle` or emits meta labels.
- MUST fail loudly if the gateway is down or the model is disallowed.
- Out of scope: inventing EN word-for-word fidelity; fact-checking sources. Meaning-load from EN context and author wording still counts.
- Reverse-translation test: if ES remounts as the EN sentence → fail and rewrite syntax.
