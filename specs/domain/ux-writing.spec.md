---
name: ux-writing
layer: domain
purpose: Interface copy — tone, structure, buttons, errors, empty states, glossary
applies_to:
  task_keywords: ["copy", "microcopy", "wording", "error message", "label", "tone of voice", "terminology", "error messages", "labels"]
  triggers: ["interface text appears or changes in the design"]
owner: reviewer-ux-copy
---

# UX Writing

Text is part of the interface, not a caption for it. It is designed alongside the layout, never afterwards.

## Principles

1. **Usefulness first, politeness second.** "Order cancelled" beats "We regret to inform you that…".
2. **The button verb names the outcome.** `Pay`, `Submit request`, `Delete`. Not `OK`, not `Next` where the outcome is known.
3. **Speak from the user's side, not the system's.** "Your order" → "Order". The system does not narrate itself.
4. **No apologies for normal behavior.** An empty list is not an occasion for "Unfortunately".
5. **One term, one entity** (D-14). The glossary below is binding.

## Tone

Tone is defined at init and recorded here. The base frame:

| Situation | Tone |
|---|---|
| Ordinary action | neutral, short |
| User error | calm, not accusatory: "Check the date format", not "You entered it wrong" |
| System error | admit it and offer a way out: "Couldn't load. Retry" |
| Irreversible action | direct: "Delete permanently? This can't be undone" |
| Success | short, with the next step |

## Format by element

| Element | Rule |
|---|---|
| Screen title | noun or short phrase, no period |
| Button | 1–3 words, a verb, no period, Sentence case |
| Field label | noun, no colon |
| Field hint | how to fill it in, shown **before** any error |
| Error text | what is wrong plus what to do, one sentence |
| Empty state | what will appear here plus an action |
| Tooltip | 2 lines or fewer, does not repeat visible text |
| Confirmation dialog | question in the title, consequence in the body, verb in the button |

## Forbidden phrasing

| Forbidden | Why | Instead |
|---|---|---|
| "Something went wrong" | conveys nothing | "Couldn't save. Check your connection" |
| "Error 500" in the primary text | the user can do nothing with it | human text plus the code in fine print |
| "Nothing found" with no way out | a dead end | "Nothing found. Clear filters" |
| "Are you sure?" | states no consequence | "Delete draft? This can't be undone" |
| "Please wait…" | needless politeness | a skeleton with no text |
| "Click here" | device-bound | "Open settings" |
| CAPS LOCK in sentences | unreadable and reads as shouting | Sentence case |

## Glossary

Maintained here and binding for the design, the spec, and the code (D-14). Seeded at init and grown as the project runs.

| Term | Meaning | Do not use |
|---|---|---|
| — | — | — |

Example row: `Order | a completed purchase after payment | Transaction, Purchase, Deal`.

## Numbers, dates, units

- Date and time format is uniform across the product and recorded in the glossary.
- Relative time ("5 minutes ago") only where freshness matters; absolute time elsewhere.
- Numbers carry thousands separators in the local convention; currency shows an explicit symbol or code.
- Pluralization covers every form of `<DEV_LANGUAGE>`; a string reading "1 items" is a defect.

## Findings

| Code | Severity | When |
|---|---|---|
| `COPY` | MINOR | period in a button; a stray "please" |
| `COPY` | IMPORTANT | term outside the glossary; a button verb that does not name the outcome; a hint that appears only after the error |
| `COPY` | CRITICAL | forbidden phrasing in error text; an irreversible action with no stated consequence; a required state with no copy at all |

## Cross-refs

- domain/states.spec.md — state copy
- domain/typography.spec.md — text growth under localization
- domain/accessibility.spec.md — labels and alternatives
