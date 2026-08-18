---
name: design-workflow
layer: workflow
purpose: Steps of a design task from requirements to handoff, including the states contract
applies_to:
  task_keywords: ["workflow", "process", "steps", "how to run a task"]
  loaded_for_modes: ["quick", "standard", "full"]
owner: design-lead
---

# Design Workflow

## Step 0 — Intake

1. Read the requirements from `<TASK_SPEC_SOURCE_PATH>`.
2. Determine the mode (`workflows/task-modes.spec.md`).
3. Create `<PER_TASK_SPEC_LOCATION>/<task-id>/` and a `worklog.md` with its first entry.
4. Check the consumed library version on the product file's `📐 Cover`.

Output: a task folder and a fixed mode.

## Step 1 — Clarify

Standard and Full only. Gather every uncertainty into **one batch** and ask before starting (`workflows/clarify.spec.md`). One question a day stretches a task across a week.

If the requirements answer everything, write `— CLARIFY: not required` in the worklog and move on.

Output: `spec.md` per `per-task/DESIGN-TASK-TEMPLATE.spec.md` with status `approved`.

## Step 2 — Context

1. Find existing solutions to similar problems in the product — reuse rather than reinvent.
2. Export the needed frames through Figma MCP (`domain/figma-structure.spec.md`).
3. Check which components `<DS_LIBRARY_NAME>` is missing.
4. For Full, look at `<REFERENCE_PLATFORM>` if one is set.

Output: a list of components to reuse and a list of missing ones.

## Step 3 — Structure

The skeleton first: hierarchy, block order, what is primary on the screen (D-10). Colors are not chosen and spacing is not polished at this step.

For Full, produce 2–3 structural options with an explicit comparison; record the choice in a DDR (`per-task/DDR-TEMPLATE.md`).

Output: a screen skeleton, agreed with a human when there were multiple options.

## Step 4 — The states contract

The order is mandatory; polishing the `data` state before the rest exist is forbidden (`domain/states.spec.md`).

| Step | Action | Check |
|---|---|---|
| **4a** | Fill the coverage matrix in `spec.md` | no empty cells |
| **4b** | Build each `✅` state as its own frame | names per `core/naming.spec.md` |
| **4c** | Reconcile the matrix against Figma | every `✅` is a real frame; a mismatch is a FAIL |

## Step 5 — Polish

Tokens, spacing from the scale, typography, copy, adaptivity, assets. This is where `domain/layout`, `color`, `typography`, `ux-writing`, and `assets` apply.

## Step 6 — Self-check

Run `/design.audit` across the task's frames. Close every CRITICAL before critique — do not hand reviewers what a machine catches.

## Step 7 — Critique and review

Per `workflows/review-pipeline.spec.md`. Standard and Full run the DS, a11y, and copy reviewers in parallel.

Findings are classified; CRITICALs are closed; IMPORTANTs are closed or justified in the worklog.

## Step 8 — Handoff

Write `handoff.md` per `domain/handoff.spec.md`. Pass gates G1–G6 (`workflows/handoff-quality.spec.md`).

## Step 9 — Delivery

1. Move the frames to a `✅` page.
2. Verify the DoD (`core/project.spec.md §2`).
3. Close `worklog.md` with `— DONE: <outcome>`.
4. Move the task to `<TRACKER_TESTING_STATUS>`.
5. Write `agent-log.md` (`workflows/agent-log.spec.md`).

## Step 10 — Accepting the implementation

Once engineering ships it, run `/design.drift` (`workflows/drift-check.spec.md`). That is a separate tracker task, not a tail on the current one.

## The short path for Quick

Steps 0 → 5 → 6 → 9. Clarify, structure, the states contract, critique, and handoff are skipped when the edit creates no new states and does not touch the DS.

## Cross-refs

- workflows/task-modes.spec.md — choosing the mode
- workflows/clarify.spec.md — question format
- workflows/review-pipeline.spec.md — review
- workflows/handoff-quality.spec.md — handoff gates
- workflows/decision-gates.spec.md — where to stop
