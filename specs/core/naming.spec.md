---
name: naming
layer: core
purpose: Naming contract for pages, frames, layers, components, variables, and export files
always_loaded: true
owner: design-lead
---

# Naming

Naming is the API of a design. A name should tell you what something is without opening it.

## General rules

- Names are **English** for anything that reaches code: components, variables, styles, exported assets. `<DEV_LANGUAGE>` is allowed only in content text layers and in page or section titles.
- Case: `PascalCase` for components, `kebab-case` for variables and files, `Sentence case` for pages and sections.
- No `Frame 427`, `Group 12`, `Rectangle 3`, `Copy of ...`, `Component 1`. An auto-generated name is technical debt.
- No dates or initials in layer names — history lives in Figma version history, not in naming.

## File pages

```
📐 Cover
🚧 WIP
✅ <Section>
📦 Components        (design-system file only)
🎨 Foundations       (design-system file only)
🗃 Archive
```

The emoji prefix carries page status and is read by the agent during audits (`domain/figma-structure.spec.md`).

## Screen frames

```
<PROJECT_PREFIX>-<number> · <Screen> · <State> · <Breakpoint>
```

Examples:

- `<PROJECT_PREFIX>-142 · Checkout · default · desktop`
- `<PROJECT_PREFIX>-142 · Checkout · empty-cart · mobile`
- `<PROJECT_PREFIX>-142 · Checkout · error-payment · mobile`

The separator is ` · ` (space, middle dot, space). The agent parses it, so do not substitute a hyphen or a slash.

## Layers inside a frame

A name describes the **role**, not the appearance:

| ✅ | ❌ |
|---|---|
| `header` | `Frame 12` |
| `price-total` | `Text bold 24` |
| `divider` | `Line 3` |
| `state:empty` | `Group 8 copy` |

Reserved prefixes:

| Prefix | Meaning |
|---|---|
| `state:` | a state layer, shown mutually exclusively (`state:loading`) |
| `spec:` | an annotation for engineering; not part of the UI, never exported |
| `🚧` | an experiment or unresolved decision; blocks handoff |
| `_` | a helper layer (mask, guide); ignored by audits |

## Components

```
<Category>/<Name>
<Category>/<Name>/<Subcomponent>
```

Examples: `Button/Primary`, `Input/Text`, `Card/Product`, `Navigation/Tab Bar`, `Icon/24/Chevron Right`.

Variant properties use `Title Case` with predictable values:

| Property | Values |
|---|---|
| `Size` | `sm` / `md` / `lg` |
| `State` | `default` / `hover` / `pressed` / `focused` / `disabled` |
| `Variant` | `primary` / `secondary` / `tertiary` / `danger` |
| `Icon` | boolean |

The same property is named identically across components. `State` in one place and `Status` in another is a DS_VIOLATION.

## Variables

```
<collection>/<group>/<role>[/<modifier>]
```

| Type | Example |
|---|---|
| primitive color | `color/blue/500` |
| semantic color | `action/primary`, `text/secondary`, `surface/raised` |
| spacing | `space/xs`, `space/inline-sm`, `space/stack-lg` |
| radius | `radius/sm`, `radius/pill` |
| typography | `font/body/md`, `font/heading/lg` |

A semantic name states **purpose**, not appearance: `text/danger`, not `text/red`.

## Asset exports

```
<category>-<name>[-<variant>]@<scale>.<ext>
```

Examples: `icon-chevron-right@2x.png`, `illustration-empty-cart.svg`, `logo-primary-dark.svg`.

`kebab-case` only, ASCII only, no spaces. Full rules in `domain/assets.spec.md`.

## Verification

`/design.audit` checks naming and emits `NAMING` findings:

| Severity | When |
|---|---|
| MINOR | auto-generated name on a helper layer |
| IMPORTANT | auto-generated name on a meaningful layer; inconsistent variant property |
| CRITICAL | a `🚧` layer inside a frame marked ready for handoff |

## Cross-refs

- domain/figma-structure.spec.md — pages and sections
- domain/components.spec.md — component anatomy
- domain/variables.spec.md — collections
- domain/assets.spec.md — exports
