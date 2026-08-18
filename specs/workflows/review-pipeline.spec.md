---
name: review-pipeline
layer: workflow
purpose: Who reviews, in what order, parallelism, the pass criterion
applies_to:
  task_keywords: ["review", "pipeline", "acceptance", "check"]
  loaded_for_modes: ["quick", "standard", "full"]
owner: design-lead
---

# Review Pipeline

## Order

```
/design.audit  →  reviewers   →  critique  →  handoff-quality  →  delivery
 (automatic)      (parallel)     (meaning)    (gates G1-G6)
```

Reviewers do not start until `/design.audit` is clean of CRITICALs: they should not spend a pass on what a machine catches.

## Pipeline per mode

| Mode | Who |
|---|---|
| **Quick** | `/design.audit` only; `reviewer-designsystem` as well if a DS component was touched |
| **Standard** | in parallel: `reviewer-designsystem` + `reviewer-a11y` + `reviewer-ux-copy` |
| **Full** | the same plus `design-lead` critique per `workflows/critique.spec.md` plus a separate pass over DS changes (`workflows/versioning.spec.md`) |

Standard and Full reviewers are launched in **one message** with several `Agent` calls — they are independent and must not wait on each other.

## Zones of responsibility

| Reviewer | Examines | Does not examine |
|---|---|---|
| `reviewer-designsystem` | components, variables, spacing, naming, consistency with the DS | copy, contrast |
| `reviewer-a11y` | contrast, focus, touch targets, semantics, `spec:` annotations | DS compliance |
| `reviewer-ux-copy` | copy, terms, tone, state text | visuals |
| `design-lead` (critique) | the problem, hierarchy, completeness, buildability | anything covered above |

Zone overlap is deliberately minimal: duplicate findings from three reviewers are noise.

## The pass criterion

| Severity | Requirement |
|---|---|
| CRITICAL | zero. Each is closed by a fix or waived by a human through Tier 2 |
| IMPORTANT | closed, or justified in writing in the worklog |
| MINOR | author's discretion; anything left open is recorded as debt in the agent log |

## Reroute

A reviewer sending work back is a reroute. The limits:

| Counter | Limit |
|---|---|
| Per author↔reviewer pair | 3 |
| Total per task | 5 |

On reaching a limit, Tier 2 hard stop: a human decides from there. An endless edit loop means the problem is in the spec or the brief, not in the design.

## Reviewer return format

```
Signal: COMPLETE | FAIL | REROUTE
Checkpoint: <PER_TASK_SPEC_LOCATION>/<task-id>/critique.md
Findings: <N critical, M important, K minor>
SpecsUsed: [...]
SpecsMissing: [...]
```

## Cross-refs

- workflows/critique.spec.md — what critique contains
- workflows/team-dispatch.spec.md — how to launch
- workflows/decision-gates.spec.md — Tier 2
- workflows/handoff-quality.spec.md — gates after review
