---
description: Build the engineering handoff spec from a Figma frame and the task spec
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, AskUserQuestion, mcp__figma__get_figma_data, mcp__figma__download_figma_images
---

# /design.handoff

Generates `handoff.md` — the spec an engineer builds the screen from without asking anything (D-12).

**Argument:** a task id (`<PROJECT_PREFIX>-NNN`) or a frame link.

## Preconditions

Do not start until:

- `/design.audit` reports no CRITICALs
- the state matrix in `spec.md` is filled in
- the frames have moved to a `✅` page

If any of those fail, say which and stop. A spec written against an unfinished design goes stale within a day.

## Step 1 — Gather

1. Read the task's `spec.md`: problem, AC, state matrix, adaptivity, guardrails.
2. Export every frame of the task through MCP — each state, each breakpoint.
3. Collect the components used: `componentId` → name and properties.
4. Collect every text node with its path — that becomes the copy table.
5. Collect layers prefixed `spec:` — those are the accessibility and behavior annotations.
6. Read `📐 Cover` and record the library version.

## Step 2 — Fill it in

Take the structure from `domain/handoff.spec.md` and complete every section.

Rules:

| Section | Where it comes from | What not to do |
|---|---|---|
| Components | `componentId` from the export | do not describe a component's internals — those live in the DS |
| States | the matrix plus links to real frames with node-ids | do not write "see Figma" without a node-id |
| Adaptivity | comparing frames across breakpoints | do not settle for a single breakpoint |
| Behavior | AC from `spec.md` plus edge cases | do not write "as usual" |
| Data | the screen's fields plus what happens when each is absent | do not skip "what if it is empty" |
| Copy | every text node as a table | do not leave text living only in a picture |
| Motion | the table from `domain/prototyping.spec.md` | do not point at the prototype instead of the table |
| Accessibility | `spec:*` layers plus focus order | do not assume the engineer will infer it |
| Assets | what was exported and where | do not attach binaries to the spec |

Spacing, colors, and sizes are **not** duplicated — the Figma inspector reports them and they are the first thing to go stale in a spec. Only rules and behavior get written down.

## Step 3 — Gaps

Collect everything you could not resolve into the "Open questions" section and put it to the human as one batch through `AskUserQuestion`.

That section must be empty before handoff: non-empty means draft (`workflows/handoff-quality.spec.md` G5).

## Step 4 — Self-check

Read the finished spec **as an engineer who has not seen the task**. Mark every place a question would arise and write the answer in. The usual gaps:

- what happens on a second tap while a request is in flight
- what happens at 0, 1, and 1000 items
- where the default value comes from
- what happens without permissions
- whether state survives leaving the screen and coming back

## Step 5 — Return

Write to `<PER_TASK_SPEC_LOCATION>/<task-id>/handoff.md`.

```
Signal: COMPLETE | FAIL
Checkpoint: <path to handoff.md>
Open questions: N
SpecsUsed: [...]
```

When `N > 0`, return `Signal: FAIL` — the spec is not ready to hand over.
