---
name: site-reptilocracy-gemma
description: >-
  Drafts Reptilocracy episode description, tldr, and the human-reality scene
  (fluff) via local Gemma 4 with thinking mode, satire-first briefs, and a
  psychological-fitness knife. Use when creating or rewriting Reptilocracy
  copy, a Reptilocracy scene, Gemma Reptilocracy text, good-day/bad-day
  emergency-powers satire, or when the user asks Gemma to write Reptilocracy
  fields (not LinkedIn; not full bundle layout; not the theme-catalog pitch).
---

# Reptilocracy episode copy (Gemma 4 + thinking)

## Goal

Get **local Gemma 4** to draft **`description`**, **`tldr`**, and **`fluff`** for posts under **`content/cognitive-memetics/reptilocracy/`**, using the brief that works in practice: **satire first**, then the knife that **psychological fitness** is almost never on the leadership agenda.

This skill owns **Gemma prompting and pick flow** only. Bundle layout, tags, dates, images, LinkedIn, and Spanish naturalness audits stay with sibling skills (see **Related**).

## When to use

| Use this skill | Use another skill |
|----------------|-------------------|
| New Reptilocracy episode copy via Gemma | **`site-cognitive-memetics-content`** for folder, front matter shell, categories, tags, images |
| Rewrite / punch up Reptilocracy `description` / `tldr` / `fluff` with Gemma | **`site-linkedin-post`** for `linkedin.txt` |
| User says Gemma, thinking mode, satire, psych fitness for Reptilocracy | **`site-revise-spanish`** after ES copy exists |
| | **`site-reptilocracy-themes`** for Dark Triad theme lists and joke pitches (before this skill) |
| | Generic **Gemma teaser** in cognitive-memetics for Cube-Cows / Raymond / Pawtropolis / T-Shirt Art (not this hub) |

## Defaults

| Setting | Value |
|---------|--------|
| Gateway | `LOCAL_LLM_BASE_URL` or `${POLYPUS_URL}/v1` (`.envrc`) |
| Model | `LOCAL_LLM_MODEL` or `deepinfra/google/gemma-4-26B-A4B-it` |
| Thinking | Do not send CF `enable_thinking`; named `gemini_paid` may return `reasoning_details` |
| Pack | **`packs/episode_copy.md`** |
| Script | **`scripts/draft_episode_copy.py`** |

## What “done” means for Gemma

**CONSTRAINT:** For new or rewritten Reptilocracy episode fields, MUST obtain **`description`**, **`tldr`**, and **`fluff`** from Gemma under this skill’s brief. MUST NOT ship agent-invented stamp poetry or policy-memo prose and claim Gemma wrote it.

- Enforcement: candidates file or chat shows Gemma output; pick recorded before apply
- Violation: STOP, re-run script or Gemma call; do not apply agent-only fields as final

CORRECT:
```text
Run draft_episode_copy.py → surface 3 descriptions + tldr + fluff → user picks → apply
```

PROHIBITED:
```text
Agent writes clinical fluff about the stamp, pastes a Gemma teaser only for description
```

## Brief rules (what to send Gemma)

**CONSTRAINT:** System and user briefs MUST be **satire first** (dark café humor, Latin American tragicomic shrug: sad and funny). MUST land the knife that institutions gossip about **mood / weather / good day vs bad day** and almost never put **psychological fitness** on the table for leaders (honesty, accountability, courage, reality-contact, impulse control, empathy under power). Emergency / continuity theater covers both moods because fitness was never a gate.

- Enforcement: scan the prompt for satire + psych-fitness knife before calling Gemma
- Violation: STOP, rewrite the brief; do not call with a white-paper thesis stack alone

**CONSTRAINT:** MUST NOT brief Gemma as a policy memo, LinkedIn think-piece, MBA fog deck, or activist petition sermon. Petition CTA belongs in LinkedIn / footer i18n, not in episode `description` / `tldr` / `fluff`.

