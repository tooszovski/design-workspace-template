---
name: anti-patterns
layer: workflow
purpose: Recurring process and design mistakes that repeat from task to task
applies_to:
  task_keywords: ["anti-pattern", "mistake", "pitfall", "how not to"]
  loaded_for_modes: ["quick", "standard", "full"]
owner: design-lead
---

# Anti-patterns

Every entry is a mistake that once cost rework. The list grows from the "What the specs should fix" section of each task's `agent-log.md`.

## Process

| Anti-pattern | Why it hurts | The right way |
|---|---|---|
| **Polishing before states** | `empty` and `error` never appear — the time goes into shadows | The states contract 4a→4b→4c (`domain/states.spec.md`) |
| **Questions one at a time** | the task stretches across a week of waiting | One clarify batch (`workflows/clarify.spec.md`) |
| **Answers left in chat** | in a week they are gone | Everything into `spec.md` |
| **Quiet scope creep** | the estimate stops being true and nobody knows | `— DRIFT:` in the worklog plus a mode recount |
| **Delivering "with caveats"** | nobody reads the caveats, the defects ship | A failed gate means not delivered (`workflows/handoff-quality.spec.md`) |
| **Verbal handoff** | the engineer builds from memory | `handoff.md` is self-sufficient (D-12) |
| **Designing in a vacuum** | the solution does not fit existing screens | Step 2, Context, is mandatory |
| **Editing the library in passing** | it breaks other people's screens without warning | DDR plus version plus consumer list (D-11) |

## Design

| Anti-pattern | Why it hurts | The right way |
|---|---|---|
| **Detach instead of a property** | the instance stops receiving DS updates | Add a property or compose (`domain/components.spec.md`) |
| **Perfect data** | the screen falls apart on real data | Edge cases in the design (D-09) |
| **One breakpoint** | the engineer will invent the adaptivity | Both ends of the range are mandatory (D-08) |
| **Placeholder instead of a label** | the label vanishes on input and the field loses meaning | A visible label (`domain/accessibility.spec.md`) |
| **Color as the only carrier of meaning** | invisible to color-blind users and in grayscale | An icon or text alongside |
| **Spinner instead of a skeleton** | the layout jumps while loading | A skeleton shaped like the content |
| **Hardcoding "just for a minute"** | it stays forever and reaches the code | A token, or a `🚧` marker (D-03) |
| **`Frame 427`** | cannot be found, understood, or handed over | Naming per contract (D-07) |
| **A component for every occasion** | sixty variants and nobody knows which to pick | Composition over configuration |
| **"As in the design" in a spec** | that is a pointer, not a specification | Values and rules in prose |

## Working with the agent

| Anti-pattern | Why it hurts | The right way |
|---|---|---|
| **Exporting a whole file over MCP** | context overflows, the answer is useless | Request one frame by node-id |
| **Guessing instead of access** | the agent describes a design that does not exist | No access means `FAIL: figma access` |
| **Retelling the work in the reply** | duplicates the checkpoint, inflates context | Lean return (`workflows/team-dispatch.spec.md`) |
| **Reviewers in sequence** | three times slower with no gain | One message, several `Agent` calls |
| **Editing `core/` specs in passing** | silently changes the rules for every task | A separate task and a separate commit |

## How to extend this list

An anti-pattern goes here once the same mistake has happened **twice**. A single occurrence is an occurrence, not a pattern.

## Cross-refs

- workflows/agent-log.spec.md — the source of new entries
- workflows/critique.spec.md — what review catches
