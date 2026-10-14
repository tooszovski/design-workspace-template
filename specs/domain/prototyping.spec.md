---
name: prototyping
layer: domain
purpose: Prototypes and motion — what to prototype, depth, timings, handing motion to engineering
applies_to:
  task_keywords: ["prototype", "animation", "transition", "motion", "interaction", "prototypes", "animations", "transitions", "interactions"]
  triggers: ["task needs to show a flow or behavior over time"]
owner: design-lead
---

# Prototyping & Motion

## When a prototype is needed

| Needed | Not needed |
|---|---|
| A flow of 3+ steps where sequence matters | A single static screen |
| A non-obvious transition that words describe poorly | A standard DS transition |
| Validation with users | An internal color review |
| A contested interaction that has to be felt | A screen decided entirely by layout |

A prototype is a communication tool, not a mandatory artifact. A prototype built for the checkbox eats time and goes stale faster than the design.

## Depth

Cover the **whole happy path** plus the branches under discussion. There is no need to wire every state of every screen: an under-wired prototype with 200 connections is worse than a coherent one with 12.

The task's `spec.md` states what the prototype covers, so a reader does not mistake a missing connection for a bug.

## Motion

Animation has a reason. Valid reasons: showing the relationship between states, directing attention, softening an abrupt change, acknowledging an action. "It looks nice" is not a reason.

### Timings

| Kind | Duration | Curve |
|---|---|---|
| Micro-feedback (press, checkbox) | 100–150ms | ease-out |
| Element appearing or leaving | 200–250ms | ease-out / ease-in |
| Screen transition | 250–350ms | ease-in-out |
| Large overlay, sheet | 300–400ms | ease-out |

Anything past 400ms reads as sluggish. Anything under 100ms is not perceived at all.

### Rules

- Entry is faster than exit: appearing matters, disappearing must not hold the user up.
- Movement along one axis. Simultaneous translate, rotate, and scale reads as a glitch.
- Animation never blocks input: the user can press a button before a transition finishes.
- Repeating animations (in lists) use a stagger of 50ms or less and cascade across no more than five items.
- A `prefers-reduced-motion` variant exists: motion becomes a fade or is removed (`domain/accessibility.spec.md`).

## Handing motion to engineering

A Figma prototype **is not a motion specification** — it does not carry exact curves and cannot be read from code. In the handoff, motion is described as a table:

| Element | Trigger | Property | From → To | Duration | Curve | Delay |
|---|---|---|---|---|---|---|
| Sheet | tap "Pay" | translateY | 100% → 0 | 300ms | ease-out | 0 |
| Scrim | same | opacity | 0 → 0.4 | 300ms | linear | 0 |

Without that table the engineer will invent values, and they will differ on every screen.

## Findings

| Code | Severity | When |
|---|---|---|
| `MOTION` | MINOR | timing outside the recommended range |
| `MOTION` | IMPORTANT | motion exists in the prototype but is absent from the handoff; no reduced-motion variant |
| `MOTION` | CRITICAL | animation blocks input; flashing above 3Hz |

## Cross-refs

- domain/states.spec.md — transitions between states
- domain/accessibility.spec.md — reduced motion
- domain/handoff.spec.md — the motion table in the spec