### Joke clarity gate

**CONSTRAINT:** Preserve the visible joke before expanding the institutional
analysis. Reptilocracy copy should make the absurdity and the clerk's response
clear before naming the clinical mechanism.

- `DESCRIPTION_1` / `DESCRIPTION_2` / `DESCRIPTION_3` MUST each carry one
  visible absurdity, one concrete response, and one turn.
- Prefer a specific object, action, or person over an abstract label: a font
  debate, a calendar check, a stamp, or a psychiatrist someone forgot to call.
- Keep `tldr` to two or three short sentences. Name the mechanism once.
- `description` is the cartoon. `fluff` is the human occasion that cartoon is
  about, said once, out loud, as a joke. See **Scene (`fluff`)**.
- A concrete clinical punchline MUST survive compression. Do not replace it
  with a vague phrase such as "sanity check."
- When the brief marks a **HUMAN-APPROVED JOKE SPINE** or a **KEEP** line,
  preserve that concrete beat in every description candidate. A named person,
  object, or action such as a psychiatrist someone forgot to call MUST NOT
  become an abstract substitute.
- When Dark Triad traits appear, describe the behavior shown. Do not diagnose a
  real person or generalize a clinical disorder to an entire population.

CORRECT:
```text
Joke spine: same leader, smile and shout; clerk stamps emergency powers on both.
People track temperament like humidity. Fitness audit never enters the briefing.
```

PROHIBITED:
```text
Write clinical institutional analysis of continuity vs early structural change
with board-deck vocabulary and no satire beat.
```

**CONSTRAINT:** When the art shows **one** character on a good day and a bad day, MUST tell Gemma it is the **same** person twice. MUST NOT allow two-lizard readings.

**CONSTRAINT:** `DESCRIPTION_1` / `DESCRIPTION_2` / `DESCRIPTION_3` MUST be three **complete alternative card teasers** (each 1–2 sentences, standalone). MUST NOT split smile / shout / stamp across three panel captions.

### Scene (`fluff`)

**CONSTRAINT:** `fluff` MUST be one human situation a person would recognize, said facetiously, in one or two spoken sentences. The cartoon stays in `description`. `fluff` says what that cartoon is like when people do it.

- Enforcement: before apply, run the scene gate below on the Gemma `fluff`
- Violation: STOP, do not apply that `fluff`; re-brief once; if the second draft still fails the gate, write the one spoken joke yourself and label it operator, not Gemma

CORRECT (`2026-11-22-the-generous-leaf`, rhythm, do not copy the Tuesday into other episodes):
```text
He keeps the week and hands you Tuesday, and you are meant to thank him for it. Say anything about the other days and you have ruined the occasion.
```

PROHIBITED:
```text
The stores are empty. The clerk asks how much gold the statue needs. The ants queue to file the thank-you.
You have met him. He eats the year and gives back a Tuesday, and the Tuesday gets the statue. The speech is very moved by the Tuesday. Nobody is rude enough to mention the other six days, or to ask whether a man who is still chewing should be handed next year. So the appetite gets the holiday, and the pile stays out of the remarks.
```

The first prohibited block is a stack of short sentences that retell the drawing. The second is the right idea broken into a mess: statue, speech, six days, chewing, next year, holiday, and pile.

**CONSTRAINT:** Before applying `fluff`, MUST complete this gate. Only `APPLY` may be written into `index.md`.

```text
Candidate: [fluff text]
Retells description or tldr in different words: YES: [quote] / NO
Stack of short sentences of similar length: YES: [quote] / NO
More than one joke or picture: YES: [quote the extras] / NO
A person would say it out loud, and it is facetious: YES: [quote] / NO
Decision: APPLY | REPROMPT
```

- Enforcement: the gate is in the chat or the candidates file before the `fluff` edit
- Violation: STOP, leave the previous `fluff` in place, re-brief or write the one spoken joke

