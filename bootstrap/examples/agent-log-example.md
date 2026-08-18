# Agent Log · ACM-142

## Outcome

Designed a product catalog with filtering: six states across three breakpoints, with the filter panel as a bottom sheet on mobile and a side panel on wide screens. No new design-system components were needed — everything composes from `Card/Product`, `Sheet/Bottom`, and `Chip/Filter`. One architectural decision went into DDR-007. The task took three days against a two-day estimate; a full day went to waiting on the answer about filter persistence between sessions.

## Artifacts

| What | Where |
|---|---|
| Design | Figma `dEf456UvW` · Catalog section · node 1240:3310 |
| Spec | Projects/AcmeShop/Tasks/ACM-142/spec.md |
| DDR | Projects/AcmeShop/Tasks/ACM-142/ddr-007.md |
| Critique | Projects/AcmeShop/Tasks/ACM-142/critique.md |
| Handoff | Projects/AcmeShop/Tasks/ACM-142/handoff.md |
| Worklog | Projects/AcmeShop/Tasks/ACM-142/worklog.md |

## Decisions

| Decision | Why | Tier |
|---|---|---|
| Filters in a bottom sheet, not a separate screen | keeps the list in context; support complaints about the Android variant | 2 (DDR-007) |
| Panel composed from existing components | Acme DS 2.3.0 had everything needed | 1 |
| 3 columns at 768–1279, not 4 | at 4 columns product names clip to two words | 1 |
| Skeleton instead of a spinner | otherwise the layout jumps while loading | 1 |

## Findings

| Severity | Found | Closed | Remaining |
|---|---|---|---|
| CRITICAL | 3 | 3 | 0 |
| IMPORTANT | 7 | 6 | 1 |
| MINOR | 3 | 1 | 2 |

Two of the three CRITICALs were caught by `/design.audit` before the reviewers ran (chips missing focused, secondary text contrast in dark theme); the third came from the copy reviewer (the empty-filtered dead end).

## Debt

- **IMPORTANT, justified:** 3 columns instead of 4 at the middle breakpoint — a deliberate trade-off for name readability, recorded in the worklog.
- **MINOR, deferred:** tracking is unset on `label/sm` in `Chip/Filter`. That is a design-system defect rather than a screen defect — filed as ACM-161 against the DS.
- **MINOR, deferred:** behavior above 1000 products was never verified anywhere in the catalog — current categories top out at 240. It will surface when the assortment grows.

## What the specs should fix

1. **`domain/states.spec.md` says nothing about filters while offline.** I had to decide it myself (lock the chips). The same question will come up on any screen with a list and a filter — worth adding a line about interactive elements in offline states.

2. **`workflows/clarify.spec.md` does not cover an answer arriving a day later.** The default held, but the Q2 answer diverged from it and some work had to be redone. It may be worth distinguishing questions whose default is cheap to reverse from those where it is not, and making the latter blocking.

3. **`domain/handoff.spec.md` does not require stating the lifetime of persisted state.** Writing "filters persist" without "until end of day" would have produced a question from engineering. I added it by hand, but no rule demanded it.
