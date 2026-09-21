# Voice catalog

Host-owned narrator contracts for essay polish. Composition stays on the shared commute voice in `data/essay-content-forms.yaml`. Polish applies one file from this directory when the operator names it.

The portable checker lives in strop (`pkg/evaluation/voice`). These files are the phrase banks and cadence rules. Strop does not store section names or persona labels.

## Section routing

| Section | Voice file |
| --- | --- |
| `human-condition` | `patient-narrator.md` |
| `x-minds` | `patient-narrator.md` |
| `social-protocols` | `clint-eastwood.md` (or `lean-realist.md`) |
| `mind-infrastructure` | `cognitive-pragmatist.md` |

Technical posts that should stay technical do not take a narrator file. Leave polish focus empty.

## Two contracts in each file

Generator contract: how the polish model should write (cadence, verbs, what to refuse).

Evaluator contract: what a deterministic audit and the `voice_fidelity` role can fail closed (banned phrases, staccato run, required verbs). Those checks are the YAML front matter. The Markdown body is the brief a human or a polish focus string can paste.

## Front matter

```yaml
---
id: patient-narrator
label: Patient Narrator
sections: ["human-condition", "x-minds"]
banned_patterns:
  - "Look,"
max_staccato_run: 2
---
```

| Field | Required | Meaning |
| --- | --- | --- |
| `id` | yes | File id used by `make audit-voice VOICE=` and polish focus |
| `label` | yes | Human name |
| `sections` | yes | Hugo section folder names this voice is for |
| `banned_patterns` | no | Case-insensitive substrings. A hit fails the audit |
| `required_verb_classes` | no | Whole words. Optional list; when present, a body paragraph with none of them fails. Standard catalog profiles omit this so they generalize across different topics |
| `max_staccato_run` | no | Longest allowed run of similar short sentences. Default 2. A longer run fails |

`cmd/audit-essay-voice` reads this front matter and the post body. It skips the README.
