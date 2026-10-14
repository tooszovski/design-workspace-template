---
name: color
layer: domain
purpose: Palette, semantic color roles, contrast, dark theme, status colors
applies_to:
  task_keywords: ["color", "palette", "contrast", "dark theme", "gradient", "opacity", "colors"]
  triggers: ["task changes a screen's color treatment or adds colors to the system"]
owner: reviewer-designsystem
---

# Color

## Palette structure

Each color ramp is a scale with steps fine enough to build contrast pairs:

```
color/<hue>/50 100 200 300 400 500 600 700 800 900
```

`500` is the ramp's base tone. A ramp that does not cover both the light and the dark end is unusable for dark theme.

## Semantic roles

The minimum set of roles that must exist:

| Group | Roles |
|---|---|
| `text/` | `primary`, `secondary`, `tertiary`, `disabled`, `inverse`, `danger`, `success` |
| `surface/` | `base`, `raised`, `sunken`, `overlay`, `inverse` |
| `border/` | `default`, `subtle`, `strong`, `focus` |
| `action/` | `primary`, `primary-hover`, `secondary`, `danger`, `disabled` |
| `status/` | `info`, `success`, `warning`, `danger` (plus `-surface` for badge backgrounds) |

Roles without a matching text-on-surface partner are useless: every `status/X` needs a `status/X-surface` on which `status/X` passes contrast.

## Contrast

The floor is WCAG `<WCAG_LEVEL>`:

| What | AA | AAA |
|---|---|---|
| Body text (<18pt / <14pt bold) | 4.5:1 | 7:1 |
| Large text (≥18pt / ≥14pt bold) | 3:1 | 4.5:1 |
| Icons and borders that carry meaning | 3:1 | 3:1 |
| Focus indicator | 3:1 against the adjacent color | 3:1 |

**Every real pair** is checked, in **every mode** — not just body text on the main background. The usual misses: a field placeholder, disabled text on a button, text over an image, an icon on a colored badge, a field border.

`disabled` is not exempt from contrast: the user still has to see that the element exists.

## Color is never the only carrier of meaning

Status, error, and selection must also be conveyed by an icon, text, or shape. "The field is red" is invisible to a color-blind user — it needs an icon and error text (`domain/accessibility.spec.md`).

## Dark theme

- Dark theme is not an inversion. Surfaces separate by lightness (`surface/base` → `surface/raised` gets lighter, not darker), and shadows give way to lit borders.
- Saturated colors from light theme vibrate on dark backgrounds — use the muted step of the ramp (`400` instead of `600`).
- Images and illustrations are checked separately: a PNG with a white background is a defect in dark theme.

## Gradients and opacity

- A gradient is a tokenized effect or a variable, not a hand-rolled fill.
- Semi-transparent color over an unknown background is forbidden for text: contrast becomes unpredictable. Opacity is fine for overlays and dividers.

## Findings

| Code | Severity | When |
|---|---|---|
| `A11Y_CONTRAST` | IMPORTANT | a pair below the bar for large text or borders |
| `A11Y_CONTRAST` | CRITICAL | body text below the bar; a pair that fails in one of the modes |
| `DS_VIOLATION` | CRITICAL | raw hex instead of a semantic role |
| `A11Y` | IMPORTANT | meaning conveyed by color alone |

## Cross-refs

- domain/variables.spec.md — collections and modes
- domain/accessibility.spec.md — the full a11y checklist
- domain/states.spec.md — state colors
