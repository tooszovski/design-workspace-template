# Drills

A fixed set of design tasks for running the workspace scaffolding end to end. It lets you compare the scaffolding before and after an edit to specs, agents, or commands on the same input, instead of on live tasks.

## How to run

1. Take a task from `typical-tasks.md`.
2. Walk it through the full cycle on a throwaway Figma page or a mock brief: research (`specs/workflows/research.spec.md`) → pre-spec (`specs/per-task/DESIGN-TASK-TEMPLATE.spec.md`) → structure with a DDR where options exist → the states contract 4a → `specs/per-task/A11Y-PRIVACY-CHECKLIST.md` where it applies → review per `specs/workflows/review-pipeline.spec.md`. Polished frames are not required: the artifacts up to step 4a plus the review returns are enough.
3. Save the result to `drills/runs/<YYYY-MM-DD>-<n>-<slug>.md` with the rubric score. `runs/` is committed; artifacts from `<PER_TASK_SPEC_LOCATION>` are linked, not copied. Exported PNGs stay out of git (`specs/core/git-policy.spec.md`).

## Rubric

| Criterion | 0 | 1 | 2 |
|---|---|---|---|
| States and failure modes | matrix has empty cells | matrix full, §6a empty | matrix full, every §6a row says what the user sees and how they get out |
| Numbers against tokens | values off the scale or unbound | some bound | every spacing, size, and color on a token; targets and contrast measured |
| Alternatives | one option | two, choice without conditions | two, with the condition under which the choice flips (DDR "When to revisit") |
| Platform references | not checked | checked from memory | every pattern, component, and symbol linked from `research.md` |
| "Needs verification" | no markers | markers without an address | markers with where to check, carried into clarify |
| Accessibility and privacy | not considered | rules cited, nothing measured | contrast, scaling, order, targets measured; sensitive regions marked `spec:sensitive` |
| Review control questions | not answered | partly | all four answered in the `Questions:` block |

The total goes into the run's title. A lower total on the same task after a scaffolding edit is a reason to roll the edit back.

## When to run

After changing `specs/core/*`, `specs/workflows/*`, `specs/per-task/*`, `.claude/agents/*`, or `.claude/commands/*`. At least one task from the set, the one closest to the changed rule.
