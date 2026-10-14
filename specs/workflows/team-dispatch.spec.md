---
name: team-dispatch
layer: workflow
purpose: Agent roster, team size, parallel launch, model routing, the lean return contract, inbox drain and crash recovery
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

## Model routing

Two tiers: a **base model** by default and a **senior model** on signals. The project picks the concrete models. At setup the project pins a role's model with `model:` in the frontmatter of `.claude/agents/*.md`: senior for `design-lead`, base for `figma-analyst`, `handoff-author`, and the reviewers. Without the field, an agent runs on the session model. For a manual dispatch, pass `model` to the Agent tool.

| Model | When |
|---|---|
| **Base** (default) | tasks with complete requirements, Quick edits, exports and breakdowns, handoff writing from a final design, reviewers on small scopes |
| **Senior**, signal 1 | design thinking: pre-spec, DDR, epic charter, a new pattern; `design-lead` |
| **Senior**, signal 2 | the final critique of a whole epic; escalating a review loop after the third round |
| **Senior**, signal 3 | hard diagnosis: an implementation drifts from the design and nobody knows why, contradictory requirements |
| **Senior**, signal 4 | the automatic-Full zones in `workflows/task-modes.spec.md`: public DS components, semantic variables, a new interaction pattern, critical flows (onboarding, payment, authentication), product-wide changes |
| **Senior**, signal 5 | repeated failure: the base model failed the task twice |
| **Senior**, signal 6 | large uncertainty in the requirements |

- Signal 4 lifts **design and review** to the senior model. Building an approved design into a handoff stays on the base model.
- An agent does not switch models itself. Hitting signal 3, 5, or 6, it writes `needs escalation to the senior model: <reason>` in its report, and the orchestrator re-dispatches.
- A switch to the senior model is recorded with its reason in the task's agent-log (`workflows/agent-log.spec.md`).

## Operational rules

- **Inbox drain before a status report.** The orchestrator reads every incoming message before claiming "reports have not arrived" or "rework 0". The typical failure: reporting "reviewers are silent" while their reports, CRITICALs included, already sit in the inbox.
- **Crash recovery when an agent dies** (API error, session limit). Before re-dispatching, check the working tree and the task folder for the dead agent's results. Verify anything salvaged by re-running the relevant check and commit it separately. If there is nothing to salvage, the re-dispatch brief says so explicitly: "previous run killed, nothing salvaged, start from scratch".

## Constraints

- An agent does not write to Figma (D-02).
- An agent does not edit `core/` specs without an explicit instruction.
- An agent does not close the tracker task — a human or the orchestrator does that at step 9.
- A reviewer does not edit the design: it returns findings.

## Cross-refs

- LOADER.md — how the bundle is assembled
- workflows/review-pipeline.spec.md — review order
- workflows/agent-log.spec.md — the final report
