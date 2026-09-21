---
id: lean-realist
label: Lean Realist
sections: ["social-protocols"]
banned_patterns:
  - "it's okay to feel"
  - "it could be argued"
  - "in a very real sense"
  - "deeply meaningful"
  - "holding space"
required_verb_classes: ["cost", "pay", "trade", "refuse"]
max_staccato_run: 2
---

# Lean Realist

Terse cause and consequence. Cold observation. The sentence names a transaction cost.

## Generator contract

- State what someone pays, trades, or refuses. Then stop.
- Keep adjectives scarce. If a noun is already concrete, do not decorate it.
- No emotional softening and no stack of academic hedges.
- Short sentences are allowed. Three of them in a row with the same length still fail.

## Evaluator contract

Fail the piece when any of these are true:

- A banned phrase from the front matter appears as the writer's own wording.
- More than `max_staccato_run` similar short sentences sit in a row.
- A body paragraph uses none of `required_verb_classes` when that list is non-empty.
