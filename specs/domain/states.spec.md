---
name: states
layer: domain
purpose: Required screen and element states, the coverage matrix, the states contract
applies_to:
  task_keywords: ["state", "empty", "loading", "error", "skeleton"]
  triggers: ["any task designing a screen that displays data"]
owner: reviewer-designsystem
---

# States

D-05: a screen is not done until every applicable state is covered. This is a **contract**, not a recommendation.

## Screen states

| State | When it happens | What it must contain |
|---|---|---|
| **empty** | there is no data and that is normal | why it is empty and an action that gets the user out of it |
| **empty-filtered** | no data because of a filter or search | text with a way to clear the filter — distinct from `empty` |
| **loading** | data is being fetched | a skeleton shaped like the coming content; a spinner only for operations under 400ms |
| **partial** | some data has arrived | what to show in the unloaded part |
| **error** | the request failed | the cause in human language plus a way to retry |
| **offline** | no network | distinct from `error`: show what is available from cache |
| **success** | an action completed | confirmation and the next step |
| **data** | the normal path | the base design |

**Non-applicability is stated explicitly** in the task's `spec.md`: `offline — n/a, the screen is online-only`. Silence does not count as non-applicability.

## Element states

For interactive elements: `default`, `hover` (pointer devices), `pressed`, `focused` (mandatory — `domain/accessibility.spec.md`), `disabled`, `loading` (if the action is async), `error` (if the element validates), `read-only` (if it differs from `disabled`).

`focused` is not `hover`. Without a visible focus state the interface cannot be traversed by keyboard.

## The coverage matrix

Filled into the task's `spec.md` — it doubles as the handoff checklist:

| Screen | empty | empty-filtered | loading | error | offline | success | data |
|---|---|---|---|---|---|---|---|
| Order list | ✅ | ✅ | ✅ | ✅ | n/a | — | ✅ |

Values: `✅` built, `n/a` not applicable with a reason, `—` not required for this screen type. An empty cell means the task is not ready.

## State copy

Every state is text, not just an illustration. Requirements live in `domain/ux-writing.spec.md`:

- **empty**: what will appear here and how to get it. Not "Nothing found".
- **error**: what happened and what to do. No error codes in the primary text, no "Something went wrong".
- **loading**: silent when fast; explanatory past three seconds.

## Transitions

States are joined by transitions, and transitions are designed too:

- `loading → error` — what flickers, what stays put
- `empty → data` after the first item is added
- `error → loading` on retry
- No layout jumps between states: the skeleton mirrors the geometry of the content.

## The states contract (Standard/Full)

The design equivalent of TDD — states are built **before** final polish:

| Step | What happens |
|---|---|
| **4a** | Fill the coverage matrix in `spec.md`. No empty cells. |
| **4b** | Build each marked state as its own frame per `core/naming.spec.md`. |
| **4c** | Verify: every `✅` in the matrix has a real frame in Figma. A mismatch is a FAIL. |

Polishing the `data` state before `empty` and `error` exist is the classic mistake that keeps them from ever appearing.

## Findings

| Code | Severity | When |
|---|---|---|
| `STATE_MISSING` | IMPORTANT | no `hover`/`pressed`; `empty-filtered` merged into `empty` |
| `STATE_MISSING` | CRITICAL | no `empty`, `loading`, or `error` without a reason; no `focused`; an empty matrix cell |
| `STATE` | IMPORTANT | layout jump between states; state copy that ignores `ux-writing` |

## Cross-refs

- domain/components.spec.md — component states
- domain/ux-writing.spec.md — state copy
- domain/accessibility.spec.md — focus
- workflows/handoff-quality.spec.md — handoff gates