REPROMPT brief MUST say: one human occasion, one or two spoken sentences, facetious, do not narrate the cartoon, do not add a second picture. One reprompt. A second failure is an operator rewrite, labeled as such.

## Procedure

1. Resolve episode **`title`** (working or final) and a **mechanism brief** (gag + institutional knife; not a full prop inventory). When the pitch came from **`site-reptilocracy-themes`**, MUST include **power species**, **role**, **public species** (usually ants), and **species rationale** from the pitch gate. MUST NOT use cows or Cube-Cows fauna in the brief. Prefer art caption + one sentence of what the stamp / system move means.
2. From repo root, run (do not hand-roll the API unless the script fails):

```bash
python3 .cursor/skills/site-reptilocracy-gemma/scripts/draft_episode_copy.py \
  --title "Good Days, Bad Days" \
  --brief "Same lizard leader: GOOD DAY smile and BAD DAY shout in one dossier. Clerk stamps EMERGENCY POWERS APPROVED across both. Mood gossip replaces psychological fitness; stamp covers both."
```

Optional: `--out content/cognitive-memetics/reptilocracy/<slug>/gemma-candidates.txt`

3. Surface the **three numbered descriptions** plus proposed **`tldr`** and **`fluff`** from stdout (and the candidates file if written).
4. Wait for a numbered **description** pick (and confirmation that TLDR/FLUFF are accepted, or a rewrite pass).
5. Apply the pick to English **`index.md`** with light mechanical cleanup only (em dash, YAML safety, restrained `**bold**` per **`.cursor/skills/site-revise-emphasis/SKILL.md`**). MUST NOT flatten the joke into a caption inventory.
6. If **`index.es.md`** exists or is being created: invoke Gemma again (thinking on) to adapt the chosen EN **`description`** into three Spanish candidates; pick or apply the best mirror of the EN joke spine; adapt **`tldr`** / **`fluff`** into native Spanish (not calque). Then run **`.cursor/skills/site-revise-spanish/SKILL.md`** when the user asks.
7. Bundle shell (date, `heading_code`, tags, image, calendar): **`.cursor/skills/site-cognitive-memetics-content/SKILL.md`**. LinkedIn: **`.cursor/skills/site-linkedin-post/SKILL.md`**.

### Thinking-mode output hygiene

**CONSTRAINT:** Final Gemma **content** MUST contain only the labeled fields (`DESCRIPTION_1`…`FLUFF`). If thinking spills into `content` and truncates fields, MUST re-run with the pack’s final-answer-only instruction (script already sets this). MUST NOT paste raw reasoning into Hugo front matter.

- Enforcement: parse labels before apply
- Violation: re-run script; discard truncated content

### Gateway down

**CONSTRAINT:** If the gateway is unreachable, MUST say so. MUST NOT invent teasers and claim Gemma wrote them. MAY leave a clearly labeled stub only if the user accepts shipping later.

## Gold tone (energy, not to copy)

- `content/cognitive-memetics/reptilocracy/2026-08-02-photo-op-readiness/` (dry satire punch)
- `content/cognitive-memetics/reptilocracy/2026-09-13-the-alarm-worked/` (short scene knife)
- `content/cognitive-memetics/reptilocracy/2026-09-20-good-days-bad-days/` (mood weather vs psychological fitness)

Sister psych-fitness close (tone only; do not paste petition into episode fields): episodes that end without soft MBA fog, e.g. `2026-08-16-insert-vote-receive-same` fluff beat on fitness standards.

## Related

- Dark Triad theme catalog and joke pitches: **`.cursor/skills/site-reptilocracy-themes/SKILL.md`**
- Bundle / hub rules: **`.cursor/skills/site-cognitive-memetics-content/SKILL.md`**
- LinkedIn: **`.cursor/skills/site-linkedin-post/SKILL.md`**
- Spanish audit: **`.cursor/skills/site-revise-spanish/SKILL.md`**
- Shared gateway helpers: **`.cursor/skills/site_local_eval_common/common.py`**
