# DDR-007 · Filters in a bottom sheet on mobile, not a separate screen

```yaml
ddr_id: DDR-007
task_ref: ACM-142
status: accepted
supersedes: -
date: 2026-02-12
```

## Context

At the mobile breakpoint the filter panel does not fit alongside the list. We need to decide where it goes.

Constraints in force at the time:

- Acme DS has `Sheet/Bottom`; there is no full-screen container with a header, so we would have to build one.
- Engineering asked us not to add screens to the navigation: that pulls in routing and state restoration.
- In the Acme 4.2 Android app filters are a separate screen, and support tickets say users lose track of the list.

## Options

### A — Bottom sheet over the list
The panel slides up to 80% height; the list stays visible behind the scrim.
**Pros:** the list stays in view, the component already exists, navigation is untouched, and the result is visible the moment a filter is applied.
**Cons:** with many filters the sheet gains its own scroll; on short screens there is little room.

### B — A separate filters screen
Navigate to a full-screen page, apply with a button, return to the list.
**Pros:** plenty of room, familiar from the Android app.
**Cons:** needs a new container component, a new route, and state restoration on return; it repeats exactly what support tickets complain about.

### C — Leave it, filters on desktop only
**Pros:** zero cost.
**Cons:** 70% of traffic is mobile — the problem goes unsolved.

## Decision

**A — the bottom sheet** was chosen.

What tipped it was the link between action and result: the user watches the list change under the filter and never loses context. Losing context is precisely what people complain about in the Android app, which implements option B. Saving a new component and a new route is a welcome bonus, but not the deciding argument.

## Consequences

**Good:**
- No new component and no new route
- Filtering results are visible instantly, which closes the support complaints
- The pattern matches the existing sorting control, which is also a sheet

**Bad:**
- Once filters grow past eight, the sheet gets cramped; we will need grouping or a move to option B
- On screens shorter than 640pt the sheet covers almost everything — the list behind it is barely visible and the advantage partly evaporates

**Affected consumers:**

| Screen / component | What needs doing | Task |
|---|---|---|
| `Sheet/Bottom` | nothing, used as-is | — |
| Android app catalog | align with the shared pattern | ACM-158 |

## When to revisit

If a category exceeds eight filters, or nested filtering appears (a filter inside a filter), option A stops working and we return to B with a new component.
