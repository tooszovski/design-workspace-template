---
description: Design critique — problem, hierarchy, completeness, consistency, buildability
allowed-tools: Read, Write, Grep, Glob, Bash, Agent, AskUserQuestion, mcp__figma__get_figma_data, mcp__figma__download_figma_images
---

# /design.critique

Checking whether the **design solves the problem**. Rule compliance is `/design.audit`, which runs first and must be clean of CRITICALs.

**Argument:** a task id or a frame link.

## Step 1 — Context

1. Read `spec.md`: the user problem, the AC, the guardrails.
2. Export the frames through MCP and download the images: the JSON answers "what is it made of", the picture answers "how is it perceived". Critique needs both.
3. Find one or two existing product screens with a similar problem, to check consistency.

## Step 2 — Reviewers

For Standard and Full, launch in parallel, **in one message**:

- `reviewer-designsystem` — components, tokens, spacing, naming
- `reviewer-a11y` — contrast, focus, touch targets, semantics
- `reviewer-ux-copy` — copy, terms, tone

For Quick, only `reviewer-designsystem`, and only if a DS component was touched.

## Step 3 — Your own critique

What the reviewers do not cover (`workflows/critique.spec.md`):

| Axis | Question |
|---|---|
| Problem | Does the screen solve the stated problem? Is the primary action visible within a second? |
| Hierarchy | Does the order of perception match the order of importance? |
| Completeness | Are the states meaningful? Are edge cases on realistic data? Both ends of the adaptive range? |
| Consistency | Does it match how this is solved nearby? If not, is there a DDR? |
| Buildability | Does it assemble from existing components? What here is expensive? |

## Step 4 — The filter

Every finding must answer: **what breaks for the user or for engineering if this is not fixed.**

No answer means it is a preference, not a finding. Preferences go into a separate "Ideas" section and do not block handoff.

Discard: "I think", "feels empty", "make it prettier", "Dribbble does it differently".

## Step 5 — Consolidate

Collect findings from every reviewer plus your own, remove duplicates (three agents often catch the same thing from different angles), and sort by severity.

```markdown
# Critique · <PROJECT_PREFIX>-NNN · <date>

## CRITICAL
### A11Y: filter chips have no focused state
Where: `Catalog / filters`
Why: the filter cannot be traversed by keyboard
Proposal: add `State: focused` to `Chip/Filter`, 2pt `border/focus` ring

## IMPORTANT
...

## MINOR
...

## Ideas (non-blocking)
...

## Summary
N critical, M important, K minor. Blocks handoff: <yes/no>
```

## Step 6 — Return

Close with the four control questions from `workflows/review-pipeline.spec.md`: non-existent references, contradicting numbers, missing alternatives, the lead's question.

```
Signal: COMPLETE | REROUTE
Checkpoint: <PER_TASK_SPEC_LOCATION>/<task-id>/critique.md
Findings: N critical, M important, K minor
Questions:
  Refs: <no non-existent references | list>
  Numbers: <consistent | mismatch: …>
  Alternatives: <present | missing for: …>
  Lead: <question> → <answered in … | unanswered>
```

The design's author answers every finding: accepted, or rejected with a reason. A rejected CRITICAL is a Tier 2 stop.

Reroute limits: 3 per pair, 5 per task (`workflows/review-pipeline.spec.md`).
