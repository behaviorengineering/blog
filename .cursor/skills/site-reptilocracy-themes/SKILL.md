---
name: site-reptilocracy-themes
description: >-
  Catalogs Reptilocracy Dark Triad joke themes and pitches single-panel gags
  that expose narcissism, Machiavellianism, and psychopathy as leadership
  traits the public (ants) cannot see. Uses species casting from
  characters-and-species.md (frogs, lizards, komodos, ants; no cows). Use when
  the user wants Reptilocracy joke ideas, theme lists, Dark Triad satire,
  herd-blindness gags, species casting, or W-week episode premises (not Gemma
  description/tldr/fluff; not LinkedIn; not bundle layout).
---

# Reptilocracy Dark Triad themes

## Goal

Pitch **single-panel satire** from a fixed catalog of **Dark Triad** pathologies (narcissism, Machiavellianism, psychopathy) so the joke makes the trait **visible**.

Author lock (verbatim):

> the main issue is that most political leaders are in the dark triad spectrum, and therefore share all the behaviour pathological traits those conditions expose. The idea is to create satire to bring that problem to the light because the rest of people cant see what is in front of their nose

In panels, **ants** are the public (voters, workers, consequences). **MUST NOT** use **cows** or Cube-Cows office fauna in Reptilocracy pitches.

This skill owns **theme catalog + species casting + joke pitches** only. Episode `description` / `tldr` / `fluff` stay with **`.cursor/skills/site-reptilocracy-gemma/SKILL.md`**. Bundle shell stays with **`.cursor/skills/site-cognitive-memetics-content/SKILL.md`**.

## References (MUST load both before pitching)

| File | Role |
|------|------|
| **`reference.md`** | Dark Triad theme ids `T1`…`T10`, pathology + herd misread, shipped overlap table |
| **`characters-and-species.md`** | Species symbolism, character roles, power patterns, visual behavior |

## When to load

| Use this skill | Use another skill |
|----------------|-------------------|
| Theme list, joke ideas, Dark Triad catalog, species casting, "new jokes" for Reptilocracy | **`site-reptilocracy-gemma`** after a numbered pitch pick, for `description` / `tldr` / `fluff` |
| Herd-blindness gags (ants or frogs misread a predator) | **`site-cognitive-memetics-content`** for folder, date, tags, image, calendar |
| | **`site-linkedin-post`** for `linkedin.txt` |

## Joke engine

```text
  [Dark Triad symptom]
           |
           v
  [Power species + role express the pathology]
           |
           v
  [Ants (or frogs) rename it as normal leadership / procedure]
           |
           v
  [Satire: rename is the punch; fitness never enters the room]
```

Key: species choice is part of the argument (see **`characters-and-species.md`**).

**Gold energy (rhythm, not to copy):**

- `content/cognitive-memetics/reptilocracy/2026-10-25-dont-make-eye-contact/` (psychotic break treated as a meeting that might run past 5:00)
- `content/cognitive-memetics/reptilocracy/2026-08-02-photo-op-readiness/` ("Have you done anything awful?" / "Probably.")
- `content/cognitive-memetics/reptilocracy/2026-09-13-the-alarm-worked/` (remove the canary because it worked)

## Core constraints

**CONSTRAINT:** Joke pitches MUST pair one catalog **pathology** (`T#`) with one **herd misread**. MUST land the knife that **psychological fitness** (honesty, accountability, courage, reality-contact, impulse control, empathy under power) is not on the agenda.

- Enforcement: each pitch gate names pathology, herd misread, and fitness knife before the user sees the gag
- Violation: STOP, drop the pitch, rewrite the gate

**CONSTRAINT:** MUST assign **power species** and **character role** from **`characters-and-species.md`**. MUST name **species rationale** (why this creature sharpens the type of power). When the public or consequence appears in the panel, MUST use **ants** (witness, crowd, queue, burden). Frogs are default **presenters / normalizers**, not the public.

- Enforcement: gate slots `Power species`, `Role`, `Public species`, `Species rationale` filled before PITCH
- Violation: STOP, DROP-SPECIES or recast per the guide

CORRECT:
```text
Power species: Komodo. Role: enforcer. Public species: ants in queue below podium.
Species rationale: dominance is legible before the caption is read.
```

PROHIBITED:
```text
Cow clerk worries about Reply-All while a generic lizard leader rants.
```

**CONSTRAINT:** Reptilocracy pitches MUST NOT use **cows**, **Cube-Cows**, or Tales from the Cube Farm office fauna. MUST NOT treat frogs as interchangeable with ants.

- Enforcement: grep pitch text for cow / Cube-Cows / bull / Tales from the Cube Farm
- Violation: STOP, rewrite cast

**CONSTRAINT:** Pitches MUST use **Seinfeld petty-rule** comedy inside the **cave ministry / institutional** frame (commute, Reply-All, split check, room booking, eye contact). Petty rule applies to **frogs or ants**, not generic corporate open-plan copy unless the mechanism is clearly institutional.

