---
description: Audit a Figma frame against design-system rules — detached, hardcoded, spacing, states, naming
allowed-tools: Read, Write, Grep, Glob, Bash, mcp__figma__get_figma_data, mcp__figma__download_figma_images
---

# /design.audit

Automated rule checking on a design. It runs **before** the reviewers: do not spend their pass on what a machine catches.

**Argument:** a Figma frame link, or `<file-key> <node-id>`. Without one, ask.

## Step 1 — Load

1. Extract `file-key` and `node-id` from the link. The URL uses a hyphen (`1234-5678`); the API uses a colon (`1234:5678`).
2. Check the cache at `.figma-cache/<file-key>/<node-id>.json`. Use it if the file's `lastModified` has not changed.
3. Call `mcp__figma__get_figma_data` with `nodeId`. Save to cache.
4. No access → stop with `FAIL: figma access`. Do not reconstruct the design's contents from the task title.

Read these specs: `core/design-system`, `core/naming`, `domain/components`, `domain/variables`, `domain/layout`, `domain/states`, `domain/color`, `domain/typography`.

## Step 2 — Checks

| # | What | How to spot it | Code | Severity |
|---|---|---|---|---|
| 1 | Detached instances | nodes that visually mirror a library component but carry no `componentId` | `DS_VIOLATION` | CRITICAL |
| 2 | Hardcoded color | `fills` with a direct value instead of `boundVariables` | `DS_VIOLATION` | CRITICAL |
| 3 | Hardcoded spacing | `itemSpacing`/`padding*` outside `<SPACING_SCALE>` | `LAYOUT` | IMPORTANT |
| 4 | Manual typography | a text node with no `textStyleId` | `TYPO` | IMPORTANT |
| 5 | Direct primitive reference | a component or screen referencing `color/*/NNN` instead of a semantic role | `DS_VIOLATION` | IMPORTANT |
| 6 | Auto-generated names | `Frame N`, `Group N`, `Rectangle N`, `Copy of` | `NAMING` | IMPORTANT |
| 7 | `🚧` layers | the prefix in a layer name | `NAMING` | CRITICAL when the frame is on a `✅` page |
| 8 | Missing states | no `empty` / `loading` / `error` frames in the section | `STATE_MISSING` | CRITICAL |
| 9 | No `focused` | an interactive component with no `State: focused` variant | `A11Y` | CRITICAL |
| 10 | Small touch target | an interactive node under 44×44 with no adjacent `spec:hit-area` | `A11Y` | IMPORTANT |
| 11 | Contrast | text-on-background pairs across every mode | `A11Y_CONTRAST` | CRITICAL for body text |
| 12 | Fixed width | `Fixed` inside an adaptive container | `LAYOUT` | IMPORTANT |
| 13 | Deprecated component | an instance whose component description contains `[deprecated]` | `DS_VIOLATION` | CRITICAL |
| 14 | Instance nesting | depth above 3 | `DS_VIOLATION` | MINOR |
| 15 | Icon without `spec:label` | an `Icon/*` instance inside an interactive node with no text | `A11Y` | CRITICAL |

For check 11, compute the WCAG ratio for every real pair, including placeholders, disabled text, text on badges, and field borders. The threshold is `<WCAG_LEVEL>`.

## Step 3 — Report

Write to `<PER_TASK_SPEC_LOCATION>/<task-id>/audit.md` (or `audit-<node-id>.md` when no task is given):

```markdown
# Audit · <frame> · <date>

Source: Figma <file-key> · node <node-id>
Checks: 15 · Found: N critical, M important, K minor

## CRITICAL
### DS_VIOLATION: detached button instance
Where: `Checkout / actions / Frame 12`
What: the node mirrors `Button/Primary` but is not linked to the component
Action: replace with a `Button/Primary` instance, variant `primary/md`

## IMPORTANT
...

## MINOR
...

## Clean
Checks with no violations: 3, 5, 7, 12, 14
```

The "Clean" section is mandatory: without it there is no way to tell whether a check found nothing or never ran.

## Step 4 — Return

```
Signal: COMPLETE | FAIL
Checkpoint: <path to audit.md>
Findings: N critical, M important, K minor
SpecsUsed: [...]
SpecsMissing: [...]
```

Any CRITICAL blocks the move to review (`workflows/review-pipeline.spec.md`).

## Limits

- The audit does not edit the design: Claude is read-only in Figma (D-02).
- The audit does not replace critique: it checks rules, not whether the design solves the problem (`workflows/critique.spec.md`).
- Checks 1 and 5 are heuristic — mark those findings "likely" and do not present them as fact.
