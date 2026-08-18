---
name: assets
layer: domain
purpose: Icons, illustrations, images — formats, export, naming, optimization
applies_to:
  paths: ["exports/assets/**"]
  task_keywords: ["icon", "illustration", "image", "asset", "svg", "logo"]
  triggers: ["task adds or changes graphics"]
owner: figma-analyst
---

# Assets

## Icons

| Parameter | Rule |
|---|---|
| Source | a component from the library icon set, never a pasted SVG |
| Grid | a single `24×24` box (or the size fixed at init), with optical padding inside |
| Stroke weight | identical across the whole set |
| Color | inherited from text through a variable, never baked into the icon |
| Export format | SVG, outlined paths (not strokes), no `<style>`, no `id` |

An icon with a baked-in color will not survive a theme switch. An icon with strokes instead of outlines distorts when scaled.

Naming is `Icon/<size>/<Name>` in Figma and `icon-<name>@<scale>.<ext>` on export (`core/naming.spec.md`).

## Illustrations

- They live as a separate set, not in the icon set: different grid, different lifecycle.
- A per-theme variant is required whenever the illustration contains a background or dark linework.
- Format: SVG when the geometry is simple; PNG@2x/@3x or WebP when there are gradients and raster content.
- Each illustration in the design carries `spec:alt` or `spec:decorative` (`domain/accessibility.spec.md`).

## Raster images

| What | Rule |
|---|---|
| Aspect ratio | fixed; the crop is set in the design, not left to the implementation |
| Placeholder | required: what to show while loading and when the image is missing |
| Focal point | specified for images that crop differently across breakpoints |
| Weight | guidance: 200KB or less for a content image, 50KB or less for a thumbnail |

## Export

Output goes to `exports/assets/` and from there to engineering. Binaries are not committed to the workspace repository (`core/git-policy.spec.md`).

Rules:

- `kebab-case` only, ASCII only, no spaces and no non-Latin characters in filenames.
- Scales: `@1x`, `@2x`, `@3x` for mobile raster; for web, SVG or WebP with `srcset`.
- Run SVG through optimization: strip editor metadata, collapse groups, round coordinates to two decimals. Do not remove `viewBox` — scaling breaks without it.
- Export is reproducible: the same settings produce the same file. Hand-editing an exported file is forbidden; fix the source in Figma.

## Findings

| Code | Severity | When |
|---|---|---|
| `ASSET` | MINOR | unoptimized SVG; leftover metadata |
| `ASSET` | IMPORTANT | icon pasted as SVG instead of a component; no per-theme variant; filename off contract |
| `ASSET` | CRITICAL | color baked into an icon; no image placeholder; `viewBox` removed |

## Cross-refs

- core/naming.spec.md — filenames
- core/git-policy.spec.md — what not to commit
- domain/accessibility.spec.md — alt and decorative
- domain/states.spec.md — placeholders
