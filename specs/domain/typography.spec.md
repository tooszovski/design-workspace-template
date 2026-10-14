---
name: typography
layer: domain
purpose: Type scale, text styles, readability, line length, text growth under localization
applies_to:
  task_keywords: ["typography", "font", "text", "text style", "heading", "type size", "leading", "fonts", "headings", "text styles"]
  triggers: ["task introduces new text styles or changes text hierarchy"]
owner: reviewer-designsystem
---

# Typography

## The scale

Typography lives as **text styles** plus variables (`font/<group>/<size>`), never as manual values.

| Group | Purpose | Range |
|---|---|---|
| `display` | large promotional headlines | the biggest sizes |
| `heading` | page hierarchy: `xl` / `lg` / `md` / `sm` | — |
| `body` | main text: `lg` / `md` / `sm` | `md` is the base |
| `label` | control captions, buttons | — |
| `caption` | footnotes, metadata | the smallest permitted size |
| `code` | monospace | — |

The number of steps is limited: fourteen distinct sizes in a design means there is no hierarchy.

## Required style parameters

A style is incomplete without all four: **size, line height, weight, tracking**. Line height is set in percent or as a multiplier, never in fixed pixels — otherwise localization with diacritics clips glyphs.

Line-height guidance: headings 110–125%, body text 140–150%, caption 130–140%.

## Readability

| Parameter | Target |
|---|---|
| Body line length | 45–75 characters |
| Minimum UI text size | 12pt (`caption`); body text no smaller than 14pt |
| Body text alignment | left; justified is forbidden |
| All caps | short `label` only, never sentences |
| Hyphenation | no manual hyphens or `<br>` inside a paragraph |

## Hierarchy

At most three levels of textual importance are distinguishable on one screen at a time. Levels are separated by size **and** color (`text/primary` → `text/secondary`), not by weight alone.

One screen, one `heading/xl`. Two top-level headings is a hierarchy defect (D-10).

## Localization and text growth

The design must absorb text growth:

| Source → target | Headroom |
|---|---|
| en → de / fi / ru | +30–35% |
| en → ar / he | +20% plus mirrored layout |
| any → zh / ja | shorter text, taller line |

Check it on the tightest elements: buttons, tabs, chips, field labels. Ellipsis truncation is acceptable only where the full text is reachable another way (tooltip, detail screen).

## Dynamic type

If `<PLATFORMS>` includes mobile operating systems, the design accounts for system font scaling: at 200% the layout reflows vertically instead of clipping. A fixed-height text container is a defect.

## Findings

| Code | Severity | When |
|---|---|---|
| `TYPO` | MINOR | tracking unset; line length slightly out of range |
| `TYPO` | IMPORTANT | manual size instead of a text style; line height in pixels; more than three hierarchy levels on a screen |
| `TYPO` | CRITICAL | size below the minimum; fixed height on growing text; two `heading/xl` on one screen |

## Cross-refs

- domain/variables.spec.md — the Typography collection
- domain/layout.spec.md — behavior as content grows
- domain/ux-writing.spec.md — the text itself
- domain/accessibility.spec.md — dynamic type
