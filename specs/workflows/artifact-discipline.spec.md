---
name: artifact-discipline
layer: workflow
purpose: Keeping artifacts honest — checkboxes with links, immutability of closed tasks and DDRs, four checks after breaking down a large artifact, session start and end protocols, what to say out loud
applies_to:
  loaded_for_modes: ["quick", "standard", "full"]
  task_keywords: ["checkbox", "checklist", "ddr", "breakdown", "archive", "session", "handover"]
owner: design-lead
---

# Artifact Discipline

Rules for every checklist artifact (DoR and DoD in `spec.md`, the coverage matrix, the epic breakdown, the DDR consumer table, `a11y-privacy.md`) and for closing artifacts. Breaking any rule in §1–§3 means rolling back and starting the item over.

## §1. Checkbox discipline

1. `[x]` goes in **only after the fact has been checked**: the frame exists in Figma, the audit is clean, the export is fresh. Never in advance, never "about to finish".
2. Automation does not replace looking. An automatic tick without a check is forbidden.
3. No batching: **one item, one tick, one update**.
4. Every `[x]` carries a link: `✅ <node id or frame name>`, `✅ <file path>`, or `✅ commit <hash>`.
5. A partly done item stays `[ ]` with `(in progress: …, left: …)`. `[x]` only at 100%.
6. A wrong `[x]` goes back to `[ ]` with `was [x], unchecked <date>: <reason>`.
7. Items are **never deleted**. An item that no longer applies gets `(cancelled <date>: <reason>)`.
8. An item that needs a design decision the pre-spec does not make → **stop** (Tier 2, `workflows/decision-gates.spec.md`): extend the pre-spec or write a DDR.

## §2. Immutability and cosmetics

- A delivered task folder and a DDR with status `accepted` or `superseded` are **immutable**. A mistake is fixed by a new task or a new DDR that links to the old one (`supersedes:`).
- Additions to a live DDR (`proposed`) go in as a session journal line (`> Added in session <date>: …`), without rewriting what was there.
- **Never edit DDRs or task artifacts for cosmetics** while working on an unrelated task. Spec edits are a separate session and a separate commit.
- Closing any artifact (task delivered, DDR accepted, epic closed) happens only after the final re-check in `workflows/verify.spec.md`.

## §3. Breaking down a large artifact — at least four checks

A large artifact (a brief, a section redesign, a monolithic requirements document) is split into several (an epic, task pre-specs, DDRs, component specs). After the split, run **at least four checks** on the results and record the outcome in the epic:

- (a) **Completeness** — no requirement, screen, state, or decision from the source was lost.
- (b) **No duplicates or contradictions** between the new artifacts.
- (c) **Cross-references are correct** — each points at an existing artifact or section; none broken, none circular.
- (d) **Format is followed** — each artifact matches its template: epic — `per-epic/EPIC-TEMPLATE.md`, task — `per-task/DESIGN-TASK-TEMPLATE.spec.md` or `per-task/QUICK-TEMPLATE.spec.md`, component — `per-task/COMPONENT-TEMPLATE.md`, DDR — `per-task/DDR-TEMPLATE.md`.

Any check fails → the breakdown is not closed; fix and re-check.

## §4. Session start protocol

Before working on an existing artifact:

1. Identify the task's artifacts: the task folder (`<PER_TASK_SPEC_LOCATION>/<task-id>/`), its epic, its DDRs.
2. Read them **in full**: `spec.md`, the latest checkpoint or session handover, open DDRs, `epic.md` if any.
3. Check the state: task status in `<TRACKER_NAME>`, DDR statuses, whether the task is delivered.
4. Refresh the Figma export of the task's frames if the cache is stale.
5. Load the relevant domain specs per `specs/LOADER.md`.
6. Show the human the session plan: items, frames, checks. For a session starting from scratch, wait for confirmation. For a specific assignment a short summary is enough: "taking X and Y; touching frames A and B".

## §5. Session end protocol

Before announcing the task done:

1. `git status` — no stray untracked files.
2. The minimum from `workflows/verify.spec.md §1`. When closing an artifact, the full re-check in `verify.spec.md §2–§3`.
3. A short report: items closed, files and frames touched, checks passed, state changes, what is left.
4. Delivering a task or accepting a DDR — an explicit notice to the human.
5. The session ends before the work does → a session handover per `workflows/checkpoint.spec.md §Session handover`.

## §6. Always say out loud

- A DDR status change.
- Delivering a task.
- Creating a new DDR, task, or epic.
- Deleting or renaming a file or a Figma page.
- A change to the public DS surface.
- An action touching more than 5 files or more than 5 frames.

## Cross-refs

- workflows/verify.spec.md — the checks before a commit and before closing
- workflows/decision-gates.spec.md — the Tier 2 stop in §1 item 8
- workflows/checkpoint.spec.md — session handover
- workflows/agent-log.spec.md — agent-log before closing
- per-task/DDR-TEMPLATE.md — DDR status model
- core/project.spec.md — §5, where per-task artifacts live
