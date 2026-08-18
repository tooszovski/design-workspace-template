# EPIC-ACM-012 · Catalog and search

```yaml
epic_id: EPIC-ACM-012
status: active
figma_file: dEf456UvW
figma_page: "✅ Catalog"
ds_version: 2.3.0
```

## What the section is for

A shopper should find the product they want inside a category of 200+ items in under a minute. Today the catalog is a flat list with no filters and no search: 41% of sessions end on it.

## Flow map

```
Home → Category → Catalog ──→ Product card → Cart
                     │
                     ├─→ Filters (sheet / panel)
                     ├─→ Search within the category
                     └─→ Empty / Error / Offline
```

## Breakdown into tasks

| Task | Screen(s) | Mode | Depends on | Status |
|---|---|---|---|---|
| ACM-140 | `Chip/Filter` component | standard | — | done |
| ACM-141 | `Sheet/Bottom` — 80% variant | quick | — | done |
| ACM-142 | Catalog with filters | standard | ACM-140, ACM-141 | done |
| ACM-149 | Search within a category | standard | ACM-142 | in progress |
| ACM-152 | Empty category and error states | quick | ACM-142 | todo |
| ACM-158 | Align Android with the shared filter pattern | standard | ACM-142 | todo |

Components (ACM-140, ACM-141) come **before** the screens that use them.

## Shared decisions

| Decision | DDR |
|---|---|
| Filters on mobile are a bottom sheet, not a separate screen | DDR-007 |
| Filters apply instantly, with no confirm button | DDR-008 |
| Filter state lives until the end of the calendar day | DDR-008 |
| Grid: 4 / 3 / 2 columns across breakpoints | — (follows from the scale) |

## Shared components

| Component | In the DS | Task to create it |
|---|---|---|
| `Chip/Filter` | added in 2.3.0 | ACM-140 |
| `Sheet/Bottom` 80% variant | added in 2.3.0 | ACM-141 |
| `Card/Product` | already existed | — |
| `Skeleton/Card` | already existed | — |

## Cross-cutting requirements

These apply to every task in the epic and are not repeated in each one:

- Web / iOS / Android breakpoints at both ends of the range
- Every state per `domain/states.spec.md`; lists require `empty`, `empty-filtered`, `loading`, `error`, `offline`
- WCAG AA
- Glossary terms: "product", "category", "filter" — not "item", "section", "refinement"
- A skeleton, never a spinner, for any list load

## Out of scope

- Global search across the whole store — a separate epic, EPIC-ACM-020
- Personalized recommendations in the catalog — not this quarter
- Changes to the product card

## Risks

| Risk | Consequence | Mitigation |
|---|---|---|
| Filter count grows past 8 | the bottom sheet gets cramped and DDR-007 needs revisiting | recorded in DDR-007 as the revisit condition |
| Categories with 1000+ products | grid and scroll behavior unverified | ACM-152 includes a check against synthetic data |
| Android falls behind web on the pattern | inconsistent experience across platforms | ACM-158 sits in the same epic and is not deferred |
