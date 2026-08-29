---
name: site-perplexity-research
description: >-
  Perplexity Browser MCP for this repo. Triggers: perplexity research, open in Perplexity,
  fact-check post, grounding hunt, prose review, human read, AI artifacts. Read packs/ before
  perplexity_research. Workflow id: site-perplexity-research.
---

# site — Perplexity research workflow

**Repo:** site  
**Workflow id:** site-perplexity-research

This document tells the **caller** (human or agent) how to run **Perplexity Pro** via the **Perplexity Browser MCP** for this repository: what to prepare, which tools to call, and where results go.

Perplexity output is **research input only**. Validate against primary sources and the target post before editing `content/` or `docs/research/`.

## When to use

- perplexity research
- open in Perplexity
- research a topic with Perplexity
- prose review / human read / does this sound like AI

## Workflows

| Workflow | Pack | Mode | When |
|----------|------|------|------|
| Deep research | `.cursor/skills/site-perplexity-research/packs/deep-research.md` | deep | Fact-check posts, find grounding sources, map interview claims to literature |
| Prose review | `.cursor/skills/site-perplexity-research/packs/prose-review.md` | search | Cold-read for human flow, voice, AI artifacts; not fact-checking |
| Revise prose (local) | `.cursor/skills/revise-prose/SKILL.md` | local API | Same diagnostic intent offline via `evaluate_prose.py` (evaluate only; no Perplexity) |

**Pick one pack per run.** Fact-check and prose review are separate submits.

## Tool priority

| Order | Method | When |
|-------|--------|------|
| 1 | **Perplexity Browser MCP** | `perplexity_research`, `perplexity_continue`, `perplexity_export`, `perplexity_session` |
| 2 | **Manual paste pack** | Login blocked, or human runs Perplexity in browser |
| 3 | **Generic browser automation** | Only if MCP returns `ui_changed` or equivalent |

Discover MCP tool schemas through your client's introspection before calling.

## Procedure (caller)

### 1. Prepare prompt

Read these repo paths first (source of truth):

- Target page bundle under `content/` (`index.md`, optional `index.es.md`, sidecars)
- Matching type skill (`.cursor/skills/claims-content/SKILL.md`, `video-content/SKILL.md`, etc.)
- `.cursor/rules/site-content-placement.mdc` when section or type is unclear
- Optional: `tmp/articles/`, prior `docs/research/`, `data/tag-register.txt`

Fill the matching pack:

- `.cursor/skills/site-perplexity-research/packs/deep-research.md` (facts, sources)
- `.cursor/skills/site-perplexity-research/packs/prose-review.md` (human read, AI artifacts)

For prose review, also skim `.cursor/skills/revise-post/SKILL.md` → **Step 2** so the pack's artifact list matches site rules.

Rules:

- Show the **full prepared prompt** to the human before `perplexity_research` when they are in the loop.
- Do **not** put secrets or customer identifiers in `title_hint`.
- Prompt body and cloud policy: Avoid secrets in title_hint. Prompt body may include repo context; cloud upload is your risk choice.

### 2. Session

```text
perplexity_session  action=status
```

If not logged in: human signs in in the headed window, then `perplexity_session` `action=wait_for_login`.

### 3. Research

```text
perplexity_research
  prompt:     <entire filled pack>
  mode:       deep | search
  title_hint: <short label, no secrets>
  session_id: <optional; default is often project folder name>
  timeout_ms: <optional>
```

Submit the **whole** pack in one `prompt`. Do not drip-feed the first submit through `perplexity_continue`.

### 4. Follow-up (optional)

```text
perplexity_continue  message=<follow-up>  thread_id=<optional>
```

Only after the initial `perplexity_research`.

### 5. Export

```text
perplexity_export  format=markdown  save_dir=<optional>
```

Default export dir: `PERPLEXITY_BROWSER_EXPORT_DIR` (often `~/.perplexity-browser-mcp/exports`).

If status is `export_manual`: share thread URL; one automated export attempt only.

### 6. After import

- Default export dir: PERPLEXITY_BROWSER_EXPORT_DIR (often ~/.perplexity-browser-mcp/exports).
- Summarize into docs/research/ or your team's research notes after human review.
- Do not commit raw Perplexity exports without editing and validation.

- Do not treat Perplexity output as source of truth.
- Do not auto-commit or merge research prose without human review.
- Do not drip-feed the first submit; use one full perplexity_research prompt.

## Research note (optional)

For non-trivial runs, create `docs/research/YYYY-MM-DD-perplexity-<slug>.md` with:

- Pack used (path) and prompt snapshot or link
- Thread URL / id
- Export file path
- Summary bullets and open questions

## Limits

- UI changes can break automation; fall back to manual paste when MCP fails
- Perplexity is not authoritative for this repo until validation rules pass
- Personal Pro use only; no credential harvesting

## Bootstrap

Regenerate scaffold: `perplexity-browser-mcp init --force` from this repo root.

MCP install: [perplexity-browser README](https://github.com/behaviorengineering/perplexity-browser).
