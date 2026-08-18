# Requirements

The design-workspace dependency matrix: what is required, what is optional, and what to do without each.

## Required

| Dependency | Why | Check | Without it |
|---|---|---|---|
| **Claude Code** | orchestration, the `/design.*` commands, agents | `claude --version` | the template degrades into a set of `.md` documents; the specs remain useful as rules for humans |
| **git** | versioning the specs | `git --version` | no history of the rules |
| **Figma access** | the source of truth for designs | signed-in account | without it no command works except `/design.init` |

## Required for the commands

| Dependency | For what | Check | Fallback |
|---|---|---|---|
| **node 18+** | running Figma MCP through npx | `node -v` | none: MCP will not start |
| **Figma MCP** | `/design.audit`, `/design.handoff`, `/design.tokens`, `/design.critique` | `claude mcp list` | manual export: the human sends screenshots and values; token and structure checks are unavailable |
| **Figma personal token** | MCP access to the files | in `.mcp.json` | — |

The token: figma.com → Settings → Security → Personal access tokens. Scope: **File content (read)**. Nothing more is needed — Claude never writes to Figma (D-02).

## Optional

| Dependency | For what | Fallback |
|---|---|---|
| **Obsidian** | storing specs and task artifacts | the repository-only mode at init |
| **`npx style-dictionary`** | transforming tokens per platform | `/design.tokens` stops at DTCG JSON in `exports/tokens/` |
| **`npx svgo`** | optimizing exported SVG | export without optimization, larger files |
| **A code repository** (`./code`) | `/design.drift`, writing tokens | drift checks limited to screenshots from engineering |

## What degrades without MCP

| Capability | Works without MCP |
|---|---|
| Rules and specs as documents | yes |
| `/design.init` | yes |
| `/design.critique` from screenshots | partly: hierarchy and copy yes, tokens and structure no |
| `/design.audit` | no |
| `/design.handoff` | partly: it will assemble the spec structure, but the contents must be dictated |
| `/design.tokens` | no |
| `/design.drift` | partly: visual comparison yes, tokens no |

The governing rule when access is missing: the agent returns `FAIL: figma access` rather than reconstructing the design from the task title. An invented design is worse than a missing one.

## Checking the environment

```bash
./scripts/setup-tools.sh
```

The script checks everything listed here, offers to install what is missing, and creates `.mcp.json` and `settings.local.json` from the examples.

## Versions

The template is not pinned to a Figma API version or a specific MCP server implementation: commands are written at the level of "fetch the structure of a node", not at the level of call signatures. When switching MCP servers, update `.mcp.json.example` and, if needed, the tool names in the commands' `allowed-tools`.
