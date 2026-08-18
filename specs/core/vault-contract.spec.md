---
name: vault-contract
layer: core
purpose: Contract with the Obsidian vault and the onto agent — specs symlink, Tasks/, forbidden zones, worklog as signal
always_loaded: true
owner: design-lead
---

# Vault Contract

Applies when init selected Obsidian for artifact storage. If the repository-only mode was chosen, this file reduces to a single fact — `<PER_TASK_SPEC_LOCATION>` sits inside the workspace — and the section about the onto agent does not apply.

## The symlink pattern

```
workspace/specs  →  <VAULT>/Projects/<PROJECT_NAME>/Specs/
```

- Specs physically live in the vault so they are reachable from Obsidian and feed knowledge distillation.
- A symlink stays in the workspace, so every `specs/...` path in specs and prompts keeps working unchanged.
- `/specs` is added to `.gitignore` — specs are not duplicated in git.
- **Do not "move specs back" into the repository.** If the symlink breaks, repair the symlink; do not copy the files.

## Project layout in the vault

```
<VAULT>/Projects/<PROJECT_NAME>/
├── Requirements/       — incoming requirements (humans write, the agent reads)
├── Specs/              — target of the specs/ symlink
├── Tasks/              — <PER_TASK_SPEC_LOCATION>: one folder per task
│   └── <PROJECT_PREFIX>-NNN/
│       ├── spec.md
│       ├── worklog.md
│       ├── handoff.md
│       └── agent-log.md
└── Agent Logs/         — <AGENT_LOGS_LOCATION>: cross-task journal
```

## Zones of responsibility

Two independent agent loops share the vault. This table is duplicated in the workspace `CLAUDE.md` and in the vault's own `CLAUDE.md` — **change both at once, never one alone**.

| Zone | Who writes | Design agent's role |
|---|---|---|
| `Projects/<P>/Specs/`, `Projects/<P>/Tasks/` | design agent | its own zone |
| `Projects/<P>/Requirements/` | human / product | read only |
| `onto/`, `sources/`, `ontology.yaml`, `.ontovault/` | onto agent | **never touch** |
| The rest of the vault | human | read only |

## The worklog as a completion signal

A final `— DONE: <short outcome>` line in `worklog.md` triggers distillation for the onto agent. Consequences:

- Do not write `DONE` until the DoD (`core/project.spec.md §2`) is satisfied.
- Do not write `DONE` twice in one worklog.
- If work reopens after `DONE`, add `— REOPENED: <reason>`, do the work, then write a new `— DONE`.

## Linking to artifacts

Always by full vault-relative path:

- ✅ `[[Projects/<PROJECT_NAME>/Tasks/<PROJECT_PREFIX>-142/handoff.md]]`
- ❌ `[[handoff.md]]` — a basename breaks the moment two tasks share a filename

## Cross-refs

- core/workspace.spec.md — layout
- core/project.spec.md §5 — contents of a task folder
- workflows/agent-log.spec.md — format of the final report
