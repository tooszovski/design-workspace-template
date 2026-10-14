---
name: design-task-template
kind: template
purpose: Pre-spec for a Standard/Full design task — problem, AC, state matrix, guardrails, DoR
owner: design-lead
---

# <PROJECT_PREFIX>-NNN · <Task title>

> Filled in before work starts. Status `approved` is the precondition for step 2.

```yaml
task_id: <PROJECT_PREFIX>-NNN
epic_ref: <epic-id or ->
mode: standard | full
status: draft | clarify | approved
figma_file: <FIGMA_PRODUCT_FILE_KEY>
figma_nodes: [<node-id>, ...]
ds_version: <library version at start>
surfaces: [<screens>]
platforms: [<from PLATFORMS>]
attachments: [figma_link | screenshot | reference]
```

## 1. The user problem

What the person is trying to do and what currently stops them. Two or three sentences, no solution described.

## 2. Why the business cares

One sentence. If it cannot be written, the task has not been prioritized.

## 3. Scope

**In:**
- <screen / state / component>

**Out:**
- <what is explicitly outside — this list is what protects against quiet expansion>

## 4. Requirements

Format: `When <condition>, the system <behavior>`.

| # | Requirement |
|---|---|
| R1 | When the list is empty, the screen explains what goes here and offers a way to add the first item |
| R2 | |

## 5. Acceptance criteria

Given / When / Then. Every criterion is verifiable by looking at the design.

| # | Given | When | Then |
|---|---|---|---|
| AC1 | | | |

## 6. State coverage matrix

Filled in at step 4a. Values: `✅` built · `n/a` not applicable, with a reason · `—` not required.

| Screen | empty | empty-filtered | loading | partial | error | offline | success | data |
|---|---|---|---|---|---|---|---|---|
| | | | | | | | | |

**Reasons for `n/a`:**
- <state> — <why>

### 6a. Failure modes

The matrix says a state exists; this table says how the user gets out of it. Mandatory for screens that load, sync, or submit data. One row per mode; `n/a` only with a reason, never a silent omission. Each applicable row maps to a frame from the matrix or to a line in the handoff.

| Mode | Matrix column | What the user sees | How they get out |
|---|---|---|---|
| No network | offline | <…> | <…> |
| Service error or timeout | error | <…> | <…> |
| Empty data | empty / empty-filtered | <…> | <…> |
| Stale data on screen | data, with a staleness marker | <…> | <…> |
| Long loading, past 3 s | loading | <…> | <…> |
| Partial response | partial | <…> | <…> |
| Version rollback: data or a feature from a newer version seen on an older one | error or data | <…> | <…> |

"How they get out" names an action or an automatic exit: retry, pull to refresh, clear the filter, go back, wait with a visible reason. "Contact support" alone is not a way out.

## 7. Guardrails

Constraints that must not be broken:

- Do not change public `<DS_LIBRARY_NAME>` components (that would force mode → Full)
- Do not introduce new semantic color roles
- Stay within the existing spacing scale
- <project-specific constraints>

## 8. Clarify

| # | Question | Default | Answer | Date |
|---|---|---|---|---|
| Q1 | | | | |

## 9. Adaptivity

| Breakpoint | What changes |
|---|---|

## 10. References

| What | Link |
|---|---|
| Requirements | |
| Research (primary sources) | `research.md`, if the task needed one |
| A comparable screen in the product | |
| `<REFERENCE_PLATFORM>` | |

## 11. Definition of Ready

Work can start when:

- [ ] The user problem is stated
- [ ] Scope, including the "out" list, is filled in
- [ ] Every AC is written and verifiable
- [ ] Clarify is closed, or defaults are adopted
- [ ] The state matrix is marked up (step 4a), and failure modes §6a are filled in
- [ ] `research.md` exists if the task leans on a platform pattern, component, or symbol new to the product (`workflows/research.spec.md`)
- [ ] `a11y-privacy.md` is started if the screen shows sensitive data or introduces new interactive patterns (`per-task/A11Y-PRIVACY-CHECKLIST.md`)
- [ ] The DS version is recorded
- [ ] Guardrails are listed

## 12. Definition of Done

See `core/project.spec.md §2` for the shared DoD. Additions for this task:

- [ ] <project-specific addition, if any>
