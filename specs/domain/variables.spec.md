---
name: variables
layer: domain
purpose: Figma variable collections, modes (themes, platforms, density), aliasing, no-hardcode rule
applies_to:
  task_keywords: ["variable", "token", "theme", "dark mode", "mode", "alias", "variables", "tokens", "themes", "modes"]
  triggers: ["task touches the color scheme, themes, or design-token values"]
owner: reviewer-designsystem
---

# Variables

## Collections

| Collection | Contains | Modes |
|---|---|---|
| `Primitives` | raw values: palette, numeric scale | single mode |
| `Semantic` | roles: `action/primary`, `text/secondary`, `surface/raised` | themes (light / dark / …) |
| `Spacing` | the `<SPACING_SCALE>` scale | density (comfortable / compact), if needed |
| `Radius` | corner radii | single mode |
| `Typography` | sizes, line heights, weights | platforms `<PLATFORMS>`, if they differ |

## Aliasing

The one-hop rule: **semantic references a primitive, a component references semantic.**

```
color/blue/500   (Primitives, hex)
      ↑
action/primary   (Semantic, alias)
      ↑
Button/Primary → fill = action/primary
```

Violations:

| Violation | Severity |
|---|---|
| Component references a primitive directly | IMPORTANT |
| Semantic holds a raw hex instead of an alias | IMPORTANT |
| Alias chain longer than two hops | MINOR |
| A layer with a raw value where a suitable variable exists | CRITICAL |

## Modes

A mode is an **axis of variation**, not "one more theme, just in case".

Rules:

1. Every variable in a collection must have a value in every mode. An empty value in a mode is CRITICAL: the screen breaks in that theme.
2. Modes are never added to `Primitives`. The palette is one; the roles are what change.
3. Adding a mode means re-checking **every contrast pair** of text against surface (`domain/accessibility.spec.md`). Dark theme is the most common point of failure.
4. Switching modes must not change sizes or layout. If dark theme reflows the page, the mode is being used for the wrong thing.

## Naming values

A semantic name states its role:

| ✅ | ❌ | Why |
|---|---|---|
| `text/danger` | `text/red` | in dark theme it is not red |
| `surface/raised` | `surface/white` | in dark theme it is not white |
| `action/primary` | `action/blue-500` | binding to the palette breaks rebranding |
| `space/stack-md` | `space/16` | the value changes, the role does not |

## Hardcoded values

A raw value is acceptable in exactly two cases:

1. The layer is marked `🚧` — an experiment that blocks handoff (D-03).
2. The value is genuinely not tokenizable (a coordinate inside an illustration, a gradient stop in a decorative background) — and a `spec:` layer next to it says so.

Everything else is a `DS_VIOLATION, severity CRITICAL`.

## Export

Variables are the source for `exports/tokens/` (`domain/tokens-export.spec.md`). Consequence: a variable's name will end up in code. Renaming one is a breaking change for token consumers and goes through `workflows/versioning.spec.md`.

## Cross-refs

- core/design-system.spec.md — DS levels
- core/naming.spec.md — name format
- domain/color.spec.md — palette and contrast
- domain/tokens-export.spec.md — export to code
- domain/accessibility.spec.md — contrast per mode
