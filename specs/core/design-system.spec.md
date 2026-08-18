---
name: design-system
layer: core
purpose: Design-system hierarchy, what counts as canonical, rules for consuming and changing the library
always_loaded: true
owner: design-lead
---

# Design System

`<DS_LIBRARY_NAME>` is the library in Figma file `<FIGMA_DS_FILE_KEY>`. Product files **consume** it; they never fork it.

## Hierarchy of levels

```
Primitives    →  Semantic       →  Component        →  Pattern         →  Screen
raw values       role in the UI     reusable            composition       concrete
color/gray/900   text/secondary     Button, Field       FormRow, Card     product screen
space/4          space/inline-sm
```

The flow rule: **a level references downward only — never sideways out of its lane, never upward.**

| Level | Who uses it | Who must not |
|---|---|---|
| Primitives | Semantic only | components and screens — never directly |
| Semantic | components, screens | — |
| Component | patterns, screens | — |
| Pattern | screens | — |

A screen referencing a primitive directly (`color/blue/500` instead of `action/primary`) is a **DS_VIOLATION, severity IMPORTANT**.

## What counts as canonical

| Artifact | Canonical | Not canonical |
|---|---|---|
| Color | a variable in the `Color` collection | a hex fill on a layer |
| Spacing | a value from the `<SPACING_SCALE>` scale | an arbitrary number in auto-layout |
| Text | a library text style | a manual size or weight |
| Component | a published library component | a detached instance, a local copy |
| Icon | a component from the library icon set | a pasted SVG |
| Effect | an effect style | a hand-rolled shadow |

## Consuming the library

1. The product file links `<DS_LIBRARY_NAME>` as an external library and updates to the current published version before the task starts.
2. Working against an outdated version is acceptable only when that is a deliberate, recorded choice in the task's `spec.md`, with the version named.
3. An instance is customized **only through published properties** (variants, boolean/text/instance props). Editing an instance's internals amounts to a detach in spirit, even when Figma does not formally detach the layer.

## Changing the library

Changing a public component is a breaking change (D-11). The order is:

1. **DDR** — record the problem, the options, the choice (`per-task/DDR-TEMPLATE.md`).
2. **Blast radius** — find every consumer of the component across product files and list them in the DDR.
3. **Classification:**
   | Type | Example | Requirement |
   |---|---|---|
   | additive | a new variant, a new optional property | changelog |
   | modifying | changed default, sizes, behavior | changelog plus notice to consumers |
   | breaking | removed variant, renamed property, removed component | DDR plus deprecation period plus migration note |
4. **Version and changelog** — `workflows/versioning.spec.md`.
5. **A human publishes.** The agent prepares the DDR, the changelog, and the consumer list; a human presses Publish (D-02).

## Deprecation

A component is never deleted outright. The order: mark it `[deprecated] <Name>` in the description → name the replacement → wait for consumers to migrate → delete in the next major version. A deprecated component must not appear in new designs; doing so is a DS_VIOLATION.

## When the component does not exist yet

If a task needs a pattern that `<DS_LIBRARY_NAME>` does not have:

1. Check whether composing existing components solves it (it does about eighty percent of the time).
2. If not, build a **local** component in the product file, mark it `🚧 <Name>`, and file a task to promote it to the library.
3. A local component that shows up on 2+ screens must be promoted (D-04).

## Cross-refs

- domain/components.spec.md — anatomy and rules of the component itself
- domain/variables.spec.md — collections, modes, aliases
- workflows/versioning.spec.md — versions and changelog
- per-task/COMPONENT-TEMPLATE.md — spec for a new component
