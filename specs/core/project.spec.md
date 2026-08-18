---
name: project
layer: core
purpose: Constitution D-01..D-14, Definition of Done, sources of truth, three SDD levels
always_loaded: true
owner: design-lead
---

# Project Constitution

## §1 Constitution (D-01..D-14)

Rules that are not broken without an explicit written exception in §1.1.

| ID | Rule |
|---|---|
| **D-01** | **Figma is the single source of truth for visuals.** Any `.md` describes the design but never replaces it. On conflict, the file wins. |
| **D-02** | **Claude is read-only in Figma.** Reading through MCP is always allowed; writing never is, absent an explicit human instruction in the current session. Changes are delivered as instructions for a human, not as automatic edits. |
| **D-03** | **Zero hardcoded values.** Color, spacing, radius, type, shadow — only through a design-system variable or style. A raw value is acceptable only as a temporary experiment, marked `🚧` in the layer name. |
| **D-04** | **A component, not a copy.** A pattern that appears on 2+ screens lives as a `<DS_LIBRARY_NAME>` component, not as a detached copy. |
| **D-05** | **Every state is mandatory.** A screen is not done until empty / loading / error / success / disabled variants that apply to it are covered. Non-applicability is stated explicitly, not implied by silence. |
| **D-06** | **WCAG `<WCAG_LEVEL>` is the floor.** Contrast, touch-target size, focus order, and text alternatives are verified before handoff. |
| **D-07** | **Naming follows the contract** in `core/naming.spec.md`. A layer without a meaningful name is technical debt. |
| **D-08** | **Adaptive by default.** Every design answers what happens at the smallest and largest breakpoint of `<PLATFORMS>`. |
| **D-09** | **Content is realistic.** No `Lorem ipsum`, no `John Doe`, no conveniently perfect line lengths — edge cases (empty string, very long string, zero items, 999+) appear in the design. |
| **D-10** | **One screen, one primary job.** Two equally weighted primary actions on a screen is a hierarchy defect, not a matter of taste. |
| **D-11** | **Changing a public DS component is a breaking change.** It requires a DDR, a version bump, and a list of affected consumers (`workflows/versioning.spec.md`). |
| **D-12** | **Handoff is self-sufficient.** An engineer must be able to build the screen without asking the designer anything. Every question they ask is a defect in the spec. |
| **D-13** | **Decisions are recorded.** A choice between valid alternatives goes into a DDR (`per-task/DDR-TEMPLATE.md`), not into a verbal agreement. |
| **D-14** | **Terminology is unified.** One entity, one word — in the design, in the UX copy, in the spec, and in the code. The glossary lives in `domain/ux-writing.spec.md`. |

### §1.1 Overrides

Project-specific exceptions to the Constitution. Each one carries a reason and a date. Empty means no exceptions.

| ID | Exception | Reason | Date |
|---|---|---|---|
| — | — | — | — |

## §2 Definition of Done

A task is closed when **all** of the following hold:

- [ ] The design is built in `<FIGMA_PRODUCT_FILE_KEY>`, frame named per `core/naming.spec.md`
- [ ] All applicable states are present (`domain/states.spec.md`)
- [ ] Zero detached instances and zero hardcoded values (`/design.audit` is clean)
- [ ] Contrast and touch targets pass WCAG `<WCAG_LEVEL>` (`domain/accessibility.spec.md`)
- [ ] Breakpoints for `<PLATFORMS>` are covered (`domain/layout.spec.md`)
- [ ] UX copy is proofread, terms come from the glossary (`domain/ux-writing.spec.md`)
- [ ] The handoff spec is written and self-sufficient (`domain/handoff.spec.md`)
- [ ] The prototype covers the main happy path (if the task calls for one)
- [ ] `worklog.md` is closed with a `— DONE: ...` line
- [ ] The task is moved to `<TRACKER_TESTING_STATUS>` in `<TRACKER_NAME>`

## §3 Sources of truth

| What | Where | Owner |
|---|---|---|
| Screen visuals | Figma `<FIGMA_PRODUCT_FILE_KEY>` | designer |
| Components, variables, styles | Figma `<FIGMA_DS_FILE_KEY>` (`<DS_LIBRARY_NAME>`) | DS owner |
| Product requirements | `<TASK_SPEC_SOURCE_PATH>` | product |
| Design rules | `specs/` (this repository) | design lead |
| Tokens in code | `<TOKENS_EXPORT_PATH>` | generated from Figma, never edited by hand |
| Implementation | `<CODE_REPO_PATH>` | engineering |
| Reference platform | `<REFERENCE_PLATFORM>` | — |

When sources conflict, the one higher in this table wins. When visuals conflict with requirements, that is a Tier 2 stop.

## §4 Three SDD levels

| Level | Artifact | When |
|---|---|---|
| **PROJECT** | this file plus all of `core/` | always |
| **EPIC** | `<PER_TASK_SPEC_LOCATION>/<epic-id>/epic.md` per `per-epic/EPIC-TEMPLATE.md` | a section or flow spanning several screens |
| **TASK** | `<PER_TASK_SPEC_LOCATION>/<task-id>/spec.md` per `per-task/DESIGN-TASK-TEMPLATE.spec.md` or `QUICK-TEMPLATE.spec.md` | every task |

A DDR (`per-task/DDR-TEMPLATE.md`) is attached when the pre-spec references specific DDR IDs.

## §5 Where per-task artifacts live

```
<PER_TASK_SPEC_LOCATION>/<task-id>/
├── spec.md          — pre-spec (DESIGN-TASK / QUICK)
├── worklog.md       — append-only log, closed with `— DONE: ...`
├── handoff.md       — spec for engineering
├── critique.md      — review findings (if any)
├── ddr-NNN.md       — design decision records (if any)
└── agent-log.md     — final report of the agent session
```

`<task-id>` is `<PROJECT_PREFIX>-<number>` from `<TRACKER_NAME>`.

## Cross-refs

- core/workspace.spec.md — layout and boundaries
- core/design-system.spec.md — DS hierarchy
- workflows/design-workflow.spec.md — task steps
- workflows/decision-gates.spec.md — Tier 1 / Tier 2
