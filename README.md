# Design Workspace Template

A workspace template for a designer working in Figma alongside Claude Code.

It wraps the design process in agent scaffolding: design-system rules as executable specs, audits of Figma files against those rules, generated handoff specs for engineering, token export, and drift checks against the implementation.

**No iOS specifics.** The template is platform-agnostic; platforms are chosen at first run.

## What is inside

```
.
├── CLAUDE.md                       — bootstrap, entry point for Claude Code
├── README.md                       — this file
├── .gitignore                      — what not to commit
├── .mcp.json.example               — Figma MCP config
├── scripts/
│   ├── setup-tools.sh              — environment check: Claude Code, node, Figma MCP
│   ├── init.sh                     — shell setup wizard (alternative to /design.init)
│   └── validate-specs.sh           — validates frontmatter, cross-refs, placeholders
├── .claude/
│   ├── commands/                   — /design.init · audit · handoff · tokens · drift · critique
│   ├── agents/                     — design-lead · figma-analyst · handoff-author + 3 reviewers
│   ├── hooks/git-push-guard.sh     — blocks pushes to protected branches
│   ├── skills/                     — local skills (empty by default)
│   ├── settings.json               — hooks, committed
│   └── settings.local.json.example — allow-list, removes permission prompts
├── specs/                          — SDD spec structure (33 specs plus templates)
│   ├── INDEX.md                    — spec map with triggers
│   ├── LOADER.md                   — on-demand loading contract, schema v2
│   ├── core/       (7)             — always loaded
│   ├── domain/     (13)            — on demand, by trigger
│   ├── workflows/  (13)            — by task mode
│   ├── per-epic/                   — epic template
│   └── per-task/                   — task, component, and DDR templates
└── bootstrap/
    ├── REQUIREMENTS.md             — dependency matrix
    └── examples/                   — a worked end-to-end example
```

## Quick start

```bash
cp -r design-workspace ~/git/my-product-design
cd ~/git/my-product-design
git init

./scripts/setup-tools.sh     # environment: Claude Code, node, Figma MCP
claude                       # then: /design.init
```

`/design.init` runs the interview, substitutes values across every file, removes the modules you turned off, and cleans up `INDEX.md`. Without Claude Code, use `./scripts/init.sh`.

Check the result:

```bash
./scripts/validate-specs.sh
```

## How it works

### Specs instead of prompts

Design rules live in `specs/` as machine-readable documents with frontmatter. An agent does not receive all of them at once: the loader assembles a bundle for the specific task from triggers (`specs/LOADER.md`).

- `core/` — always loaded: Constitution, design system, naming, git
- `domain/` — by task keywords: color, typography, states, accessibility, and so on
- `workflows/` — by task mode: Quick / Standard / Full

This keeps agent context small and stops the same requirements from being read differently across sessions.

### Three task modes

| Mode | When | What happens |
|---|---|---|
| Quick | 1–2 frames, an edit with no new states | one pass, audit, deliver |
| Standard | a new screen or flow | clarify → structure → states → critique → handoff |
| Full | a section, a DS change, a new pattern | plus an epic, DDRs, parallel reviewers, checkpoints |

### The states contract

The design equivalent of TDD. Screen states are built **before** polish: the coverage matrix first, then the frames, then reconciliation. It is the only reliable way found to stop losing `empty` and `error` to the deadline.

### Claude is read-only in Figma

The agent reads designs through MCP but never writes to them. Changes are delivered as instructions for a human. The reason: a silent edit to someone else's file is irreversible and invisible.

## Commands

| Command | What it does |
|---|---|
| `/design.init` | first-run setup: interview and value substitution |
| `/design.audit` | 15 checks on a frame: detached, hardcoded, spacing, states, contrast, naming |
| `/design.handoff` | frame → a self-sufficient spec for engineering |
| `/design.tokens` | Figma variables → DTCG JSON → platform export |
| `/design.drift` | compare implementation against the design, file `DESIGN_DRIFT` findings |
| `/design.critique` | design critique: problem, hierarchy, completeness, buildability |

