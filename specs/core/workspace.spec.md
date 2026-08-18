---
name: workspace
layer: core
purpose: Design-workspace layout, zone boundaries, Figma as an external source of truth
always_loaded: true
owner: design-lead
---

# Workspace Layout

## Structure

```
<workspace-root>/
├── CLAUDE.md              — bootstrap, not committed in a derived workspace
├── README.md
├── .mcp.json              — Figma MCP (gitignored, from .mcp.json.example)
├── .claude/               — agents, commands, settings
├── scripts/
├── specs/                 — symlink to vault Projects/<PROJECT_NAME>/Specs/ (or a plain folder)
├── exports/               — generated tokens and assets (gitignored)
│   ├── tokens/
│   └── assets/
├── code/                  — optional symlink to <CODE_REPO_PATH> (read-only)
└── bootstrap/             — REQUIREMENTS plus worked examples
```

## Boundaries

| Zone | Agent's rights |
|---|---|
| `specs/`, `<PER_TASK_SPEC_LOCATION>/` | read and write |
| `exports/` | read and write (regenerated, never hand-edited) |
| Figma via MCP | **read only** (D-02) |
| `code/` | **read only** — for drift checks; engineering makes the edits |
| `<TASK_SPEC_SOURCE_PATH>` (requirements) | read only |
| `.claude/`, `CLAUDE.md` | edit only when a human explicitly asks |

## Figma as an external source of truth

Designs do not live in the repository. That has consequences:

1. **You cannot "read the project" off disk.** Design state comes through Figma MCP (`mcp__figma__get_figma_data`) by file key plus node id. Pulling a whole file without a node id is expensive — ask the human which frame first.
2. **Caching is mandatory for large files.** Store the exported JSON in `.figma-cache/<file-key>/<node-id>.json` (gitignored) and reuse it for the duration of the task. Treat the cache as stale when the file's `lastModified` changes.
3. **Screenshots are a secondary channel.** `mcp__figma__download_figma_images` writes to `.figma-cache/img/`. An image answers "how does it look"; the JSON answers "what is it made of". An audit needs the JSON.
4. **No MCP access means no audit.** Do not invent the contents of a design from the task title. Lack of access is a FAIL with a reason, not a prompt to guess.

## The optional `code/`

Appears only when `<CODE_REPO_PATH>` was set during init. It serves two purposes:

- `/design.drift` — comparing implementation against the design (`workflows/drift-check.spec.md`)
- `/design.tokens` — writing the export to `<TOKENS_EXPORT_PATH>` (`domain/tokens-export.spec.md`)

In every other case `code/` is not read: it inflates context and has nothing to do with the design task.

## Running

Claude Code starts from the workspace root. Paths in specs are relative to that root (`specs/...`, `exports/...`).

## Cross-refs

- core/vault-contract.spec.md — what lives in Obsidian
- core/git-policy.spec.md — what not to commit
- domain/figma-structure.spec.md — how the Figma file is organized
- workflows/drift-check.spec.md — working with `code/`
