---
name: essay-command-center
description: >-
  Operates the essays pipeline through content-pipelines MCP and the browser command
  center: human-driven WIP, essay_create, essay_board, verb tools (arc/composition
  generate/regenerate/pick), then checkout/review/submit. Use when the user
  starts an essay, runs the essays pipeline, asks about piece_id, command center,
  essay board, arc proposal, composition review, or content-pipelines MCP essay tools. Do not
  auto-chain the full pipeline unless the user explicitly asks for one-shot run.
---

# Essay command center (content-pipelines MCP)

## Role

You are the **operator's assistant**, not the pipeline autopilot. Postgres holds artifact facts; the human (or explicit user instruction) chooses the next verb. Steps show run history on the board; **every step stays re-runnable** with feedback.

## Prerequisites

- `make serve` running (content-pipelines MCP on `http://127.0.0.1:3849/mcp` per `.cursor/mcp.json`)
- `providers/content-pipelines-mcp` symlink (run `./scripts/link-providers.sh` or `make serve`; gitignored)
- `content-pipelines-mcp.yaml`: `review_pipeline: essays`
- `process-compose.yaml`: `PIPELINES_BIN` / `PIPELINES_DIR` point at `providers/content-pipelines`
- Postgres + Meilisearch up for `pipelines essays` (see n8n README)
- Rebuild `bin/pipelines` after content-pipelines CLI changes

## Philosophy (non-negotiable)

1. **No silent auto-advance** after `essay_create` unless the user asked for a one-shot run.
2. Call **`essay_board`** after every mutating tool to refresh facts before suggesting the next action.
3. **`status`** = review queue only (pending composition for Gate). **`essay_board`** = full WIP (step run counts, actions, focus).
4. Use **`essay_focus_set`** when the operator shifts context (e.g. "reworking hook after disagree").
5. Prefer opening **`command_center_url`** or **`review_url`** in the browser when the user wants a visible panel.
6. **No Hugo export yet**: approved essays stay in Postgres; do not copy into `content/` unless a future export exists.

## MCP tools

| Tool | When |
|------|------|
| `essay_create` | New piece: `title`, `notes_files` (array), and/or `notes_file`, optional `notes` preface, optional `stance` / `charge` |
| `essay_board` | Always after mutations; start of each operator turn |
| `essay_focus_set` | Operator WIP label: `focus`, optional `bookmark` |
| `essay_arc_proposal_generate` | First arc pass; use `auto_select: true` or `arc: trap_conundrum_fork` to skip TUI |
| `essay_arc_proposal_regenerate` | Re-run arc with `message` feedback |
| `essay_arc_pick` | Pick catalog id from latest proposal without LLM (`arc` required) |
| `essay_composition_generate` | Compose essay; needs selected arc (or `arc` override) |
| `essay_composition_regenerate` | Re-compose with `message` |
| `checkout` | Export pending composition to `checkout_dir`; returns `review_url` |
| `submit` | `alignment` agree\|disagree, optional `message`, optional `context` (edited body) |
| `status` | Review queue snapshot only |

## Operator loop

```
essay_create (or resume with piece_id)
  → essay_board
  → [operator picks verb]
  → run one verb tool
  → essay_board
  → repeat
```

When `essay_board` shows `review.pending`, offer **checkout** then open `review_url` (or `http://127.0.0.1:3849/review`).

## Starting with context files

Use **`notes_files`** on `essay_create` to pass multiple paths (site-relative or absolute). Sitekit merges them into workspace `notes.md` with `## path` section headers. Optional **`notes`** is a short operator preface (`## Operator notes`).

Typical bundle for a claim-shaped essay:

```json
{
  "title": "Working title",
  "notes": "Turn the grounding into a full essay; keep Claim/Grounding voice.",
  "notes_files": [
    "content/social-protocols/some-claim/index.md",
    ".cursor/skills/claims-content/SKILL.md"
  ]
}
```

- **`notes_file`** still works for a single source (backward compatible).
- Duplicate paths are deduped. Response includes `notes_sources` with the section labels used.
- The agent does not need to stitch files manually when paths are known; still read files first if the user only @-mentions content without paths.

## Browser UI

- Command center: `http://127.0.0.1:3849/command-center?piece_id=<UUID>`
- Review panel: `http://127.0.0.1:3849/review` (after checkout)
- Workspace files: `tmp/essay-workspaces/<piece_id>/` (`notes.md`, `run.json`)

## Arc selection (MCP)

Interactive `pipelines essays arc-proposal generate` prompts in the terminal. For MCP, use one of:

- `essay_arc_proposal_generate` with `auto_select: true`
- `essay_arc_proposal_generate` with `arc: trap_conundrum_fork` (only mapped arc for composition today)
- `essay_arc_pick` after generate when the user names a catalog id from `essay_board` / prior output

Catalog reference: `docs/features/essay-reader-arcs.md` in content-pipelines (n8n repo).

## Long-running jobs

`essay_arc_proposal_*` and `essay_composition_*` block until the CLI finishes (minutes). If MCP times out, run the same command in the n8n repo terminal, then `essay_board` again.

Example CLI (equivalent):

```bash
cd /path/to/n8n
bin/pipelines essays arc-proposal generate <piece-id> --auto-select --json
bin/pipelines essays composition generate <piece-id> --json
bin/pipelines essays board <piece-id> --json
```

## Suggesting next actions

Use `essay_board.steps` and `actions` as **hints**, not gates. The operator may regenerate arc after composition, or pick a new arc. List 2-3 sensible options; ask which verb to run unless the user already chose.

## After agree (review)

Composition approved in Gate. There is no Hugo export step in v1. Tell the user the piece is approved in Postgres; do not invent `content/` paths.

## Verification

After a mutating tool or before declaring a step "done", prefer delegating to the **essay-verifier** subagent (`.cursor/agents/essay-verifier.md`) or manually call `essay_board` and confirm `piece_id`, step `run_count`, and `last_status` match intent.