## Placeholders

Filled in by `/design.init` or `./scripts/init.sh`.

| Token | What it is | Example |
|---|---|---|
| `<PROJECT_NAME>` | project name, CamelCase | `AcmeShop` |
| `<ORG_NAME>` | organization or product | `Acme` |
| `<PROJECT_PREFIX>` | task prefix in the tracker | `ACM` |
| `<DEV_LANGUAGE>` | product interface language | `en` |
| `<FIGMA_DS_FILE_KEY>` | file key of the design-system file | `aBc123XyZ` |
| `<FIGMA_PRODUCT_FILE_KEY>` | file key of the product file | `dEf456UvW` |
| `<DS_LIBRARY_NAME>` | library name | `Acme DS` |
| `<PLATFORMS>` | product platforms | `Web, iOS, Android` |
| `<SPACING_BASE>` | spacing scale base | `4` |
| `<SPACING_SCALE>` | the scale itself | `4, 8, 12, 16, 24, 32, 48, 64` |
| `<WCAG_LEVEL>` | accessibility level | `AA` |
| `<CODE_REPO_PATH>` | implementation repository, optional | `~/git/acme-web` |
| `<TOKENS_EXPORT_PATH>` | where tokens go | `~/git/acme-web/tokens` |
| `<TASK_SPEC_SOURCE_PATH>` | where requirements live | vault `Projects/Acme/Requirements` |
| `<PER_TASK_SPEC_LOCATION>` | task specs and worklogs | vault `Projects/Acme/Tasks` |
| `<AGENT_LOGS_LOCATION>` | cross-task journal | vault `Projects/Acme/Agent Logs` |
| `<TRACKER_NAME>` | task tracker | `Jira` |
| `<TRACKER_TESTING_STATUS>` | the "in review" status | `Testing` |
| `<TRACKER_BLOCKED_STATUS>` | the "blocked" status | `Blocked` |
| `<GIT_USER_NAME>` / `<GIT_USER_EMAIL>` | commit author | — |
| `<COMMIT_LANGUAGE>` | commit message language | `English` |
| `<INTEGRATION_BRANCH>` / `<RELEASE_BRANCH>` | branches | `develop` / `main` |
| `<REFERENCE_PLATFORM>` | reference platform, optional | `Android` |

## Artifact storage

Two options, chosen at init:

**Obsidian vault plus symlink** (the default when a vault is found). `specs/` moves into `Projects/<PROJECT_NAME>/Specs/` and a symlink stays in the repository. Specs stay reachable from Obsidian and feed knowledge distillation, without being duplicated in git. Tasks live in `Projects/<PROJECT_NAME>/Tasks/<task-id>/`.

**Repository only.** `specs/` and `tasks/` sit in the workspace and Obsidian is not used. The onto-agent section of `core/vault-contract.spec.md` does not apply in that case.

## What to fill in by hand after init

These need project knowledge the wizard cannot guess:

| File | What |
|---|---|
| `specs/domain/layout.spec.md` | the breakpoint table for the chosen platforms |
| `specs/domain/ux-writing.spec.md` | the product glossary |
| `specs/domain/color.spec.md` | the real semantic roles, if they differ from the defaults |
| `specs/core/project.spec.md §1` | review the Constitution D-01..D-14 against the project |
| `specs/core/project.spec.md §1.1` | record exceptions, if there are any |
| `.mcp.json` | the Figma token |

## Dependencies

Required: Claude Code, node 18+, git. Optional: `npx style-dictionary` for token transforms, `npx svgo` for SVG optimization.

Details and fallbacks are in `bootstrap/REQUIREMENTS.md`.

## Evolving the template

The "What the specs should fix" section of each task's `agent-log.md` is the source of changes. A mistake that has happened twice goes into `specs/workflows/anti-patterns.spec.md`. A rule that was missing goes into the relevant domain spec.

After any frontmatter change:

```bash
./scripts/validate-specs.sh
```
