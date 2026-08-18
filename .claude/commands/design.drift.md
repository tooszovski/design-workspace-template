---
description: Compare the implementation in ./code against the design and file DESIGN_DRIFT findings
allowed-tools: Read, Grep, Glob, Bash, Write, mcp__figma__get_figma_data, mcp__figma__download_figma_images
---

# /design.drift

Accepting the implementation. Runs **after** engineering has shipped the screen.

**Arguments:** a task id and, optionally, a path to the implementation files inside `./code`.

## Preconditions

- The task has a `handoff.md` — without it there is nothing to compare against
- `./code` exists, or engineering supplied screenshots

Without `./code`, only a visual comparison is possible: it catches layout and copy but not tokens and not accessibility. Say that plainly rather than passing a partial check off as a complete one.

## Order of comparison

The order is mandatory: comparing spacing pixels while colors are still hardcoded is pointless.

### 1. Tokens

Compare values in code against `exports/tokens/` and against the variables. A hardcoded value in code where a token exists is a `DESIGN_DRIFT` with cause "implementation defect".

Separately: divergence between `<TOKENS_EXPORT_PATH>` and Figma is `TOKEN_DRIFT`, fixed by rerunning `/design.tokens`, not by editing screens.

### 2. Components

Was a design-system component used, or was one rebuilt? Rebuilt is CRITICAL: it will not receive DS updates.

### 3. States

Against the coverage matrix in `spec.md`: every `✅` must be implemented. A missing state is CRITICAL.

### 4. Layout

Spacing from the scale, behavior at the ends of the breakpoint range, overflow, long text.

### 5. Copy

String for string against the copy table in `handoff.md`.

### 6. Accessibility

Were the `spec:*` annotations implemented: accessible names, focus order, roles, live regions, enlarged hit areas.

### 7. Motion

Timings and curves from the table. Lowest priority.

## Classifying the cause

Every finding needs a cause — it determines the recipient:

| Cause | Goes to |
|---|---|
| implementation defect | engineering |
| spec defect — it was never in `handoff.md` | design: extend the spec, do not file a bug |
| deliberate trade-off | record a DDR and close it |

Half of all "drift" is the second and third case. Do not send those to engineering as bugs.

## What is not drift

- A 1–2px difference from render rounding
- Platform-native differences: scroll inertia, system font, native transitions
- A trade-off already recorded in a DDR

## Finding format

```
DESIGN_DRIFT: <what diverges>
Severity: MINOR | IMPORTANT | CRITICAL
Design:         <what Figma shows> · node <id>
Implementation: <what the code does> · <path:line>
Cause:          implementation defect | spec defect | deliberate trade-off
Action:         <fix the code | extend the spec | record a DDR>
```

## Return

Write to `<PER_TASK_SPEC_LOCATION>/<task-id>/drift.md` and file tasks in `<TRACKER_NAME>`.

```
Signal: COMPLETE | FAIL
Checkpoint: <path to drift.md>
Findings: N critical, M important, K minor
Of which spec defects: X
```

Acceptance passes with zero CRITICALs and every IMPORTANT closed in writing. Any CRITICAL is a Tier 2 stop.
