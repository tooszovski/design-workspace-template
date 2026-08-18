---
name: layout
layer: domain
purpose: Auto-layout, grid, spacing scale, breakpoints, adaptivity, overflow behavior
applies_to:
  task_keywords: ["layout", "auto-layout", "grid", "spacing", "breakpoint", "responsive", "adaptive"]
  triggers: ["task concerns screen structure, adaptivity, or spacing"]
owner: reviewer-designsystem
---

# Layout

## Auto-layout by default

Every container is auto-layout. Absolute positioning is acceptable only for overlays (a badge on an avatar, a decorative element) and is marked deliberately.

Container requirements:

| Parameter | Rule |
|---|---|
| Direction | reflects the semantics of the flow, not what was convenient to build |
| Resizing | `Fill` / `Hug`; `Fixed` only under a physical constraint |
| Padding and gaps | from the `<SPACING_SCALE>` scale |
| Alignment | set explicitly, never inherited by accident |

A `Fixed`-width frame inside an adaptive screen is the single biggest cause of broken responsiveness.

## The spacing scale

Base `<SPACING_BASE>`, scale `<SPACING_SCALE>`. A value off the scale is a `DS_VIOLATION, severity IMPORTANT`.

Semantic roles for spacing:

| Role | What it separates |
|---|---|
| `space/inline-*` | elements in a row (icon and text) |
| `space/stack-*` | elements in a column (form fields) |
| `space/inset-*` | a container's internal padding |
| `space/section-*` | meaningful blocks of a screen |

**The proximity law:** the distance between related elements is always smaller than the distance to the neighboring group. Equal spacing everywhere is visual noise in which structure cannot be read.

## Grid and breakpoints

Breakpoints are determined by the `<PLATFORMS>` set. For each one, record column width, column count, gutter, and margins.

Rules:

1. A breakpoint is added when the **content breaks**, not to match a specific device model.
2. Every screen carries the smallest and largest breakpoint in the design (D-08). Intermediate ones only when the layout changes qualitatively.
3. The content column has a maximum width — text spanning a full monitor is unreadable (`domain/typography.spec.md`).
4. The transition between breakpoints is described in words in the handoff: what collapses, what moves, what disappears.

## Overflow and edge cases

For each block, the design answers what happens when:

| Case | What to show |
|---|---|
| Zero items | an empty state (`domain/states.spec.md`) |
| One item | it must not look broken |
| Very many items | scroll, pagination, or virtualization — pick one and say so |
| Very long text | wrap or truncate — pick one and say so |
| Very short text | the container does not collapse below its minimum |
| Missing image | a placeholder, not an empty hole |

No answer means a defect in the spec, not "obviously".

## Safe areas and touch

- System zones are respected: notches, home indicator, status bar, keyboard.
- Interactive elements sit no closer than 8pt to a screen edge.
- Minimum touch target is 44×44pt, even when the element looks smaller (`domain/accessibility.spec.md`).

## Findings

| Code | Severity | When |
|---|---|---|
| `LAYOUT` | MINOR | a redundant nested container with no role |
| `LAYOUT` | IMPORTANT | spacing off the scale; the proximity law broken; `Fixed` where `Fill` belongs |
| `LAYOUT` | CRITICAL | a required breakpoint missing; an element under a system zone; no answer for overflow |

## Cross-refs

- domain/variables.spec.md — the Spacing collection
- domain/states.spec.md — empty and overflowing states
- domain/accessibility.spec.md — touch targets and safe areas
- domain/handoff.spec.md — describing adaptivity for engineering
