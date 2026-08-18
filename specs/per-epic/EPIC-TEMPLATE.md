---
name: epic-template
kind: template
purpose: Design epic — charter for a section or flow, breakdown into tasks, shared decisions
owner: design-lead
---

# EPIC-<PROJECT_PREFIX>-NNN · <Section name>

```yaml
epic_id: EPIC-<PROJECT_PREFIX>-NNN
status: draft | active | done
figma_file: <FIGMA_PRODUCT_FILE_KEY>
figma_page: <✅ Section>
ds_version: <version at epic start>
```

## What the section is for

What the section gives the user. One paragraph.

## Flow map

Screens in the order they are traversed, with branches marked:

```
Entry → List → Detail → Checkout → Confirmation
             ↘ Empty
             ↘ Load error
```

## Breakdown into tasks

| Task | Screen(s) | Mode | Depends on | Status |
|---|---|---|---|---|
| `<PROJECT_PREFIX>-NNN` | | standard | — | |

Granularity: one task is one screen with all its states, or one component. A task covering "the whole section" is unmanageable.

## Shared decisions

Decisions that apply to every screen in the epic. Each links to a DDR when it was contested.

| Decision | DDR |
|---|---|
| Navigation inside the section uses tabs, not a stack | DDR-004 |

## Shared components

| Component | In the DS | Task to create it |
|---|---|---|

Components are created **before** the screens that use them; otherwise the screens get rebuilt.

## Cross-cutting requirements

These apply to every task in the epic and are not repeated in each one:

- Every screen supports `<PLATFORMS>` at both ends of the range
- Every state per `domain/states.spec.md`
- WCAG `<WCAG_LEVEL>`
- Terms from the `domain/ux-writing.spec.md` glossary

## Out of scope

- <what sits outside the epic and where it goes instead>

## Risks

| Risk | Consequence | Mitigation |
|---|---|---|
