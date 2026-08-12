# Revise prose (evaluate only)

Local human-friendliness critique for a Hugo post. **Diagnose only; do not edit `content/`.**

Full workflow: **`.cursor/skills/revise-prose/SKILL.md`**.

---

## Procedure

1. Resolve the target path:
   - Path the user names, or
   - Focused / open file under `content/` (prefer English `index.md`), or
   - Ask if unclear.

2. Scope: `full` unless the user asks for `list` or `body`.

3. Run (from repo root). **Default mode is progressive** (each list field / paragraph with prior as context, then overall synthesis):

```bash
python3 .cursor/skills/revise-prose/scripts/evaluate_prose.py \
  <path-to-index.md> \
  --scope full
```

Optional:

- `--mode whole` for a single full-text pass
- `--model @cf/zai-org/glm-4.7-flash` for a second opinion
- `--out docs/research/YYYY-MM-DD-local-prose-<slug>.md` to save the report
- Env: `LOCAL_LLM_BASE_URL` (default `http://127.0.0.1:1320/v1`), `LOCAL_LLM_MODEL`, `LOCAL_LLM_API_KEY`

4. Surface the **full report** (per-unit sections + Overall synthesis). Do not silently rewrite the draft.

5. Hand off (only if the user wants fixes applied):

- `.cursor/skills/revise-post/SKILL.md` Steps 2, 3, 5
- `.cursor/skills/revise-flow/SKILL.md`

---

## Constraints

- MUST NOT edit `content/` from this command.
- MUST fail loudly if the gateway is down or the model is disallowed.
- Out of scope: Spanish evaluate, fact-checking, automatic polish rewrites.
