---
name: versioning
layer: workflow
purpose: Design-system versions, changelog, change classification, deprecation, consumer migration
applies_to:
  task_keywords: ["version", "changelog", "library release", "publish", "deprecation", "migration", "breaking"]
  loaded_for_modes: ["full"]
owner: design-lead
---

# Design System Versioning

`<DS_LIBRARY_NAME>` is versioned like an API, because that is what it is.

## Version scheme

```
MAJOR.MINOR.PATCH
```

| Part | When it increments | Examples |
|---|---|---|
| **MAJOR** | breaking change | a component removed, a property renamed, a variable deleted, a role's semantics changed |
| **MINOR** | additive | a new component, a new variant, a new optional property, a new variable |
| **PATCH** | fix | corrected contrast, adjusted spacing inside a component, clarified description |

Changing a default value is MAJOR, not PATCH: it silently alters every existing instance.

## Classifying a change

Before publishing, every change lands in one of three categories:

| Category | What it requires |
|---|---|
| additive | a changelog line |
| modifying | changelog plus the list of affected screens plus notice to engineering |
| breaking | DDR plus deprecation period plus migration note plus sign-off from engineering |

The category follows from the consequence for consumers, not from the amount of work. Nudging one pixel in a button's default is modifying.

## Changelog

Lives in `<PER_TASK_SPEC_LOCATION>/../DS-CHANGELOG.md` (or in the vault next to Specs). Format:

```markdown
## 2.3.0 — 2026-03-14

### Added
- `Card/Product` — `compact` variant for narrow breakpoints

### Changed
- `Button/Primary` — `md` height 40→44pt to meet the touch-target floor (modifying, affects: Checkout, Profile)

### Deprecated
- `Input/Legacy` — use `Input/Text`; removal in 3.0.0

### Removed
- —

### Fixed
- `status/warning-surface` — contrast 3.9:1 → 4.6:1
```

Empty sections stay: their absence reads as "we forgot", not as "there were none".

## Deprecation

| Step | Action |
|---|---|
| 1 | Mark the component `[deprecated] <Name>` in its description and name the replacement |
| 2 | Record it in the changelog with the removal version |
| 3 | List the consumers and file migration tasks |
| 4 | Wait for migration; remove in the next MAJOR |

A deprecated component in a new design is a `DS_VIOLATION, severity CRITICAL`.

A component is never removed in the same release that deprecates it, even with zero consumers: tokens and code follow their own update cycle.

## Publishing

The agent prepares it; a human presses the button (D-02). The publication package:

- [ ] The version is derived from the scheme above
- [ ] The changelog is written
- [ ] Every breaking change has a DDR
- [ ] The consumer list is compiled
- [ ] The token export is rerun **after** publication (`domain/tokens-export.spec.md`)
- [ ] Engineering is notified when the category is anything other than additive

## The version in the product file

The current consumed version sits on the product file's `📐 Cover`. A task begins by checking it: working against an outdated version is acceptable only when recorded in `spec.md`.

## Cross-refs

- core/design-system.spec.md — rules for changing the library
- domain/components.spec.md — properties as an API
- domain/tokens-export.spec.md — token synchronization
- per-task/DDR-TEMPLATE.md — recording breaking decisions
