---

translationKey: "2026-05-06-echo-village"
date: '2026-05-06T01:00:00+11:00'
title: "🏕️ They rebuilt your village to keep you circling."
type: claims
description: |
  Algorithms rebuild the ancient village in your pocket to keep you circling. They use **identity**, **cohesion**, and **topic alignment** to trap you in a digital campfire that rewards staying in sync over getting wiser.
grounding: |
  **Group sustainability** is measurable via **social identity** (shared region, role, or behavior class) and **social cohesion** (graph density and average shortest path) to predict which Twitter groups stay aligned across real-world events. The paper tests two competing theories: groups form through shared identity categories or through dense mutual ties. It finds both matter. **Topic divergence** (KL distance from group topic averages) tracks how discussion stays aligned over time. Sustainability here means "discussion stays aligned and the group persists," not "beliefs become more accurate." The metrics omit truth, breadth, or cross-group learning. Source: [Social Identity and Cohesion in Online Communities](https://arxiv.org/pdf/1212.0141.pdf) (PDF).
draft: false

categories: ["Mind-Infrastructure"]

tags: ["OptimisedForStaying", "SynchronyIsNotWisdom", "StickyLoops", "MetricsShapeMinds"]

featuredImage: "campfire.jpg"
featuredImagePreview: "campfire.jpg"

images:
  - campfire.jpg

resources:
  - src: campfire.jpg
    name: featured-image
related:
  - "/social-protocols/2026-04-01-memes/"
  - "/cognitive-memetics/cows/2026-03-12-cow-w03/"
  - "/cognitive-memetics/cows/2026-11-04-cow-w37/"

---

### How algorithms score your village

Humans evolved for small villages and night-time campfires where meaning emerged from the steady rhythm of the same people, paths, and stories. A Twitter study built a mathematical model of exactly that pattern in digital groups.

They score groups on four dimensions:

- **Identity**: Do members share a region, a role, or a **behavior class** (a specific way of acting online)?
- **Cohesion**: How tightly is the group wired? They measure **graph density** (how many possible connections actually exist) and **average shortest path** (how quickly news spreads from any member to any other).
- **Topic divergence**: Do they stick to the group's script? It measures how far an individual's daily subjects stray from the group's collective focus.
- **Membership stability**: Does the group stay together, or is there a high turnover of people leaving and joining?

Groups scoring low divergence and high stability are considered "sustainable." For the study, this just means the group persists over time by repeating the same topics, not that their beliefs evolve.

### Turning the village into a knob

The metrics of the campfire are the blueprint for the loop.

1. **The Logic (Input)**: The algorithm relies on the premise that people join groups reflecting who they are (**social identity theory**) and stay where they have many strong ties (**social cohesion**).
2. **The Data (Input)**: That premise is translated into profile labels for identity and network statistics for ties.
3. **The Steering Loop (extrapolation)**: The paper measures and predicts which groups are sustainable; it does not propose feed algorithms. But if a platform used these signals as objectives, it could monitor how far a user strays from the group topic average, treat rising divergence as a stability risk, and **re-weight the feed to prioritize on-script content**. This would suppress individual curiosity to protect the group's rhythm. The system would have traded individual interest for group stability.

### Stability is not wisdom

The metric measures the **strength of the loop**, but not the **quality of the conversation around the fire**.

A philosophy circle and a cult score identically if both stay cohesive and on-topic. The math is blind to growth:

- It ignores whether beliefs are becoming more accurate.
- It ignores whether the group is reaching outside its own frame.
- It ignores whether members are changing their minds.

This is the wedge: "Sustainable" means staying in sync (aligned topics, shared rhythm). It does not mean getting wiser.

### What we really want

No platform optimizes for **getting wiser**. Measuring whether you are seeing the whole picture, connecting with different groups, or actually finding the truth would require a different set of tools entirely.

Those metrics do not appear in any major dashboard. The easier question ("is this group stable?") is the one that gets answered. It works, it makes money, and for a platform, there is no reason to fix what isn't broken.

### What he said

> The real problem of humanity is the following: We have Paleolithic emotions, medieval institutions, and godlike technology.
>
> (Edward O. Wilson)

---