- Enforcement: scan each pitch for a named petty social rule plus a visible clinical trait
- Violation: STOP, rewrite or DROP-SERMON

**CONSTRAINT:** MUST NOT draft or apply Reptilocracy **`description`**, **`tldr`**, or **`fluff`** in this skill. MUST hand the picked pitch to **`site-reptilocracy-gemma`**. MUST NOT claim Gemma wrote agent-invented episode fields.

**CONSTRAINT:** MUST read **`reference.md`** and **`characters-and-species.md`** before pitching. MUST NOT invent a theme id outside `T1`…`T10` unless the user asks to extend **`reference.md`**.

## Steps

1. **Load references:** Read **`reference.md`** and **`characters-and-species.md`**. If the user asked only for a theme list, print the 10 themes (id, pathology, herd misread) and wait. Do not pitch yet.
2. **Scan shipped titles:** List `title` from `content/cognitive-memetics/reptilocracy/*/index.md`. Use those quotes in the overlap slot of each pitch gate.
3. **Choose themes:** If the user named a theme or id, use that. Else pick up to four unused catalog ids (no mechanism overlap with shipped episodes).
4. **Pitch gate (forced intermediate state):** For each candidate gag, complete this gate in working memory **before** writing that gag for the user:

```text
Candidate: [working title]
Theme: [T# from reference.md]
Pathology: [one clause]
Power species: [frog | lizard | komodo | crocodile | chameleon | snake]
Role: [presenter | operator | enforcer | witness | crowd | decorative victim]
Public species: [ants | none in frame | flies if scandal/noise only]
Species rationale: [one clause: why this cast makes the pathology faster to read]
Herd misread: [what ants or frogs call it]
Petty rule: [Seinfeld social or etiquette rule in institutional frame]
Visual: [one panel sentence; natural bodies; small accessories OK per guide]
Knife: psychological fitness never on the agenda because [clause]
Already shipped overlap: YES: [quote existing title] / NO
Decision: PITCH | DROP-SERMON | DROP-REPEAT | DROP-SPECIES
If PITCH: Caption: [one deadpan bottom line]
```

Work through every candidate. Only `Decision: PITCH` items go to the user. Maximum four PITCH items per turn.

5. **Surface pitches:** Number them `1`…`n`. Each pitch MUST show cast: power species, role, ants if present, scene, dialogue, caption. Wait for a numbered pick (and optional date / `heading_code`).
6. **Hand off:** On a numbered pick, load **`.cursor/skills/site-reptilocracy-gemma/SKILL.md`** with `--title` and `--brief` built from the gate. The brief MUST include `Pathology`, `Herd misread`, `Visual`, `Knife`, plus `Power species`, `Role`, `Public species`, and `Species rationale`. Then load **`.cursor/skills/site-cognitive-memetics-content/SKILL.md`** only if the user asked to create the bundle.

Example `--brief` fragment:

```text
T4 DARVO. Komodo enforcer, ants witness below. Species rationale: threat visible before text.
Frog presenter files grievance against ant auditor for hostile tone re missing treasury.
Knife: psychological fitness not on calendar; only etiquette.
```

## Pre-completion checklist

- [ ] **Both references loaded:** `reference.md` and `characters-and-species.md` read this turn
      Method: Confirm pitches cite `T#` and named species from the guide
      Pass: Every pitch has theme id + power species + role
      Fail: STOP, read both files, remap
- [ ] **No cows:** pitch text has no cow / Cube-Cows / office-cube fauna
      Method: Case-insensitive scan for cow, bull, cube-cow
      Pass: Zero hits
      Fail: STOP, recast with ants and reptiles per guide
- [ ] **Shipped overlap checked:** existing Reptilocracy titles were listed
      Method: Each gate has `Already shipped overlap: YES: [quote] / NO`
      Pass: No PITCH shares a mechanism with a quoted title
      Fail: STOP, mark DROP-REPEAT
- [ ] **Gates completed before pitches:** each user-facing gag has a filled gate
      Method: Count PITCH items vs gates
      Pass: Equal counts; species slots present
      Fail: STOP, fill missing gates, drop ungated gags
- [ ] **No episode fields:** reply has no final `description` / `tldr` / `fluff`
      Method: Scan the user-facing reply
      Pass: Themes and/or numbered pitches only
      Fail: STOP, cut those fields; point to Gemma skill
- [ ] **Petty-rule comedy:** each PITCH names an institutional petty rule
      Method: Read `Petty rule` slot
      Pass: Concrete rule in cave/ministry frame
      Fail: STOP, DROP-SERMON or rewrite

## Related

- Dark Triad catalog: **`reference.md`**
- Species and roles: **`characters-and-species.md`**
- Gemma episode copy: **`.cursor/skills/site-reptilocracy-gemma/SKILL.md`**
- Bundle / hub: **`.cursor/skills/site-cognitive-memetics-content/SKILL.md`**
