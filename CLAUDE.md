# CLAUDE.md

Bootstrap document for Claude Code and every subagent working in this design workspace.

All detailed rules live in `specs/` (an SDD spec structure). This file is the entry point, not the source of truth.

## Project

`<PROJECT_NAME>` — product design for `<ORG_NAME>`.

- Primary tool: **Figma** (accessed through Figma MCP)
- Design system: `<DS_LIBRARY_NAME>`, file `<FIGMA_DS_FILE_KEY>`
- Product designs: file `<FIGMA_PRODUCT_FILE_KEY>`
- Platforms: `<PLATFORMS>`
- Spacing scale: base `<SPACING_BASE>` → `<SPACING_SCALE>`
- Accessibility baseline: WCAG `<WCAG_LEVEL>`
- Product interface language: `<DEV_LANGUAGE>`

Constitution (D-01..D-14) lives in `specs/core/project.spec.md §1`.

## First run

If files still contain `<UPPER_CASE>` placeholders, the workspace is not configured. Run:

```
/design.init
```

Claude will run the interview (through AskUserQuestion), substitute the values, remove unused modules, and clean up `specs/INDEX.md`. The shell alternative, without Claude Code, is `./scripts/init.sh`.

Verify with: `grep -rE '<[A-Z_]+>' specs/ CLAUDE.md README.md` — it should return nothing.

## Workspace layout

- Claude Code runs from the workspace root.
- Orchestration files (CLAUDE.md, `.claude/`, `specs/`) live here.
- Design source lives **in Figma**, not in the repository. Only specs, tokens, and exported assets are stored locally.
- `specs/` is a **symlink** to the Obsidian vault at `Projects/<PROJECT_NAME>/Specs/` (when init selected a vault). Specs live in the vault and are excluded from the git workspace repository (`/specs` in `.gitignore`). Every `specs/...` path resolves through the symlink — do not "move them back" into the repository.
- `./code` is an optional symlink to the implementation repository, needed only for drift checks and token export. Absent by default.
- `./exports` holds generated tokens and assets (gitignored unless decided otherwise).

See `specs/core/workspace.spec.md`.

## The vault and the onto agent (zones of responsibility)

