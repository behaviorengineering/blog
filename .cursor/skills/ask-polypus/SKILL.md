---
name: ask-polypus
description: >-
  Host overlay for Polypus consults on this Hugo site. Follow pack ask-polypus
  for BASE discovery and health, then use DeepInfra Gemma 4 (not gemini_free,
  not Cloudflare cf_local, not unnamed gemini_paid) unless the operator names
  another prefixed id. Triggers: ask gemma, ask polypus, curiosity title,
  local eval, POLYPUS_URL.
---

# Ask Polypus (site overlay)

**Moral:** This host points editorial Gemma at **DeepInfra** Gemma 4 26B on Polypus. Pack `ask-polypus` still defaults to `cf_local/@cf/google/gemma-4-26b-a4b-it`. On this site, the pack discovery/health steps still apply; the **default model does not**.

Generic pack skill: Cursor plugin `cursor-packs` skill `ask-polypus`.

## Defaults (this host)

| Setting | Value |
| --- | --- |
| Base URL | `POLYPUS_URL`, then `POLYPUS_BASE_URL`, then `https://polypus.manticore-powan.ts.net`; loopback `http://127.0.0.1:1320` only when those are empty |
| Chat path | `POST /v1/chat/completions` |
| Default model | `deepinfra/google/gemma-4-26B-A4B-it` |
| Health | `GET /health` |

**CONSTRAINT:** MUST NOT use `gemini_free/` on this host. MUST NOT default to `cf_local/@cf/google/gemma-*` when the operator says Gemma / ask Polypus without another id. MUST NOT default to `gemini_paid/gemma-4-26b-a4b-it` (thinking often returns empty `content` with `finish_reason: length`).

- MUST: use `LOCAL_LLM_MODEL` when set, unless it is `gemini_paid/gemma-*` (remap to `deepinfra/google/gemma-4-26B-A4B-it`)
- MUST: otherwise use `deepinfra/google/gemma-4-26B-A4B-it`
- MUST: allow a named prefixed id (`deepinfra/`, `gemini_paid/` for Gemini models, `openrouter/`, `cf_local/`, `lm_studio/`, `router/`) when the operator asked for that id
- MUST NOT: honor `LOCAL_LLM_MODEL=gemini_paid/gemma-*` as a Gemma default
- MUST NOT: call Cloudflare, Workers AI, or Google URLs directly; stay on `${BASE}/v1/chat/completions`

CORRECT:
```json
{
  "model": "deepinfra/google/gemma-4-26B-A4B-it",
  "messages": [{"role": "user", "content": "..."}]
}
```

PROHIBITED:
```text
gemini_free/gemma-4-26b-a4b-it
cf_local/@cf/google/gemma-4-26b-a4b-it as the unnamed Gemma default
gemini_paid/gemma-4-26b-a4b-it as the unnamed Gemma default
```

## Pack steps that still apply

1. Discover `BASE` (`POLYPUS_URL` / `POLYPUS_BASE_URL` before loopback).
2. Probe `GET ${BASE}/health`.
3. Include the artifact in the prompt.
4. Synthesize for the human; do not treat the consult as an implement order.

Do not send CF `enable_thinking`. Named `gemini_paid` calls may return `reasoning_details`.
