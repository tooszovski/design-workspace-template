# `specs/per-task/`

Templates for task-level artifacts. These are **forms**, not filled-in documents — the real ones live in `<PER_TASK_SPEC_LOCATION>/<task-id>/`.

## Which one to take

| Template | When |
|---|---|
| `DESIGN-TASK-TEMPLATE.spec.md` | Standard / Full: a new screen, a flow, a substantial rework |
| `QUICK-TEMPLATE.spec.md` | Quick: editing 1–2 frames with no new states or components |
| `COMPONENT-TEMPLATE.md` | a `<DS_LIBRARY_NAME>` component is created or changed |
| `DDR-TEMPLATE.md` | one of several valid options was chosen, and the choice has to survive six months |

## The selection rule

When torn between Quick and Standard, take Standard. Downgrading mid-task is forbidden, and upgrading costs you the work already done (`workflows/task-modes.spec.md`).

## Worked examples

`bootstrap/examples/` holds an end-to-end example on a mock task.