Two independent agent loops share the Obsidian vault: **you** (the workspace agent, designing against `specs/`) and the **onto agent** (the ontological knowledge layer, running against the vault's own CLAUDE.md). Neither reads the other's bootstrap, so the zone table is duplicated in both canons and **changes only in lockstep**:

| Zone | Who writes | Your role |
|---|---|---|
| `Projects/<P>/Specs/`, `Projects/<P>/Tasks/` | you | your zone (through the symlink or a full path) |
| `Projects/<P>/Requirements/` | human / product team | read only |
| `onto/`, `sources/`, `ontology.yaml`, `.ontovault/` | onto agent | **never touch** |

**A task counts as finished on the final `worklog.md` entry** (`— DONE: ...`) — that is the distillation trigger for the onto agent. Links to vault artifacts always use the full vault-relative path (`[[Projects/<P>/Tasks/<task-id>/worklog.md]]`), never a basename.

The full contract is in `specs/core/vault-contract.spec.md`.

## SDD spec structure

```
specs/
├── INDEX.md           — map of every spec with its triggers
├── LOADER.md          — on-demand loading contract (schema v2)
├── core/              — always loaded
│   ├── project.spec.md         — Constitution D-01..D-14, DoD, sources of truth
│   ├── workspace.spec.md       — layout, Figma as source of truth
│   ├── vault-contract.spec.md  — contract with the Obsidian vault and the onto agent
│   ├── design-system.spec.md   — DS hierarchy, what counts as canonical
│   ├── naming.spec.md          — naming for layers, components, variables, frames
│   ├── git-policy.spec.md      — what not to commit, branches
│   └── commits.spec.md         — Conventional Commits, author, language
├── domain/            — on demand, by trigger
│   └── figma-structure, components, variables, color, typography, layout,
│       states, accessibility, prototyping, ux-writing, tokens-export,
│       handoff, assets
├── workflows/         — by mode
│   └── task-modes, template-sync, verify, artifact-discipline, design-workflow,
│       clarify, research, critique, review-pipeline, handoff-quality, drift-check,
│       decision-gates, versioning, team-dispatch, agent-log, checkpoint, anti-patterns
├── per-epic/
│   └── EPIC-TEMPLATE.md        — design epic (SDD level 2)
└── per-task/
    ├── DESIGN-TASK-TEMPLATE.spec.md — task pre-spec (problem, AC, guardrails, DoR)
    ├── QUICK-TEMPLATE.spec.md       — thin spec for Quick mode
    ├── COMPONENT-TEMPLATE.md        — DS component specification
    ├── DDR-TEMPLATE.md              — Design Decision Record
    └── A11Y-PRIVACY-CHECKLIST.md    — per-screen accessibility and privacy checklist
```

**A worked example:** `bootstrap/examples/` holds an end-to-end mock feature with every artifact.

## Loading rules

**Every subagent must:**

1. Read `specs/INDEX.md` to see what is available.
2. Read **every `specs/core/*.spec.md`** — always loaded (the Constitution included, in `project.spec.md §1`).
3. Load matching `specs/domain/*.spec.md` by task scope (figma_nodes / surfaces / task_keywords / attachments).
4. Load matching `specs/workflows/*.spec.md` by mode (Quick / Standard / Full).

See `specs/LOADER.md` for the full contract.

## Task entry point

For a **large epic** (more than one screen, or a new section), start from `specs/per-epic/EPIC-TEMPLATE.md`.

For a new task:

1. **Mode detection** — `specs/workflows/task-modes.spec.md`.
2. **Design workflow** (Standard/Full) — `specs/workflows/design-workflow.spec.md`, including the states contract 4a/4b/4c (`specs/workflows/handoff-quality.spec.md`).
3. **Pre-spec** — create it from the matching template:
   - Standard / Full → `specs/per-task/DESIGN-TASK-TEMPLATE.spec.md`
   - Quick → `specs/per-task/QUICK-TEMPLATE.spec.md`
   - A new DS component → `specs/per-task/COMPONENT-TEMPLATE.md`
   - A contested decision to record → `specs/per-task/DDR-TEMPLATE.md`
   - The task leans on a platform pattern, system component, or symbol the product does not use yet, or the brief asserts platform behavior → first `research.md` per `specs/workflows/research.spec.md`.
   - The screen shows personal, financial, health, or credential data, or introduces a new interactive pattern → `a11y-privacy.md` per `specs/per-task/A11Y-PRIVACY-CHECKLIST.md`.
4. **Where per-task artifacts live** — `<PER_TASK_SPEC_LOCATION>/<task-id>/`, see `specs/core/project.spec.md §5`.

## Slash commands

| Command | What it does |
|---|---|
| `/design.init` | first-run setup: interview and value substitution |
| `/design.audit` | audit a Figma file against DS rules: detached, hardcoded, spacing, states |
| `/design.handoff` | Figma frame → engineering handoff spec |
| `/design.tokens` | Figma variables → tokens JSON, plus platform export |
| `/design.drift` | compare the implementation in `./code` against the design |
| `/design.critique` | design critique: hierarchy, states, accessibility, copy |
| `/template-sync` | reconcile the scaffolding with its template: `down`, `up`, or `all` |

## Hard rules (always applied)

These live in core and are **always** active, regardless of mode and domain:

- **Figma is the only source of truth for visuals.** Local `.md` files describe the design but never replace it — `specs/core/workspace.spec.md`
- **Never change anything in Figma without explicit human permission** — Claude is read-only in Figma by default; writes happen only through manual steps described in the handoff — `specs/core/design-system.spec.md`
- **No hardcoded values** where a variable or style exists — `specs/domain/variables.spec.md`
- **Naming follows the contract** — `specs/core/naming.spec.md`
- **Every state is mandatory** before handoff — `specs/domain/states.spec.md`
- **WCAG `<WCAG_LEVEL>` is the floor**, not an aspiration — `specs/domain/accessibility.spec.md`
- **Conventional Commits (terse, no body), no AI mentions** — `specs/core/commits.spec.md`
- **Never commit:** CLAUDE.md, `*-plan.md`, `.md` instructions, exported PNG mockups, `.figma-cache/` — `specs/core/git-policy.spec.md`
- **`[x]` only after the check, with a `✅` link; delivered tasks and accepted DDRs are immutable** — `specs/workflows/artifact-discipline.spec.md`, checks in `specs/workflows/verify.spec.md`
- **The scaffolding syncs with its template both ways** — a change touching `specs/`, `.claude/`, `drills/`, `scripts/`, `CLAUDE.md` carries an `Upstream` section (G7); down-sync by the `.template-sync` marker and the session-start hook reminder, command `/template-sync` — `specs/workflows/template-sync.spec.md`

## Stop conditions (Tier 2 — hard stop)

See `specs/workflows/decision-gates.spec.md`:

- Clarify needed (a product question the requirements do not answer)
- A choice between several valid design directions is required
- Any CRITICAL finding (DS_VIOLATION / A11Y / DESIGN_DRIFT)
- A change to a public DS component (breaking change for consumers)
- Scope violation (edits outside the declared frames)
- Reroute limit reached
- A write to Figma is required (Claude is read-only)

## Memory and auto-memory

The system memory loader, when enabled in Claude Code, loads automatically. Memory complements this workspace's specifics; it does not replace them.

## Template provenance

This workspace was built from the `design-workspace-template`. After cloning:

1. Run `./scripts/setup-tools.sh` (checks Claude Code and node, wires up Figma MCP).
2. Run `/design.init` in Claude Code (or `./scripts/init.sh`).
3. Open `specs/core/project.spec.md` — review §1 Constitution (D-01..D-14), §2 DoD, §3 sources of truth.
4. Open `specs/core/design-system.spec.md` — reconcile the DS hierarchy with the real file.
5. Open `specs/domain/*` — tune scales, variable collections, and breakpoints to the real project.
6. Optionally copy `.claude/settings.local.json.example` → `.claude/settings.local.json`.
7. Open the workspace `README.md` — it holds the step-by-step guide and the full placeholder table.
8. Point the `template` remote at this template (`git remote add template git@github.com:tooszovski/design-workspace-template.git`), write `.template-sync` (`sha=<template commit> date=<today>`), and start `docs/template-sync.md` per `specs/workflows/template-sync.spec.md`.
