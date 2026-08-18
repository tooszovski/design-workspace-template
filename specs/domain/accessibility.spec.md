---
name: accessibility
layer: domain
purpose: WCAG checklist for a design — contrast, focus, touch targets, semantics, screen readers, motion
applies_to:
  task_keywords: ["accessibility", "a11y", "wcag", "contrast", "focus", "screen reader", "voiceover", "keyboard"]
  triggers: ["any task with interactive elements or text"]
owner: reviewer-a11y
---

# Accessibility

The baseline is WCAG `<WCAG_LEVEL>` (D-06). It is verified in the design, before engineering: half of all accessibility defects are born in Figma, not in code.

## Design checklist

### Perceivable

- [ ] Contrast of every text pair passes in **every** mode (`domain/color.spec.md`)
- [ ] Contrast of icons and borders that carry meaning is at least 3:1
- [ ] Meaning is **not** conveyed by color alone — an icon, text, or shape backs it up
- [ ] Informative images carry a text alternative in a `spec:alt` layer
- [ ] Decorative images are marked `spec:decorative` — screen readers skip them
- [ ] Text over an image stays readable for any variant of that image (or has a scrim)

### Operable

- [ ] Touch targets are at least 44×44pt; where the element looks smaller, the enlarged region is marked `spec:hit-area`
- [ ] Adjacent touch targets are separated by at least 8pt
- [ ] Every interactive element has a visible `focused` state with contrast of at least 3:1
- [ ] Focus order is set in the design via `spec:focus-order` for non-trivial layouts
- [ ] Everything is reachable by keyboard; modals contain no focus traps
- [ ] Gestures (swipe, long press, drag) have a plain button equivalent

### Understandable

- [ ] Every form field has a **visible** label; a placeholder is not a label
- [ ] Errors are described in text next to the field, not by border color alone
- [ ] Required fields are marked with text, not only an asterisk
- [ ] Input format is explained **before** the error, not after
- [ ] Interface language is consistent; abbreviations are expanded on first use

### Robust

- [ ] The layout survives font scaling to 200% (`domain/typography.spec.md`)
- [ ] The layout survives page zoom to 200% without horizontal scrolling
- [ ] Animations have a `prefers-reduced-motion` variant; nothing flashes more than three times per second
- [ ] Timeouts are extendable or absent

## Annotations for engineering

Design is responsible for making sure the engineer knows what to build. Add `spec:` layers:

| Layer | Contains |
|---|---|
| `spec:alt` | text alternative for an image |
| `spec:label` | accessible name when it differs from the visible text (icon button) |
| `spec:role` | element role when it is not obvious (`tab`, `dialog`, `alert`) |
| `spec:focus-order` | traversal order when it differs from the visual one |
| `spec:live` | a region whose changes a screen reader announces (cart counter, upload status) |
| `spec:hit-area` | the enlarged tap region |

An icon button without `spec:label` is CRITICAL: to a screen reader it is an unnamed button.

## Modals and overlays

- Focus moves inside on open and returns to the trigger on close
- There is an explicit close button — not only a backdrop click and Esc
- Content behind the overlay is non-interactive, and that reads visually

## Findings

| Code | Severity | When |
|---|---|---|
| `A11Y` | MINOR | unexpanded abbreviation; missing `spec:role` on an obvious element |
| `A11Y` | IMPORTANT | touch target between 32 and 44pt; missing `spec:focus-order` in a complex layout; a gesture with no alternative |
| `A11Y` | CRITICAL | no visible `focused`; icon button without `spec:label`; field without a visible label; body-text contrast below the bar; a focus trap |

Any CRITICAL `A11Y` is a Tier 2 hard stop (`workflows/decision-gates.spec.md`).

## Cross-refs

- domain/color.spec.md — contrast
- domain/states.spec.md — the focused state
- domain/typography.spec.md — dynamic type
- domain/layout.spec.md — touch targets, safe areas
- domain/handoff.spec.md — carrying annotations into engineering
