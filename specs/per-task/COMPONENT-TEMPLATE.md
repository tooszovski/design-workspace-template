---
name: component-template
kind: template
purpose: Design-system component spec — API, anatomy, states, usage rules
owner: reviewer-designsystem
---

# <Category>/<Name>

```yaml
component: <Category>/<Name>
status: draft | review | published | deprecated
version_added: <MAJOR.MINOR.PATCH>
replaces: <component or ->
figma_node: <node-id in FIGMA_DS_FILE_KEY>
```

## Purpose

One sentence: which problem it solves.

## When to use it

- <scenario>

## When NOT to use it

- <scenario> → use `<other component>` instead

This section matters more than the previous one: without it, people start using the component everywhere.

## Anatomy

| Part | Required | Token / component |
|---|---|---|
| container | yes | `surface/raised`, `radius/md`, `space/inset-md` |
| icon | no | `Icon/24/*`, color inherits from text |
| title | yes | `font/label/md`, `text/primary` |

## API

### Variants

| Property | Values | Default | Purpose |
|---|---|---|---|
| `Variant` | primary / secondary / danger | primary | visual weight of the action |
| `Size` | sm / md / lg | md | density of the context |
| `State` | default / hover / pressed / focused / disabled | default | — |

### Boolean

| Property | Default | What it shows |
|---|---|---|

### Slots

| Property | Type | What goes in |
|---|---|---|
| `label` | text | the action text |
| `icon` | instance swap | an icon from `Icon/24/*` |

Total combinations: `<N>`. Past forty, split the component (`domain/components.spec.md`).

## States

| State | Difference | Tokens |
|---|---|---|
| default | — | `action/primary` |
| hover | darker fill | `action/primary-hover` |
| pressed | darker fill plus 98% scale | `action/primary-hover` |
| focused | 2pt outer ring | `border/focus`, contrast ≥3:1 |
| disabled | reduced saturation, cursor unchanged | `action/disabled`, `text/disabled` |

`focused` is mandatory (`domain/accessibility.spec.md`).

## Behavior

- Minimum and maximum width
- Long text: wrap or truncate
- Behavior when a slot is empty
- Touch target ≥44×44pt even at `Size: sm`

## Adaptivity

| Breakpoint | Behavior |
|---|---|

## Accessibility

- Role: `<button / link / ...>`
- Accessible name: from `label`; when there is no text, `spec:label` is required
- Focus order: <rule>
- Contrast: verified in every mode

## Promotion checklist

- [ ] Used on 2+ screens
- [ ] Every value on variables
- [ ] Every state built, including `focused` and `disabled`
- [ ] Properties named per `core/naming.spec.md`
- [ ] Contrast verified in every mode
- [ ] "When to use / when not to" description written
- [ ] Combination count ≤40
- [ ] Entered in the changelog (`workflows/versioning.spec.md`)
