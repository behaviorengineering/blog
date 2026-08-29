---
name: site-curiosity-title
description: >-
  Drafts or refines Hugo post titles with legitimate curiosity tension (real open
  loops the body pays off), not fake-urgency clickbait. Uses prediction-error
  questions, concrete nouns, and cold-read tests. Example gold standard: "Why does
  every group organize into a pyramid?" Triggers: curiosity title, clickbait title
  (means real gap + payoff, not bait-and-switch), title ideas, retitling, click
  tension; pair with revise-hooks to audit.
---

# Curiosity title (legitimate tension, not bait)

## Purpose

Find **`title`** lines that make a stranger think *I don't know why that happens, and I want the answer* — then **deliver** that answer in the Claim, lead, or body.

**If the user says "clickbait":** they mean **this** skill (real open loop + payoff), **not** fake urgency, mystery boxes, or bait-and-switch. **Not** "You won't believe…" patterns.

**Legitimate curiosity:** a **specific gap** the post actually closes.

**Audit existing titles:** **`.cursor/skills/site-revise-hooks/SKILL.md`**.  
**This skill:** **generate and compare** candidates before you commit.

## When to use

| Situation | Skill |
|-----------|--------|
| New post needs a title | **This skill** → then **revise-hooks** cold-read |
| Retitle after the essay is written | **This skill** (read body + Claim first) |
| Title already good; check list row | **revise-hooks** only |
| Full publish pass | **revise-post** (hooks phase uses **revise-hooks**) |

## Gold-standard example (this repo)

**Post:** `content/human-condition/2026-05-28-why-humans-keep-building-pyramids/`

**Title:** `🏢🔺 Why does every group organize into a pyramid?`

**Why it works:**

| Test | Pass? |
|------|-------|
| **Prediction error** | Reader assumes groups can stay flat; title says they become a pyramid anyway. |
| **Concrete image** | *pyramid* (not "hierarchy" alone). |
| **Universal scope** | *every group* (family, company, forum) without listing them. |
| **Plain verb** | *organize into* (readable cold; not "map complexity flat"). |
| **Question opens a loop** | *Why* — gap the essay closes. |
| **Payoff exists** | Claim + body explain layers, rank, attractor, counter-design. |
| **Not a mystery box** | You know the topic (groups, pyramid shape); you don't know the **why**. |

**Pairing:** Question in **`title`**; **`description` (Claim)** stays **assertive** (answers the why). Do not put the only question in the Claim.

## Workflow (MUST follow)

### 1. Read the post first

- **`type`** skill (`claims-content`, `video-content`, `cognitive-memetics-content`, etc.).
- **`description`** / Claim / lead: what answer does the page **owe** the reader?
- Body **spine** (one sentence): what mechanism or scene is the real payoff?
- Section **`##`** hooks: do not copy verbatim; title can rhyme with them.

### 2. Name the curiosity gap (one line)

Write internally:

```text
Reader believes: …
Article shows: …
Gap: …
```

**Fail** if you cannot state the gap in plain English. No gap → no curiosity title; use a **direct thesis title** instead (see **revise-hooks**).

### 3. Draft 3–5 title candidates

Use **different patterns** (not five rewrites of the same joke):

| Pattern | Template | Use when |
|---------|----------|----------|
| **A. Gap question** | Why does [concrete subject] [surprising verb] [concrete image]? | Universal pattern, strong cold-read (pyramids model). |
| **B. Paradox / contrast** | [X looks flat] until [Y] | Two beats; good for claims. |
| **C. Direct thesis** | [Actor] [verb] [mechanism] | When question would be vague. |
| **D. Stakes** | What [cost] when [mechanism] | Only if body proves the cost. |
| **E. Scene hook** | [Concrete scene] — [turn] | When one image carries the post. |

**MUST:**

- One **concrete noun** from the piece (pyramid, org chart, mod, feed, etc.).
- **Active verb** where possible (*organize into*, *redraw*, *track*, not *engagement dynamics*).
- **US English** in `content/` default pages.
- **Truthful:** title claim must be defended in the first screen (Claim or lead).

**MUST NOT:**

- "You won't believe…", "The truth about…", "Everything you know about…"
- Questions with **no** imaginable answer in the piece ("What if reality is a simulation?" unless the post is about that).
- Jargon the card cannot decode (*predictive processing*, *heterarchy*) without a plain noun.
- **Mystery box:** withhold **what the post is about** (bad: "This changes how we think about groups").
- Duplicate the **Claim** sentence as the title.

### 4. Emoji (section rules)

- **`human-condition`**, **`social-protocols`**, **`mind-infrastructure`:** MAY use **1–2** leading emoji if they signal the hook.
- **`cognitive-memetics`:** **no** leading emoji in **`title`** (use **`heading_code`** when needed).

### 5. Cold-read each candidate

For each title, alone, ask:

1. What is this about? (subject + image)
2. What don't I know yet? (the gap)
3. Would I feel **tricked** after opening? (if yes → reject)

**Pass** if a stranger can answer 1 and 2 and 3 is **no**.

### 6. Pick one and check Claim pairing

| Field | Job |
|-------|-----|
| **`title`** | Opens the gap (often a **question**). |
| **`description` (Claim)** | **Answers** with mechanism + stakes (assertive prose). |

**Reject** a title that forces the Claim to repeat the question without answering.

**Claim fog check:** After picking a title, read the **Claim** per **`.cursor/skills/site-revise-hooks/SKILL.md`** → **Claim fog**. Title can be perfect while a Claim sentence still fails cold-read; fix the Claim before publish.

## Required output format

```markdown
## Curiosity titles: [bundle or path]

**Gap:** Reader believes … / Article shows … / Gap: …

| # | Pattern | Title | Cold-read |
|---|---------|-------|-----------|
| 1 | A Gap question | … | Pass / Fail + why |
| 2 | … | … | … |

**Recommended:** #N — [one line why]

**Claim pairing:** [does current Claim answer the title? yes/no + one fix if no]

Apply recommended title to front matter? (y / pick # / cancel)
```

**Default:** analysis only; change **`title`** only after user confirms (stable URL: do not rename bundle folder unless user asks).

## Legitimate vs bait (quick)

| Legitimate | Bait |
|------------|------|
| Specific *why* you can answer in the post | Vague *what* you'll "reveal" |
| Concrete noun (pyramid, VP, mod) | Abstract label (systems, paradigms) |
| Reader learns something true | Reader feels manipulated |
| Claim delivers on the title | Claim is unrelated hype |

## Related skills

- **`.cursor/skills/site-revise-hooks/SKILL.md`** — audit, integrity, body headings
- **`.cursor/skills/site-claims-content/SKILL.md`** — Claim must stay assertion
- **`.cursor/skills/site-revise-post/SKILL.md`** — full lot after title is set (hooks phase)
- **`.cursor/skills/site-curiosity-title/examples.md`** — more before/after pairs (optional read)
