---
name: handoff-quality
layer: workflow
purpose: Handoff gates G1-G7 — what is verified before design reaches engineering, plus the upstream gate for scaffolding changes
applies_to:
  task_keywords: ["handoff", "gate", "readiness", "definition of done", "delivery"]
  loaded_for_modes: ["standard", "full"]
owner: handoff-author
---

# Handoff Quality Gates

Seven gates. A task is not delivered until all of them pass. A failed gate sends the task back; it is not delivered "with caveats".

## G1 — State completeness

- [ ] The coverage matrix in `spec.md` has no empty cells
- [ ] Every `✅` has a real frame in Figma (states contract 4c)
- [ ] Every `n/a` carries a written reason
- [ ] Transitions between states are described (Full)

Failing G1 is the most common and the most expensive: a missing state surfaces in production.

## G2 — A clean design

- [ ] `/design.audit` reports no CRITICALs
- [ ] Zero detached instances
- [ ] Zero hardcoded values outside those marked `🚧` and `spec:`
- [ ] Zero `🚧` layers in the delivered frames
- [ ] Naming follows the contract
- [ ] Frames have moved to a `✅` page

## G3 — Accessibility

- [ ] The `domain/accessibility.spec.md` checklist is complete
- [ ] Zero CRITICAL `A11Y` findings
- [ ] `spec:alt`, `spec:label`, `spec:focus-order` annotations are present where needed
- [ ] Contrast verified in every mode

## G4 — Copy

- [ ] Every string on the screen is in the `handoff.md` copy table
- [ ] Terms come from the glossary (`domain/ux-writing.spec.md`)
- [ ] State copy is written, not left as "Nothing found"
- [ ] Text growth under localization has been checked

## G5 — A self-sufficient spec

- [ ] `handoff.md` follows the structure in `domain/handoff.spec.md`
- [ ] The "Open questions" section is empty
- [ ] Not a single "as in the design" or unlinked "same as"
- [ ] Adaptivity is described for every breakpoint
- [ ] Behavior and data are described, edge cases included
- [ ] Assets are exported and in place

How to check this gate: **read the spec as an engineer who has not seen the task.** If a question comes up, the gate has failed.

## G6 — Traces

- [ ] `worklog.md` is closed with `— DONE: ...`
- [ ] DDRs exist for every non-obvious decision
- [ ] `agent-log.md` is written
- [ ] The task is in `<TRACKER_TESTING_STATUS>`
- [ ] A link to `handoff.md` is in the tracker

## G7 — Upstream (scaffolding changes)

Applies when the change touches `specs/`, `.claude/`, `drills/`, `scripts/`, or `CLAUDE.md`, in every mode, Quick included.

- [ ] The PR description (or, for a direct commit to the template, the journal entry) has an `Upstream` section: one line per scaffolding file labeled `generic` / `generic after generalizing` / `design-only`
- [ ] Every `generic` line is copied into `docs/template-sync.md` "To send"

Without the section the change is not ready. Rule and format: `workflows/template-sync.spec.md`.

## Order

Gates run in sequence. Failing G2 means G5 is not checked yet: there is no point proofreading a spec for a design that will still change.

## Cross-refs

- domain/handoff.spec.md — spec structure
- domain/states.spec.md — the states contract
- domain/accessibility.spec.md — the a11y checklist
- core/project.spec.md §2 — the DoD
- workflows/verify.spec.md — the full re-check before closing
- workflows/template-sync.spec.md — G7, the up and down flows
