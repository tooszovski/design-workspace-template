---
name: team-dispatch
layer: workflow
purpose: Agent roster, team size, parallel launch, the lean return contract
applies_to:
  task_keywords: ["dispatch", "team", "agents", "parallel", "subagent"]
  loaded_for_modes: ["standard", "full"]
owner: design-lead
---

# Team Dispatch

## Roles

| Agent | When it runs | What it does |
|---|---|---|
| `design-lead` | orchestrator, Standard/Full | runs the task, critiques, holds the gates; does not draw |
| `figma-analyst` | when an export and breakdown are needed | pulls data through MCP, produces a structured report |
| `handoff-author` | step 8 | writes `handoff.md` |
| `reviewer-designsystem` | review | components, tokens, naming |
| `reviewer-a11y` | review | accessibility |
| `reviewer-ux-copy` | review | copy |

## Team size per mode

| Mode | Roster |
|---|---|
| Quick | one agent, no orchestrator |
| Standard | `design-lead` + `figma-analyst` + 3 reviewers + `handoff-author` |
| Full | the same plus a dedicated DS pass and checkpoints |

More agents is not better. Every extra agent is another context to reconcile.

## Parallelism

Reviewers are **always** launched in one message with several `Agent` calls. They are independent: `reviewer-a11y` must not wait for `reviewer-ux-copy`.

Only genuinely dependent steps run in sequence: `figma-analyst` → reviewers (they need the export), reviewers → `handoff-author` (the spec is written against the final design).

## What an agent receives

```
<spec-bundle>
core: [project, workspace, design-system, naming, ...]
workflows: [task-modes, review-pipeline, ...]
domain: [states, accessibility, ...]
task: <PER_TASK_SPEC_LOCATION>/<task-id>/spec.md
figma: <file-key> · <node-id> · <path to the cached export>
scope: <which frames belong to the task>
</spec-bundle>
```

An agent receives no specs outside the bundle. If it needs another one mid-flight, it returns `SpecsMissing`; the orchestrator decides whether to load it.

## Lean return

One return format **for every agent** in this workspace:

```
Signal: COMPLETE | FAIL | REROUTE
Checkpoint: <path to the file holding the detail>
SpecsUsed: [...]
SpecsMissing: [...]
```

An agent does not retell its work in the reply — the detail lives in the checkpoint file. Retelling inflates the orchestrator's context with exactly what is already on disk.

`SpecsMissing` is feedback for the loader: triggers in `INDEX.md` get corrected from it.

## Constraints

- An agent does not write to Figma (D-02).
- An agent does not edit `core/` specs without an explicit instruction.
- An agent does not close the tracker task — a human or the orchestrator does that at step 9.
- A reviewer does not edit the design: it returns findings.

## Cross-refs

- LOADER.md — how the bundle is assembled
- workflows/review-pipeline.spec.md — review order
- workflows/agent-log.spec.md — the final report
