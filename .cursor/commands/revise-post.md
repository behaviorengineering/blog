# Revise post (full lot conductor)

Run the Hugo publish revise lot on a page bundle. **Analysis first; do not write `content/` until the user confirms apply.**

Full skill: **`.cursor/skills/revise-post/SKILL.md`**.

---

## Procedure

1. Resolve the target path:
   - Path the user names, or
   - Focused / open file under `content/` (prefer English `index.md`), or
   - Ask if unclear.

2. Pick **mode** (default **`rough`**):

| Token | Mode |
|-------|------|
| (none) / `rough` | Lot plan → heavy flow → hooks → Steps 1–3, 5 → fine flow → format last |
| `standard` | Lot plan → heavy flow → hooks → Steps 1–5 → format last |
| `polish` | Lot plan → hooks → Steps 1–3, 5 → fine flow → format last |
| `format-only` | Format only (no Gemma) |
| `checklist` | Lot plan → Steps 1–5 only (no heavy/fine flow) |

3. **Onion:** write a lot plan first (agent skim). Default Gemma is **`--scope list`** only, not one call per body paragraph. Unless the user already said `with gemma` / `skip gemma` / `format-only` / `plan only`, **stop and ask**:

`Local Gemma 4 list eval is on by default (title and card fields only). Reply y / with gemma to include it, or skip gemma for an agent-only plan.`

If AskQuestion is available, offer: Gemma 4 list (Recommended), Skip local eval.

4. Read the page **`type`** skill. Write the lot plan, then iterate remaining phases. `plan only` stops after the plan. Collect a **merged apply list**; do not write yet.

5. Present the report (mode, Gemma on/skipped, phases, Before/After, merged apply list). Ask: apply all / apply Phase N only / cancel.

6. Only after confirmation, write in phase order, then **`hugo build`** (or `make build`) when `content/` changed.

Optional: user says `with score` → add **revise-score** after format.

---

## Constraints

- MUST NOT auto-apply unless the user says apply without asking.
- MUST run **revise-format** (or deferred Step 4) so em dash Grep is not skipped.
- Focused passes alone: **revise-flow**, **revise-hooks**, or **revise-format** (not this command).
- Spanish sibling: **revise-post-es** after English.
