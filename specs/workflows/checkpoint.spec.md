---
name: checkpoint
layer: workflow
purpose: Intermediate checkpoints in long tasks — when, what to record, how to resume
applies_to:
  task_keywords: ["checkpoint", "long task", "resume", "interruption"]
  loaded_for_modes: ["full"]
owner: design-lead
---

# Checkpoints

A checkpoint is a snapshot of task state that lets work resume in a new session without losing context.

## When one is required

- Mode is Full
- The task is estimated above 2 hours
- The task crosses a day boundary
- Before a Tier 2 stop, when the answer will take a while
- Before handing the task to another person or agent

## Points

Checkpoints mark the end of a phase, not intervals on a clock:

| Point | What is captured |
|---|---|
| after Clarify | questions sent, defaults adopted |
| after Structure | skeleton agreed |
| after 4b | every state built |
| after Polish | design ready for review |
| after Review | findings resolved |

## Format

`<PER_TASK_SPEC_LOCATION>/<task-id>/checkpoint-<N>.md`:

```markdown
# Checkpoint 2 · <PROJECT_PREFIX>-NNN · after 4b

## State
Every catalog state is built. Polish has not started.

## Where things are
| Artifact | Link |
|---|---|
| Frames | Figma <file-key> · node <id> |
| Cached export | .figma-cache/<file-key>/<node-id>.json |
| Spec | spec.md (Clarify closed) |

## Decisions taken
- Q1 → A (answer received)
- Q2 → default B, no answer yet
- Used Card/Product, not Card/Basic

## Open
- Waiting on Q2; if the answer is C, empty-filtered gets rebuilt
- Undecided: whether to show a counter past 1000 items

## Next step
Polish: tokens, spacing, copy. Start with the error state.
```

## Resuming

A new session starts by reading the **latest** checkpoint, not the whole worklog. The order: `CLAUDE.md` → `specs/core/*` → the latest checkpoint → `spec.md` → the cached export.

If the Figma cache is stale (the file's `lastModified` changed), re-export; do not trust the snapshot.

## What is not a checkpoint

A chat message, a Figma comment, a tracker note. Only a file in the task folder counts. Nothing else survives a session change.

## Cross-refs

- workflows/agent-log.spec.md — worklog and the final report
- workflows/decision-gates.spec.md — stops
- domain/figma-structure.spec.md — export caching
