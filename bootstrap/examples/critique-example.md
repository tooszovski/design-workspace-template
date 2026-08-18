# Critique · ACM-142 · 2026-02-13

Reviewers: `reviewer-designsystem`, `reviewer-a11y`, `reviewer-ux-copy` (in parallel) plus `design-lead` critique.
Duplicates removed: two reviewers caught the chip contrast; one finding kept.

## CRITICAL

### COPY: the empty-filtered copy dead-ends
Where: `ACM-142 · Catalog · empty-filtered · mobile` · `state:empty-filtered / title`
Current: "Nothing found"
Proposed: "Nothing matched your filters" plus a "Clear filters" button
Why: the user sees an empty screen and cannot tell that the filter is responsible rather than an empty category. There is no way out of this state except going back.

## IMPORTANT

### A11Y: focus order in the bottom sheet is undefined
Where: `ACM-142 · Catalog · data · mobile` · `filters-sheet`
Why: when the sheet opens, focus stays on the button behind the scrim, so a keyboard user falls through into an unreachable list
Proposal: add `spec:focus-order` — sheet title → chips by group → "Clear" → "Close"; on close, focus returns to the filters button

### DS_VIOLATION: the filters button counter references a primitive
Where: `filters-button / badge`
Why: it uses `color/red/500` instead of `status/danger`; when the palette changes the badge will stay behind, and nobody will notice for a while
Proposal: switch to `status/danger`

### LAYOUT: spacing between filter groups is off the scale
Where: `filters-sheet / groups` · gap 20
Why: 20 is not in the scale 4, 8, 12, 16, 24, 32, 48, 64 — it becomes a magic number in code
Proposal: 24

### COPY: an "Apply" button in a sheet that applies instantly
Where: `filters-sheet / actions`
Why: filters apply immediately (Q1), so the button promises an action that does not exist and the user waits for a result after tapping it
Proposal: change it to "Close", or drop it and keep only "Clear"

## MINOR

### TYPO: tracking is unset on `label/sm` in the chips
Where: `Chip/Filter` — a design-system question, not a screen one
Proposal: file a DS task; do not fix it inside ACM-142

### NAMING: `Frame 88` in the skeleton
Where: `ACM-142 · Catalog · loading · desktop`
Proposal: `skeleton-card`

## Ideas (non-blocking)

- Show the item count next to each chip ("Size M · 24") — it heads off some empty results before they happen. Needs data before the filter is applied; discuss with product separately.
- Animate the grid reflow when a filter changes. Not required: the current instant swap reads fine.

## Summary

1 critical, 4 important, 2 minor. Blocks handoff: **yes** (the critical).

Author's responses: the critical is accepted and fixed. Three importants accepted. The `LAYOUT` finding about 3 columns at 768–1279 is rejected with a reason: four columns clip product names to two words — recorded in the worklog.
