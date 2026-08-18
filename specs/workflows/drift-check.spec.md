---
name: drift-check
layer: workflow
purpose: Comparing implementation against the design — what to check, filing DESIGN_DRIFT, acceptance
applies_to:
  paths: ["code/**", "<CODE_REPO_PATH>"]
  task_keywords: ["drift", "acceptance", "implementation", "not as designed", "check the build"]
  loaded_for_modes: ["standard", "full"]
owner: reviewer-designsystem
---

# Drift Check

Comparing what was built against what was designed. Runs **after** implementation, as its own task.

It needs `<CODE_REPO_PATH>` (the `./code` symlink). Without it, only a visual comparison against screenshots from engineering is possible.

## What gets compared

| Layer | How | Priority |
|---|---|---|
| **Tokens** | values in code against variables in Figma | highest: divergence multiplies across every screen |
| **Components** | a DS component used, or rebuilt from scratch | high |
| **States** | whether everything in the coverage matrix exists | high |
| **Layout** | spacing from the scale, behavior at breakpoints | medium |
| **Copy** | matches the copy table in `handoff.md` | medium |
| **Accessibility** | whether the `spec:*` annotations were implemented | high |
| **Motion** | timings and curves from the table | low |

The order matters: comparing spacing pixels while colors are still hardcoded is pointless.

## What is not drift

- A 1–2px difference from render rounding
- Platform-native differences (scroll inertia, system font)
- A difference recorded in a DDR as a deliberate trade-off
- Anything absent from `handoff.md`: if the spec was silent, that is a spec defect (`HANDOFF`), not an implementation defect

That last point matters: half of all "drift" is something the designer never wrote down.

## Finding format

```
DESIGN_DRIFT: <what diverges>
Severity: MINOR | IMPORTANT | CRITICAL
Design:         <what Figma shows> · <frame link>
Implementation: <what the code does> · <path:line or screen>
Cause:          implementation defect | spec defect | deliberate trade-off
Action:         <fix the code | extend the spec | record a DDR>
```

The `Cause` field is mandatory — it determines who receives the task.

## Severity

| Severity | When |
|---|---|
| MINOR | a difference invisible to the user: a timing, 2px |
| IMPORTANT | a difference that changes perception: wrong group spacing, wrong font weight, hardcoded value instead of a token |
| CRITICAL | a state is missing; adaptivity is broken; accessibility is violated; the wrong component was used |

Any CRITICAL is a Tier 2 stop.

## Token drift

A separate pass: compare `<TOKENS_EXPORT_PATH>` against the variables (`domain/tokens-export.spec.md`). Divergence here means the export was never rerun after the library was published — the fix is rerunning `/design.tokens`, not editing screens.

## Filing

All findings go into `<PER_TASK_SPEC_LOCATION>/<task-id>/drift.md`, and from there into `<TRACKER_NAME>` tasks. A chat message does not count as an artifact.

Acceptance passes when there are zero CRITICALs and every IMPORTANT is either fixed or accepted in writing.

## Cross-refs

- domain/handoff.spec.md — what was promised
- domain/tokens-export.spec.md — token drift
- workflows/decision-gates.spec.md — Tier 2
- core/workspace.spec.md — access to `code/`
