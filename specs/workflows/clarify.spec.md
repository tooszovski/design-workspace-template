---
name: clarify
layer: workflow
purpose: Format for clarifying questions, the drift guard, what must not be asked
applies_to:
  task_keywords: ["clarify", "question", "unclear", "incomplete requirements"]
  loaded_for_modes: ["standard", "full"]
owner: design-lead
---

# Clarify

The goal is to close every uncertainty in **one batch** before work starts. Asking one at a time stretches the task and forces rework.

## What to ask

Only what **changes the design** and is **absent from the sources of truth** (`core/project.spec.md §3`).

| Ask | Do not ask |
|---|---|
| Product rules: what happens when payment is cancelled | What the designer decides: button color, spacing |
| Priority: what matters more when the screen has a conflict | Permission to follow the DS as usual |
| Data: which fields are required, which may be missing | What the requirements already state |
| Limits: maximum item count, behavior at 0 and at 1000 | What follows from existing screens |
| Edge cases: no permissions, offline | Permission to begin |

**A question the designer could answer themselves is not a question — it is handing the decision away.** Those decisions get made and recorded in a DDR.

## Format

```markdown
## Clarify · <PROJECT_PREFIX>-NNN

### Q1. <The question in one sentence>
**Why it matters:** what in the design depends on the answer.
**Options:**
- A — <option> → consequence for the design
- B — <option> → consequence for the design
**If no answer arrives:** I will take A, because <reason>.
```

The "if no answer arrives" line is mandatory. It turns a blocking question into a non-blocking one: work continues on the default and the answer corrects it.

Seven questions maximum per batch. More than that means the requirements are not ready: record that separately and move the task to `<TRACKER_BLOCKED_STATUS>`.

## The drift guard

An answer can quietly change the task. After answers arrive, check:

| Check | Action when it fires |
|---|---|
| The answer added a new screen or flow | recompute the mode (`workflows/task-modes.spec.md`) |
| The answer contradicts the requirements | Tier 2 stop: show the contradiction to a human |
| The answer contradicts the existing product | Tier 2 stop: this is a product change, not a task change |
| The answer requires a new DS component | mode becomes Full |

Record it in the worklog: `— DRIFT: answer to Q2 expands scope, mode Standard→Full`.

## Where it is written down

Questions and answers go into `<PER_TASK_SPEC_LOCATION>/<task-id>/spec.md`, in the Clarify section. Answers given in chat and never transferred into `spec.md` count as nonexistent: nobody will find them in a week.

## Cross-refs

- per-task/DESIGN-TASK-TEMPLATE.spec.md — the Clarify section
- workflows/decision-gates.spec.md — Tier 2
- per-task/DDR-TEMPLATE.md — recording decisions made independently
