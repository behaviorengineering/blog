# Perplexity threads: public share before Hugo ship

Explore further `perplexity_thread` rows MUST open for **cold readers** (logged out or incognito), not only inside your account.

## Critical: default is private

New searches (including MCP `perplexity_research` outside the blog project) start as **Only people with access can view**. Explore batch threads MUST be created inside the project first; see [PERPLEXITY-PROJECT.md](PERPLEXITY-PROJECT.md).

## Do not test inside Perplexity “incognito”

If the thread shows **Exit incognito**, you are in Perplexity’s private session mode, not a cold reader test.

1. Click **Exit incognito** (or open the thread in a normal logged-in tab).
2. **Share** → **Anyone with the link can view** → **Copy link**.
3. Verify in **Safari/Chrome private window** where you are **not** logged into Perplexity.

Pass: full answer visible without signing in. Fail: sign-in prompt or empty thread.

## Operator steps (each completed thread)

1. Open the thread in Perplexity (browser or app).
2. Use **Share** (or thread menu → share).
3. Under **General access**, select **Anyone with the link can view** (globe icon, not “Only people with access” or project-only).
4. Click **Copy link** and confirm the URL is `https://www.perplexity.ai/search/<uuid>`.
5. Paste that URL into `candidates.json` / Hugo YAML only if it matches the thread you shared.

Perplexity Computer project: run this on every thread before you paste the URL into the blog packet.

## Verify (required before `explore-apply`)

- Open the URL in a **private/incognito** window (or another browser where you are not logged into Perplexity).
- Pass: the research answer and citations load.
- Fail: login wall, blank thread, or “no access” → re-share as public, then update YAML if the URL changed.

Optional repo check (bot blocking may false-fail):

```bash
make verify-explore-links POST=x-minds/2026-09-26-the-octopus-advantage
```

Treat a failed automated check as a reminder to run the incognito test, not as proof the link is private.
