# ACM-142 · Product catalog with filters

```yaml
task_id: ACM-142
epic_ref: EPIC-ACM-012
mode: standard
status: approved
figma_file: dEf456UvW
figma_nodes: ["1240:3310"]
ds_version: 2.3.0
surfaces: [Catalog]
platforms: [Web, iOS, Android]
attachments: [figma_link, reference]
```

## 1. The user problem

A shopper is looking for an item in a category holding 200+ products. Today the list has no filters: to find the right size at the right price they scroll through eight screens and leave.

## 2. Why the business cares

Catalog abandonment sits at 41% of sessions; filters should shorten the path to a product.

## 3. Scope

**In:**
- The catalog screen with a list and a filter panel
- Every list state
- Filter behavior: applying, clearing, the counter

**Out:**
- Text search — a separate task, ACM-149
- Sorting — exists already, unchanged
- The product card — untouched

## 4. Requirements

| # | Requirement |
|---|---|
| R1 | When the catalog opens with no filters, every product in the category is shown |
| R2 | When a filter is applied, the list updates without leaving the screen |
| R3 | When no product matches the filters, a state appears offering to clear them |
| R4 | When filters are applied, their count is visible on the filters button |
| R5 | When the user returns to the catalog from a product card, the filters are preserved |
| R6 | When the list is loading, a skeleton mirroring the card grid is shown |

## 5. Acceptance criteria

| # | Given | When | Then |
|---|---|---|---|
| AC1 | A catalog of 200 products | the user selects size M | the list shows only size M and the button counter reads 1 |
| AC2 | Three filters applied | the user taps "Clear" | all filters drop, the list is full, the counter disappears |
| AC3 | Filters yield zero results | the list renders | an explanation and a "Clear filters" button are visible |
| AC4 | The catalog is open | the network drops | an offline state appears with the cached list |
| AC5 | A filter is applied | the user opens a product and goes back | the filter is preserved and the scroll position is restored |

## 6. State coverage matrix

| Screen | empty | empty-filtered | loading | partial | error | offline | success | data |
|---|---|---|---|---|---|---|---|---|
| Catalog | ✅ | ✅ | ✅ | n/a | ✅ | ✅ | — | ✅ |
| Filter panel | — | — | ✅ | — | — | — | — | ✅ |

**Reasons:**
- `partial` — n/a: the list arrives as a single page, there is no partial delivery
- `success` — not required: applying a filter is not a completed action, so no confirmation is needed

## 7. Guardrails

- Do not change public Acme DS components — compose from what exists
- The filter panel is assembled from `Sheet/Bottom` and `Chip/Filter`; no new components
- Stay within the spacing scale 4, 8, 12, 16, 24, 32, 48, 64
- Do not touch sorting or the product card

## 8. Clarify

| # | Question | Default | Answer | Date |
|---|---|---|---|---|
| Q1 | Do filters apply instantly or behind a "Show" button? | instantly | instantly, confirmed | 2026-02-11 |
| Q2 | Do filters persist between sessions? | no, session only | yes, until end of day | 2026-02-11 |
| Q3 | Maximum simultaneous filters? | unlimited | unlimited | 2026-02-11 |

The answer to Q2 added requirement R5 — recorded in the worklog as DRIFT.

## 9. Adaptivity

| Breakpoint | What changes |
|---|---|
| ≥1280 | filters as a left side panel, 4-column grid |
| 768–1279 | filters as a side panel, 3-column grid |
| <768 | filters behind a button, opening in a bottom sheet, 2-column grid |

## 10. References

| What | Link |
|---|---|
| Requirements | Projects/AcmeShop/Requirements/catalog-filters.md |
| A comparable screen | Figma dEf456UvW · node 980:1120 (order list) |
| Android | Acme app 4.2, catalog screen |

## 11. Definition of Ready

- [x] The user problem is stated
- [x] Scope, including the "out" list, is filled in
- [x] Every AC is written and verifiable
- [x] Clarify is closed
- [x] The state matrix is marked up
- [x] The DS version is recorded: 2.3.0
- [x] Guardrails are listed

## 12. Definition of Done

The shared DoD is in `core/project.spec.md §2`. Addition for this task:

- [ ] Filter persistence is described in the handoff, with its lifetime stated
