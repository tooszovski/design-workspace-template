---
name: checkpoint
layer: workflow
purpose: Intermediate checkpoints in long tasks — when, what to record, how to resume; the session handover across tasks
applies_to:
  task_keywords: ["checkpoint", "long task", "resume", "interruption", "handover"]
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

## Session handover

The session ends but the work does not (end of day, a limit, handing over to another agent or person) → a state snapshot in `docs/YYYY-MM-DD-session-handover.md`. A second snapshot on the same day gets a suffix: `docs/YYYY-MM-DD-session-handover-evening.md`. A checkpoint describes one task; a handover describes the whole session across tasks.

Required sections:

1. **Checked in this session.** Only what was run, opened, or read now, not taken from memory or the previous handover. Anything unchecked is marked `UNVERIFIED` (`workflows/research.spec.md`).
2. **Files and branches.** Figma files and pages touched, with `lastModified`; the head sha of each touched branch, whether it is pushed, whether the tree is clean. Uncommitted edits — whose and where from.
3. **What was done.** Delivered tasks, DDRs written or accepted, tracker items filed, process artifacts created, with links.
4. **Unfinished work.** Per task: where the artifacts are, what was measured, which decisions the human has already made, which step to resume from.
5. **Waiting on people.** Who, what exactly, since when, what it blocks.
6. **Constraints and traps.** Broken tools, MCP quirks, workarounds found in the session.
7. **Next steps.** In order; first whatever does not depend on other people.
8. **Stale references.** Node ids, paths, item numbers, and links in artifacts that went out of date and need fixing.
9. **Previous snapshot.** A link to the last `docs/*-session-handover*.md`.

A handover does not replace `worklog.md` or a task checkpoint; it links to them. The next session starts from the latest handover and the start protocol in `workflows/artifact-discipline.spec.md §4`.

## Cross-refs

- workflows/agent-log.spec.md — worklog and the final report
- workflows/decision-gates.spec.md — stops
- domain/figma-structure.spec.md — export caching
- workflows/artifact-discipline.spec.md — session start and end protocols
