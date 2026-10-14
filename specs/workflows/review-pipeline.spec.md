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
 (automatic)      (parallel)     (meaning)    (gates G1-G7)
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

## Control questions before the verdict

Every reviewer, and `design-lead` in critique, answers four questions at the end of the return, one line each. A question left unanswered means the review is not finished.

1. **Does anything reference components, variants, tokens, styles, symbols, or platform patterns that do not exist** in the consumed `<DS_LIBRARY_NAME>` version or in the platform guidelines? Check against the `figma-analyst` report, the task's `research.md` (`workflows/research.spec.md`), and the guideline itself. An invented or deprecated reference in the design or the pre-spec is IMPORTANT; once it reaches `handoff.md` or an AC, it is CRITICAL — engineering builds from it.
2. **Do the numbers contradict each other or the tokens?** Spacing outside `<SPACING_SCALE>`, a 44pt target drawn in a 36pt frame, a contrast ratio claimed in the spec but not matching the measured one, a type size in an annotation that differs from its text style, breakpoints that disagree between the pre-spec §9 and the frames.
3. **Does every decision have a considered alternative?** For Full, each structural choice has a DDR with at least two options (`per-task/DDR-TEMPLATE.md`); for Standard, one line in the worklog is enough. A decision with no alternative on record is IMPORTANT in Full and MINOR in Standard.
4. **What would the design lead ask to sink the author?** One question the frames and the spec do not answer. If the answer is in the spec, the DDR, or the frames, say where.

Format, appended to the return:

```
Questions:
  Refs: <no non-existent references | list>
  Numbers: <consistent | mismatch: …>
  Alternatives: <present | missing for: …>
  Lead: <question> → <answered in … | unanswered>
```

An `unanswered` lead question is not a finding by itself; the reviewer decides whether it becomes one, and `design-lead` carries it into the consolidated critique.

## Reviewer return format

```
Signal: COMPLETE | FAIL | REROUTE
Checkpoint: <PER_TASK_SPEC_LOCATION>/<task-id>/critique.md
Findings: <N critical, M important, K minor>
Questions: <the four lines above>
SpecsUsed: [...]
SpecsMissing: [...]
```

## Cross-refs

- workflows/critique.spec.md — what critique contains
- workflows/research.spec.md — the fact base reviewers check references against
- workflows/team-dispatch.spec.md — how to launch
- workflows/decision-gates.spec.md — Tier 2
- workflows/handoff-quality.spec.md — gates after review
