---
name: ask-polypus
description: >-
  Host overlay for Polypus consults on this Hugo site. Follow pack ask-polypus
  for BASE discovery and health, then use gemini_paid Gemma 4 (not gemini_free,
  not Cloudflare cf_local) unless the operator names another prefixed id.
  Triggers: ask gemma, ask polypus, curiosity title, local eval, POLYPUS_URL.
---

# Ask Polypus (site overlay)

**Moral:** This host already points editorial Gemma at Google AI Studio **paid** on Polypus. Pack `ask-polypus` still defaults to `cf_local/@cf/google/gemma-4-26b-a4b-it`. On this site, the pack discovery/health steps still apply; the **default model does not**.

Generic pack skill: `.cursor/packs/shared/skills/ask-polypus/SKILL.md`.

## Defaults (this host)

| Setting | Value |
| --- | --- |
| Base URL | `POLYPUS_URL`, then `POLYPUS_BASE_URL`, then `https://polypus.manticore-powan.ts.net`; loopback `http://127.0.0.1:1320` only when those are empty |
| Chat path | `POST /v1/chat/completions` |
| Default model | `gemini_paid/gemma-4-26b-a4b-it` |
| Health | `GET /health` |

**CONSTRAINT:** MUST NOT use `gemini_free/` on this host. MUST NOT default to `cf_local/@cf/google/gemma-*` when the operator says Gemma / ask Polypus without another id.

- MUST: use `LOCAL_LLM_MODEL` when set (`.envrc` exports `gemini_paid/gemma-4-26b-a4b-it`)
- MUST: otherwise use `gemini_paid/gemma-4-26b-a4b-it`
- MUST: allow a named prefixed id (`gemini_paid/`, `deepinfra/`, `openrouter/`, `cf_local/`, `lm_studio/`, `router/`) when the operator asked for that id
- MUST NOT: call Cloudflare, Workers AI, or Google URLs directly; stay on `${BASE}/v1/chat/completions`

CORRECT:
```json
{
  "model": "gemini_paid/gemma-4-26b-a4b-it",
  "messages": [{"role": "user", "content": "..."}]
}
```

PROHIBITED:
```text
gemini_free/gemma-4-26b-a4b-it
cf_local/@cf/google/gemma-4-26b-a4b-it as the unnamed Gemma default
```

## Pack steps that still apply

1. Discover `BASE` (`POLYPUS_URL` / `POLYPUS_BASE_URL` before loopback).
2. Probe `GET ${BASE}/health`.
3. Include the artifact in the prompt.
4. Synthesize for the human; do not treat the consult as an implement order.

Do not send CF `enable_thinking`. `gemini_paid` may return `reasoning_details`.
