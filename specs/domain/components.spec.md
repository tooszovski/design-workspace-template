---
name: components
layer: domain
purpose: Component anatomy, variants and properties, slots, composition, promotion to the library
applies_to:
  task_keywords: ["component", "variant", "instance", "library", "detach", "slot"]
  triggers: ["task creates or changes a design-system component"]
owner: reviewer-designsystem
---

# Components

## Anatomy

A component consists of:

| Part | Rule |
|---|---|
| **Container** | always auto-layout; a fixed size only where the constraint is physical (icon, avatar) |
| **Slots** | regions the consumer swaps: instance-swap or text properties |
| **Tokens** | every visual value through variables (`domain/variables.spec.md`) |
| **Properties** | the component's external API |
| **Description** | one line: when to use it and when **not** to |

## Properties as an API

A property is a public contract. Renaming one breaks consumers (D-11).

**Rules:**

- A property exists only when it has 2+ real uses. A property added "for later" is clutter.
- Boolean for showing or hiding a part; variant for mutually exclusive visual states.
- The number of variants is the product of property values. Past forty combinations, the component is doing too much: split it.
- Property order is identical across components: `Variant` → `Size` → `State` → boolean flags → text/instance slots.

**Required `State` values** for interactive components: `default`, `hover`, `pressed`, `focused`, `disabled`. A missing `focused` is an accessibility defect, not a simplification (`domain/accessibility.spec.md`).

## Composition over configuration

When a new scenario seems to need a fifth boolean property, check whether composition solves it first:

| Bad | Good |
|---|---|
| `Card` with `hasImage`, `hasBadge`, `hasFooter`, `hasAction` | `Card` with `media`, `content`, `actions` slots |

A slot through an instance-swap property is more flexible than a pile of boolean flags and does not multiply variants.

## Instances

- Customization happens **through properties only**. Editing internal layers of an instance is a violation, even where Figma permits it.
- Detaching is acceptable in exactly one case: deliberately deriving a new component from an existing one, with a task filed immediately to add it to the library.
- Nested instances: depth of 3 or less. Deeper than that and the component cannot be debugged.

## Promotion to the library

A local component (`🚧 <Name>`) moves into `<DS_LIBRARY_NAME>` once:

- [ ] It is used on 2+ screens (D-04)
- [ ] Every value is on variables, none hardcoded
- [ ] Every state is built, including `focused` and `disabled`
- [ ] Properties are named per `core/naming.spec.md`
- [ ] `per-task/COMPONENT-TEMPLATE.md` is filled in
- [ ] Contrast is verified in every theme (`domain/variables.spec.md`, modes section)
- [ ] The description states when to use it and when not to

## Findings

| Code | Severity | When |
|---|---|---|
| `DS_VIOLATION` | MINOR | nested instance depth above 3; a property with no second use |
| `DS_VIOLATION` | IMPORTANT | edited internal layers of an instance; inconsistent property name; missing `focused` |
| `DS_VIOLATION` | CRITICAL | detached instance of a library component; local copy of something the DS already has; use of a deprecated component |

## Cross-refs

- core/design-system.spec.md — levels and library changes
- core/naming.spec.md — component and property names
- domain/variables.spec.md — tokens inside a component
- domain/states.spec.md — required states
- per-task/COMPONENT-TEMPLATE.md — the spec
