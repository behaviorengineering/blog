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
| (none) / `rough` | Heavy flow → hooks → Steps 1–3, 5 → fine flow → format last |
| `standard` | Heavy flow → hooks → Steps 1–5 → format last |
| `polish` | Hooks → Steps 1–3, 5 → fine flow → format last |
| `format-only` | Format only |
| `checklist` | Steps 1–5 only (no heavy/fine flow) |

3. Read the page **`type`** skill, then follow **revise-post** phase order for the chosen mode. Collect a **merged apply list**; do not write yet.

4. Present the report (mode, phases, Before/After, merged apply list). Ask: apply all / apply Phase N only / cancel.

5. Only after confirmation, write in phase order, then **`hugo build`** (or `make build`) when `content/` changed.

Optional: user says `with score` → add **revise-score** after format.

---

## Constraints

- MUST NOT auto-apply unless the user says apply without asking.
- MUST run **revise-format** (or deferred Step 4) so em dash Grep is not skipped.
- Focused passes alone: **revise-flow**, **revise-hooks**, or **revise-format** (not this command).
- Spanish sibling: **revise-post-es** after English.
