# Handoff · ACM-142 · Product catalog with filters

## Links

- Figma: `dEf456UvW` · section `Catalog` · node `1240:3310`
- Requirements: Projects/AcmeShop/Requirements/catalog-filters.md
- DDR: DDR-007 (filters in a bottom sheet)
- DS version: Acme DS **2.3.0**

## What we are building

A category catalog with filtering by size, color, and price. Filters apply instantly and the list updates without navigation.

## Components

| Element in the design | DS component | Properties | New? |
|---|---|---|---|
| Product card | `Card/Product` | `Size: md`, `Badge: false` | no |
| Filters button | `Button/Secondary` | `Size: md`, `Icon: true` | no |
| Button counter | `Badge/Count` | `Variant: danger` | no |
| Filter panel (mobile) | `Sheet/Bottom` | `Height: 80%` | no |
| Filter chip | `Chip/Filter` | `State: default / selected` | no |
| Card skeleton | `Skeleton/Card` | `Size: md` | no |

The task introduces no new components.

## States

| State | Frame | node |
|---|---|---|
| data | `ACM-142 · Catalog · data · {desktop,tablet,mobile}` | 1240:3310 / 3402 / 3510 |
| empty | `ACM-142 · Catalog · empty · mobile` | 1240:3620 |
| empty-filtered | `ACM-142 · Catalog · empty-filtered · mobile` | 1240:3688 |
| loading | `ACM-142 · Catalog · loading · {desktop,mobile}` | 1240:3740 / 3801 |
| error | `ACM-142 · Catalog · error · mobile` | 1240:3855 |
| offline | `ACM-142 · Catalog · offline · mobile` | 1240:3902 |

`partial` — not applicable: the list arrives as a single page.
`success` — not required: applying a filter is not a completed action.

## Adaptivity

| Breakpoint | What changes |
|---|---|
| ≥1280 | filters as a 280pt left side panel, 4-column grid, no filters button |
| 768–1279 | 240pt panel, 3-column grid. **Do not use 4 columns** — product names clip to two words |
| <768 | panel hidden, a "Filters" button with a counter appears, the panel opens in an 80%-height bottom sheet, 2-column grid |

Crossing 768 → 767: the side panel collapses and its contents move into the sheet with group order unchanged.

## Behavior

- A filter applies **immediately** on chip selection; there is no confirm button. The sheet has no "Apply".
- While a request is in flight the list shows a skeleton; already-selected chips stay active and tappable.
- Tapping a chip again during a request cancels the previous request and starts a new one. Requests do not queue.
- The counter on the "Filters" button shows the number of applied filters, not the number of selected values: size M plus size L is 1.
- "Clear filters" removes every filter and scrolls the list to the top.
- Filters persist **until the end of the calendar day** (per Q2), across sessions included. They reset after midnight.
- Returning from a product card restores both the filters and the scroll position.
- On network loss the offline state appears with the last cached list; filters are locked and chips render `disabled`.
- A failed request produces the error state with a "Retry" button. Retrying returns to loading.

## Data

| Field on screen | Source | Format | Behavior when absent |
|---|---|---|---|
| Product name | `product.title` | up to 2 lines, then ellipsis | never empty |
| Price | `product.price` | `1,299` with a currency symbol | hide the price block; the card remains |
| Image | `product.image` | 1:1, center crop | placeholder `illustration-no-photo.svg` |
| Sizes | `product.sizes[]` | a chip list | hide the sizes row |
| Item count | `meta.total` | number | show "Products" without a number |

## Copy

| Key | Text | Translation note |
|---|---|---|
| `catalog.filters.button` | Filters | button, 12 characters max |
| `catalog.filters.reset` | Clear filters | — |
| `catalog.filters.close` | Close | button in the sheet |
| `catalog.empty.title` | No products here yet | the category is empty |
| `catalog.empty.body` | Browse other categories — there is plenty to see | — |
| `catalog.emptyFiltered.title` | Nothing matched your filters | **not** "Nothing found" |
| `catalog.emptyFiltered.action` | Clear filters | duplicates the button; needed as a CTA inside the state |
| `catalog.error.title` | Couldn't load the catalog | no error code |
| `catalog.error.body` | Check your connection and try again | — |
| `catalog.error.action` | Retry | — |
| `catalog.offline.title` | No connection | — |
| `catalog.offline.body` | Showing products loaded earlier. Filters return when you're back online | — |

## Motion

| Element | Trigger | Property | From → To | Duration | Curve | Delay |
|---|---|---|---|---|---|---|
| Bottom sheet | tap "Filters" | translateY | 100% → 0 | 300ms | ease-out | 0 |
| Sheet scrim | same | opacity | 0 → 0.4 | 300ms | linear | 0 |
| Bottom sheet | close | translateY | 0 → 100% | 250ms | ease-in | 0 |
| Chip | select | background | `surface/base` → `action/primary` | 120ms | ease-out | 0 |

Under `prefers-reduced-motion` the sheet appears via a 150ms opacity fade with no translation.

## Accessibility

- Filters button: `spec:label` = "Filters, N applied"
- Sheet: `spec:role` = `dialog`; focus moves to the title on open and returns to the "Filters" button on close
- `spec:focus-order` inside the sheet: title → chip groups top to bottom → "Clear" → "Close"
- Chips: `focused` state is a 2pt `border/focus` ring at 3.2:1
- Item count: `spec:live` — announced when the list changes ("24 products found")
- Product images: `spec:alt` = the product name
- Image placeholder: `spec:decorative`
- Every chip is at least 44pt tall, with 8pt between neighbors

## Assets

| File | Format | Where |
|---|---|---|
| `illustration-no-photo.svg` | SVG, two theme variants | exports/assets/ |
| `illustration-empty-catalog.svg` | SVG, two theme variants | exports/assets/ |
| `icon-filter@2x` | from library `Icon/24/Filter` | not exported, taken from the DS |

## Open questions

None.
