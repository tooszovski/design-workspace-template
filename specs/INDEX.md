---
name: index
purpose: Map of every spec file with its loading triggers
schema_version: 2
---

# Specs Index

**Structure:**

- `core/*` — always loaded (7 files), plus any spec marked `always_loaded: true`
- `domain/*` — on demand, by trigger (`task_keywords` / `task_attachments` / `paths` / free-form `triggers`)
- `workflows/*` — by `loaded_for_modes` (Quick / Standard / Full); some always

**Loader contract and frontmatter schema (v2):** `LOADER.md`.

## Core (always loaded — 7 files)

| Name | Path | Purpose |
|---|---|---|
| project | core/project.spec.md | Constitution D-01..D-14, DoD, sources of truth, three SDD levels |
| workspace | core/workspace.spec.md | Layout, zone boundaries, Figma as an external source of truth |
| vault-contract | core/vault-contract.spec.md | Obsidian: specs symlink, Tasks/, forbidden zones, worklog as signal |
| design-system | core/design-system.spec.md | DS hierarchy, canon, consuming and changing the library |
| naming | core/naming.spec.md | Naming for pages, frames, layers, components, variables, exports |
| git-policy | core/git-policy.spec.md | What not to commit, branches, rebase, push |
| commits | core/commits.spec.md | Conventional Commits, scopes, author, language |

## Domain (on demand — 13 files)

| Name | Path | Triggers |
|---|---|---|
| figma-structure | domain/figma-structure.spec.md | keywords: figma, file, structure, page, section, cover |
| components | domain/components.spec.md | keywords: component, variant, instance, library, detach, slot |
| variables | domain/variables.spec.md | keywords: variable, token, theme, dark mode, mode, alias |
| color | domain/color.spec.md | keywords: color, palette, contrast, dark theme, gradient, opacity |
| typography | domain/typography.spec.md | keywords: typography, font, text, text style, heading, type size |
| layout | domain/layout.spec.md | keywords: layout, auto-layout, grid, spacing, breakpoint, responsive |
| states | domain/states.spec.md | keywords: state, empty, loading, error, skeleton · **default for screen tasks** |
| accessibility | domain/accessibility.spec.md | keywords: accessibility, a11y, wcag, contrast, focus, screen reader · **default for screen tasks** |
| prototyping | domain/prototyping.spec.md | keywords: prototype, animation, transition, motion, interaction |
| ux-writing | domain/ux-writing.spec.md | keywords: copy, microcopy, wording, tone of voice, terminology |
| tokens-export | domain/tokens-export.spec.md | paths: exports/tokens/**, `<TOKENS_EXPORT_PATH>` · keywords: tokens, export, style dictionary |
| handoff | domain/handoff.spec.md | keywords: handoff, engineering spec, developer, implementation, annotation |
| assets | domain/assets.spec.md | paths: exports/assets/** · keywords: icon, illustration, image, svg, logo |

**Project-specific domain specs** to add as needed: industry specifics, regulatory UI requirements, brand book, email templates, print materials, data visualization.

## Workflows (by mode — 13 files)

| Name | Path | Loaded for |
|---|---|---|
| task-modes | workflows/task-modes.spec.md | **always_loaded** — needed for classification |
| design-workflow | workflows/design-workflow.spec.md | quick, standard, full — steps 0-10 |
| review-pipeline | workflows/review-pipeline.spec.md | quick, standard, full — who reviews and when |
| decision-gates | workflows/decision-gates.spec.md | quick, standard, full — Tier 1 / Tier 2 |
| anti-patterns | workflows/anti-patterns.spec.md | quick, standard, full |
| clarify | workflows/clarify.spec.md | standard, full — question batch, drift guard |
| critique | workflows/critique.spec.md | standard, full — design critique |
| handoff-quality | workflows/handoff-quality.spec.md | standard, full — gates G1-G6 |
| drift-check | workflows/drift-check.spec.md | standard, full (plus trigger: accepting an implementation) |
| team-dispatch | workflows/team-dispatch.spec.md | standard, full — roster, lean return |
| agent-log | workflows/agent-log.spec.md | standard, full — worklog and final report |
| checkpoint | workflows/checkpoint.spec.md | full (plus trigger: estimate above 2h) |
| versioning | workflows/versioning.spec.md | full (plus trigger: the task touches the DS) |

## Per-epic (SDD level 2)

| Path | Purpose |
|---|---|
| per-epic/EPIC-TEMPLATE.md | Section charter: flow map, breakdown, shared decisions and components, cross-cutting requirements |
| per-epic/README.md | When to open an epic, where real ones live |

## Per-task (SDD level 3, plus Quick, component, DDR)

| Path | Purpose |
|---|---|
| per-task/DESIGN-TASK-TEMPLATE.spec.md | Pre-spec: problem, requirements, AC, state matrix, guardrails, DoR |
| per-task/QUICK-TEMPLATE.spec.md | Thin spec for Quick |
| per-task/COMPONENT-TEMPLATE.md | DS component spec: API, anatomy, states, promotion checklist |
| per-task/DDR-TEMPLATE.md | Design Decision Record |
| per-task/README.md | Which template to take when |

## Examples

A worked end-to-end example lives in `bootstrap/examples/`.

| Path | Level |
|---|---|
| bootstrap/examples/README.md | map of the example |
| bootstrap/examples/epic-example.md | epic |
| bootstrap/examples/design-task-example.md | task pre-spec |
| bootstrap/examples/ddr-example.md | DDR |
| bootstrap/examples/critique-example.md | review findings |
| bootstrap/examples/handoff-example.md | engineering spec |
| bootstrap/examples/worklog-example.md | append-only log |
| bootstrap/examples/agent-log-example.md | final report |

## Finding codes (summary)

| Code | Source |
|---|---|
| `DS_VIOLATION` | domain/components, variables, color, design-system |
| `A11Y`, `A11Y_CONTRAST` | domain/accessibility, color |
| `STATE_MISSING`, `STATE` | domain/states |
| `LAYOUT` | domain/layout |
| `TYPO` | domain/typography |
| `COPY` | domain/ux-writing |
| `MOTION` | domain/prototyping |
| `ASSET` | domain/assets |
| `NAMING` | core/naming |
| `STRUCTURE` | domain/figma-structure |
| `HANDOFF` | domain/handoff |
| `DESIGN_DRIFT`, `TOKEN_DRIFT` | workflows/drift-check, domain/tokens-export |
| `CRITIQUE` | workflows/critique |
