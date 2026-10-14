---
name: research
layer: workflow
purpose: Fact base from primary sources before a pre-spec or DDR — three buckets (confirmed / needs verification / refuted) plus a list of outdated claims
applies_to:
  task_keywords: ["research", "hig", "guidelines", "material", "sf symbols", "wcag", "platform pattern", "deprecated", "outdated"]
  loaded_for_modes: ["standard", "full"]
  triggers: ["the task relies on a platform pattern, system component, or symbol not yet used in the product", "the requirements assert how a platform or a guideline behaves"]
owner: design-lead
---

# Research

A step before the pre-spec or a DDR when the decision leans on a platform pattern, a system component, a symbol set, or an accessibility rule that the product does not use yet. The goal is to move everything the model or the author "remembers" out of the spec and replace it with links. Invented components, tokens, symbol names, or HIG patterns in a spec, a DDR, or a handoff are not allowed.

## When it is mandatory

- The task introduces a system component or platform pattern absent from the product and from `<DS_LIBRARY_NAME>` (a new navigation pattern, a sheet type, a system material).
- A DDR compares options, at least one of which the product has never shipped.
- The requirements or the brief assert platform or guideline behavior: "iOS shows this automatically", "HIG requires…", "WCAG allows…", "this symbol exists on every supported OS".
- The design uses symbols or system materials whose availability depends on the OS version, and `<PLATFORMS>` covers more than one version.

Not run in Quick mode. In Standard, one short `research.md` is enough; in Full, research feeds every structural option in the DDR.

## Sources

Primary sources only:

| Topic | Source |
|---|---|
| Apple platforms | Apple Human Interface Guidelines, Apple Design Resources, WWDC design sessions |
| Symbols | the SF Symbols app and its per-symbol availability (minimum OS version, renamed and deprecated symbols); Material Symbols for Android and Web |
| Android | Material Design guidelines, Android developer design docs |
| Web | WCAG and its "Understanding" documents, WAI-ARIA Authoring Practices |
| Accessibility on devices | Apple Accessibility documentation, Android accessibility documentation |
| Product | the current `<DS_LIBRARY_NAME>` version, earlier DDRs, the glossary in `domain/ux-writing.spec.md` |

Blogs, Dribbble, Medium posts, and "someone's app does it" are pointers, never confirmation. Without network access, say so plainly and report only what you are sure of, each item marked as unverified.

## Fact format

Every fact states: what is claimed, where it is confirmed (a link or the exact guideline section), which platform, OS, or guideline version it applies to, and the date it was checked.

## Three buckets

```
## Confirmed
- <fact> — <link or section>, <platform / version>, checked <date>

## Needs verification
- <fact> — where to look: <link or section>, why it is not confirmed yet

## Refuted
- <popular claim> — what is actually true, <link>, since which version
```

## Outdated claims

A separate list: claims on the topic that held only for older OS or guideline versions and still circulate in articles and old design files. Typical sources: superseded WCAG versions, guideline pages rewritten after a platform redesign, symbols renamed between SF Symbols releases, system materials replaced in a newer OS. Each entry: the claim, what replaced it, the version where it changed.

## Output

The file `<PER_TASK_SPEC_LOCATION>/<task-id>/research.md`. It feeds the task as follows:

- Lines from "Confirmed" go into §10 References of the pre-spec (`per-task/DESIGN-TASK-TEMPLATE.spec.md`) and into the Context of a DDR (`per-task/DDR-TEMPLATE.md`).
- Every line from "Needs verification" becomes a §8 Clarify question or an explicit assumption marked "needs verification" with the address where to check.
- Reviewers check the existence of components, tokens, and patterns against this file (`workflows/review-pipeline.spec.md`, control questions).

## Cross-refs

- workflows/design-workflow.spec.md — step 1, before the pre-spec is approved
- workflows/review-pipeline.spec.md — control questions before the verdict
- per-task/DESIGN-TASK-TEMPLATE.spec.md
- per-task/DDR-TEMPLATE.md
