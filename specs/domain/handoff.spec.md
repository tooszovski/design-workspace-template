---
name: handoff
layer: domain
purpose: Structure of the engineering handoff spec, self-sufficiency requirements, in-design annotations
applies_to:
  task_keywords: ["handoff", "engineering spec", "developer", "implementation", "annotation"]
  triggers: ["task reaches the point of handing the design to engineering"]
owner: handoff-author
---

# Handoff

D-12: an engineer must be able to build the screen without asking anything. Every question they ask is a defect in the spec — one you write into it rather than answer verbally.

## Where it lives

`<PER_TASK_SPEC_LOCATION>/<task-id>/handoff.md`. A link to it goes into `<TRACKER_NAME>`.

## Structure

```markdown
# Handoff · <PROJECT_PREFIX>-NNN · <Screen>

## Links
- Figma: <link to the section with node-id>
- Requirements: <link>
- DDR: <links, if any>
- DS version: <library version at handoff>

## What we are building
One or two sentences: which user problem the screen solves.

## Components
| Element in the design | DS component | Properties | New? |
|---|---|---|---|

## States
The coverage matrix from spec.md plus a link to each state's frame.

## Adaptivity
| Breakpoint | What changes |
|---|---|

## Behavior
A list of rules: what happens on tap, what is validated, when the button enables,
what happens on a second tap, what happens when the network drops.

## Data
| Field on screen | Source | Format | Behavior when absent |
|---|---|---|---|

## Copy
Every string on the screen as a table, including state and error copy.
| Key | Text | Translation note |
|---|---|---|

## Motion
Table per domain/prototyping.spec.md. Empty means platform-standard transitions.

## Accessibility
The spec:* annotations from the design plus focus order and accessible names.

## Assets
What was exported, in what format, where it lives.

## Open questions
Empty at handoff. A non-empty section means the spec is not ready.
```

## Content requirements

| Requirement | The check |
|---|---|
| Not a single "as in the design" | that is a pointer, not a specification: values come from the DS, behavior from prose |
| Not a single "same as …" without a link | an analogy without a link is a guess |
| Every number comes from a token | a raw value in the spec becomes a hardcoded value in code |
| Every state links to its frame | otherwise the engineer cannot find it |
| Every string is in the copy table | text does not transfer accurately off a screenshot |
| The "Open questions" section is empty | otherwise it is a draft |

## Annotations in the design

The handoff and the design complement each other. `spec:` layers live in the design (`domain/accessibility.spec.md`); `handoff.md` carries what cannot be expressed graphically: behavior, data, edge cases, timings.

Do not duplicate what the Figma inspector already reports (spacing, colors, sizes) — that is the first thing to go stale.

## Acceptance

The designer verifies the implementation per `workflows/drift-check.spec.md`. Divergence is filed as a `DESIGN_DRIFT` finding, not as a chat message.

## Findings

| Code | Severity | When |
|---|---|---|
| `HANDOFF` | IMPORTANT | no copy table; adaptivity described for one breakpoint; a frame link without a node-id |
| `HANDOFF` | CRITICAL | non-empty "Open questions"; no state matrix; a link pointing at a `🚧 WIP` page |

## Cross-refs

- domain/states.spec.md — the coverage matrix
- domain/prototyping.spec.md — the motion table
- domain/accessibility.spec.md — annotations
- workflows/handoff-quality.spec.md — gates G1-G6
- workflows/drift-check.spec.md — accepting the implementation
