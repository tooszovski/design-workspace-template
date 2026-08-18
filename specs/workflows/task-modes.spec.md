---
name: task-modes
layer: workflow
purpose: Classifying a design task as Quick/Standard/Full, criteria, escalation
always_loaded: true
applies_to:
  task_keywords: ["mode", "quick", "standard", "full"]
  loaded_for_modes: ["quick", "standard", "full"]
owner: design-lead
---

# Task Modes

The mode sets the depth of the workflow: the simpler the task, the less ceremony.

## Order of determination

1. An explicit line in `spec.md`: `**Mode:** quick`
2. An explicit instruction from a human
3. Auto-detection by the criteria below

## The modes

| Mode | Criteria | Workflow |
|---|---|---|
| **Quick** | 1–2 frames, editing an existing screen, no new components and no new decisions | One agent: read requirements → edit → audit → hand off. No critique, no DDR. |
| **Standard** | 3–10 frames, a new screen or flow, built from existing components | Full cycle: clarify → structure → states (states contract) → critique → handoff. |
| **Full** | 10+ frames, a new section, a DS change, a new pattern, a rebrand | Standard plus an epic charter, DDRs, parallel critique, and checkpoints. |

## Automatic Full

Regardless of size, a task becomes Full when it:

- changes a **public component** of the design system (D-11)
- changes **semantic variables** or adds a mode (theme)
- introduces a **new interaction pattern** the product does not have
- touches **onboarding, payment, authentication**, or another critical flow
- affects every screen in the product (navigation, header, typography)

## Escalation

If a Quick task turns out to be bigger, **escalate to Standard** rather than stretching the current mode. Same for Standard → Full.

Escalation triggers: a new component turned out to be needed; a product question surfaced; more than two states appeared; the edit pulled in neighboring screens.

Record it in the worklog: `### HH:MM — ESCALATE Quick→Standard, reason: ...`.

De-escalation is forbidden: a task that started as Full is not downgraded midway.

## State requirements per mode

| Mode | Requirement |
|---|---|
| Quick | do not break existing states; new ones are not required |
| Standard | coverage matrix mandatory, states contract 4a/4b/4c |
| Full | the same plus described transitions between states |

## Specs loaded per mode

See `LOADER.md`.

| Mode | Workflows |
|---|---|
| Quick | task-modes, design-workflow, review-pipeline, decision-gates, anti-patterns |
| Standard | plus clarify, critique, handoff-quality, drift-check, team-dispatch, agent-log (plus versioning if the DS is touched) |
| Full | plus checkpoint, versioning |

## Cross-refs

- workflows/design-workflow.spec.md — the steps
- workflows/review-pipeline.spec.md — review depth
- workflows/checkpoint.spec.md — checkpoints in Full
