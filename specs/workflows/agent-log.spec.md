---
name: agent-log
layer: workflow
purpose: Format of the append-only worklog and the final agent-session report
applies_to:
  task_keywords: ["worklog", "agent-log", "log", "report", "journal"]
  loaded_for_modes: ["standard", "full"]
owner: design-lead
---

# Worklog & Agent Log

Two different files with two different jobs.

## worklog.md — the append-only task log

Written **as work happens**, by appending only. Editing past entries is forbidden: a log that can be rewritten after the fact is worthless.

```markdown
# Worklog · <PROJECT_PREFIX>-NNN

### 14:05 — START
Mode: standard. Requirements: <link>. DS version: 2.3.0.

### 14:20 — CLARIFY
Sent 3 questions. Proceeding on defaults A/A/B.

### 15:10 — AUTO: chose Card/Product over Card/Basic — more common in the product

### 16:30 — STATES 4b
Built: empty, empty-filtered, loading, error, data. offline — n/a, the screen is online-only.

### 17:00 — DRIFT: the answer to Q2 added a confirmation screen, mode standard→full

### 11:15 — REVIEW
3 reviewers: 1 critical (chips have no focused state), 4 important, 2 minor.

### 12:40 — DONE: catalog screen, 5 states, handoff ready
```

Required markers:

| Marker | When |
|---|---|
| `START` | the first entry |
| `AUTO:` | a Tier 1 decision |
| `STOP:` | a Tier 2 stop |
| `ESCALATE` | a mode change |
| `DRIFT:` | a scope change |
| `REOPENED:` | reopening after DONE |
| `DONE:` | the **last** entry, the distillation trigger (`core/vault-contract.spec.md`) |

## agent-log.md — the final report

Written once, at the end. It answers "what happened here" without retelling the worklog.

```markdown
# Agent Log · <PROJECT_PREFIX>-NNN

## Outcome
<What was produced, one paragraph>

## Artifacts
| What | Where |
|---|---|
| Design | Figma <link with node-id> |
| Spec | spec.md |
| Handoff | handoff.md |
| DDR | ddr-001.md |

## Decisions
| Decision | Why | Tier |
|---|---|---|

## Findings
| Severity | Count | Closed | Remaining |
|---|---|---|---|
| CRITICAL | 1 | 1 | 0 |
| IMPORTANT | 4 | 3 | 1 |
| MINOR | 2 | 0 | 2 |

## Debt
<What is left open and why that is acceptable>

## What the specs should fix
<Places where the rules gave no answer, or gave the wrong one — the input for improving specs/>
```

That last section is the log's main value. A task that says nothing about the rules was probably too simple, or the agent failed to notice the friction.

## Where they go

Both files live in `<PER_TASK_SPEC_LOCATION>/<task-id>/`. The cross-task journal, if kept, lives in `<AGENT_LOGS_LOCATION>`.

## Cross-refs

- core/vault-contract.spec.md — DONE as a signal
- workflows/checkpoint.spec.md — intermediate checkpoints
- workflows/team-dispatch.spec.md — lean return
