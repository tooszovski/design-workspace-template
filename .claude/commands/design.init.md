---
description: First-run setup of the design workspace — interview and value substitution
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, AskUserQuestion
---

# /design.init

Unpacking the workspace from the template. Run **once** after cloning. Idempotent: a second run overwrites the values without breaking already-configured files.

## Step 0 — Check the current state

```bash
grep -rEo '<[A-Z_]+>' specs/ CLAUDE.md README.md 2>/dev/null | sed 's/.*://' | sort -u
```

- Empty list → the workspace is already configured. Say so and ask whether to reconfigure. Without confirmation, exit.
- Non-empty list → continue.

Also read `README.md` § Placeholders — it holds the full token table with descriptions.

## Step 1 — The interview

Ask through `AskUserQuestion`, in **batches of 2–4 questions**, in the order below. Do not dump everything as one list — the person will not hold it. Do not ask one at a time either; that is slow.

Wherever a sensible default exists, put it first and mark it "(recommended)".

### Batch 1 — Project

| Token | Question | Default |
|---|---|---|
| `<PROJECT_NAME>` | Project name (CamelCase, no spaces) | required |
| `<ORG_NAME>` | Organization or product | required |
| `<PROJECT_PREFIX>` | Task prefix in the tracker (`ABC` → `ABC-142`) | required |
| `<DEV_LANGUAGE>` | Product interface language | `en` |

### Batch 2 — Figma

| Token | Question | Default |
|---|---|---|
| `<FIGMA_DS_FILE_KEY>` | File key of the design-system file | may be skipped |
| `<FIGMA_PRODUCT_FILE_KEY>` | File key of the product file | may be skipped |
| `<DS_LIBRARY_NAME>` | Library name | `<PROJECT_NAME> DS` |

The file key is part of the link: `figma.com/design/<KEY>/<name>`. If the person pastes a full URL, extract the key yourself instead of making them edit it.

If the keys do not exist yet, leave them and warn that `/design.audit` and `/design.tokens` will not work until they are filled in.

### Batch 3 — Platforms and scales

| Token | Question | Options |
|---|---|---|
| `<PLATFORMS>` | Product platforms (multiSelect) | Web · iOS · Android · Desktop |
| `<SPACING_BASE>` | Spacing scale base | `4` (recommended) · `8` |
| `<SPACING_SCALE>` | The scale | from base `4`: `4, 8, 12, 16, 24, 32, 48, 64`; from `8`: `8, 16, 24, 32, 48, 64` |
| `<WCAG_LEVEL>` | Accessibility level | `AA` (recommended) · `AAA` · `A` |

`<PLATFORMS>` is written comma-separated. Breakpoints in `domain/layout.spec.md` depend on the choice — offer to fill in their values right away.

### Batch 4 — Modules

Which capabilities to enable (multiSelect, all on by default except the last):

| Module | What it pulls in |
|---|---|
| Design audit against DS rules | `/design.audit`, `reviewer-designsystem` |
| Handoff specs for engineering | `/design.handoff`, `handoff-author`, `domain/handoff` |
| Accessibility checks | `reviewer-a11y`, `domain/accessibility` |
| UX copy | the copy part of `/design.critique`, `reviewer-ux-copy`, `domain/ux-writing` |
| Design token export | `/design.tokens`, `domain/tokens-export`, prompts for `<TOKENS_EXPORT_PATH>` |
| Implementation drift check | `/design.drift`, `workflows/drift-check`, prompts for `<CODE_REPO_PATH>` |

A disabled module is removed entirely: specs, command, agent, and the lines in `INDEX.md` and `CLAUDE.md`. Half-measures leave dead links that agents will later try to open.

### Batch 5 — Code repository

Asked only when token export or drift check was selected.

| Token | Question | Default |
|---|---|---|
| `<CODE_REPO_PATH>` | Path to the implementation repository | empty |
| `<TOKENS_EXPORT_PATH>` | Where tokens go inside it | `<CODE_REPO_PATH>/tokens` |

When `<CODE_REPO_PATH>` is non-empty, offer to create the `./code` symlink.

### Batch 6 — Artifact storage

First check whether Obsidian is present:

```bash
ls -d ~/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/*/ 2>/dev/null
```

| Option | Offer first when |
|---|---|
| Obsidian vault plus symlink | a vault was found |
| Repository only | no vault was found |

If Obsidian is chosen: one vault means take it; several means let them pick; none means ask for the path.

Then fill in:

| Token | Obsidian | Repository only |
|---|---|---|
| `<TASK_SPEC_SOURCE_PATH>` | `<VAULT>/Projects/<PROJECT_NAME>/Requirements` | tracker name or path |
| `<PER_TASK_SPEC_LOCATION>` | `<VAULT>/Projects/<PROJECT_NAME>/Tasks` | `tasks` |
| `<AGENT_LOGS_LOCATION>` | `<VAULT>/Projects/<PROJECT_NAME>/Agent Logs` | `tasks` |

### Batch 7 — Tracker and git

| Token | Question | Default |
|---|---|---|
| `<TRACKER_NAME>` | Task tracker | `Jira` · `Linear` · `Bitrix24` · `YouTrack` |
| `<TRACKER_TESTING_STATUS>` | The "in review" status | `Testing` |
| `<TRACKER_BLOCKED_STATUS>` | The "blocked" status | `Blocked` |
| `<GIT_USER_NAME>` | Commit author name | from `git config user.name` |
| `<GIT_USER_EMAIL>` | Commit author email | from `git config user.email` |
| `<COMMIT_LANGUAGE>` | Commit message language | `English` |
| `<INTEGRATION_BRANCH>` | Integration branch | `develop` |
| `<RELEASE_BRANCH>` | Release branch | `main` |
| `<REFERENCE_PLATFORM>` | Reference platform, if any | empty |

## Step 2 — Confirmation

Show the full token → value table and ask for confirmation in a single question. Apply nothing before explicit agreement.

## Step 3 — Applying

1. **Token substitution** across every `*.md`, `*.json`, `*.sh`, `*.yml` in `specs/`, `.claude/`, `bootstrap/`, `scripts/`, plus `CLAUDE.md` and `README.md`.
   - Replace whole `<UPPER_CASE>` tokens only, never substrings.
   - An empty value: drop the line carrying the token when it becomes meaningless; otherwise leave the token and note it in the report.
2. **Remove disabled modules** — spec, command, and agent files plus the lines in `INDEX.md`, `CLAUDE.md`, and `LOADER.md`.
3. **Breakpoints** — write the table in `domain/layout.spec.md` for the chosen `<PLATFORMS>`.
4. **Spacing scale** — write the values into `domain/variables.spec.md`.
5. **Obsidian** (if chosen):
   - `mkdir -p` for `Requirements`, `Tasks`, `Agent Logs`
   - move `specs/` into `<VAULT>/Projects/<PROJECT_NAME>/Specs/` and leave a symlink
   - append `/specs` to `.gitignore`
6. **The `./code` symlink** (if `<CODE_REPO_PATH>` was set).
7. **MCP** — copy `.mcp.json.example` → `.mcp.json` if it is missing; remind them about the Figma token.
8. **settings.local.json** — copy from the `.example` if it is missing.
9. **git config** — offer to set `user.name` and `user.email` in this repository.

## Step 4 — Verification

```bash
./scripts/validate-specs.sh
grep -rEo '<[A-Z_]+>' specs/ CLAUDE.md README.md | sed 's/.*://' | sort -u
```

The second output should be empty. List any surviving tokens with the files they sit in.

## Step 5 — Report

Print:

- the table of applied values
- the list of removed modules
- what is left to do by hand: fill in the glossary in `domain/ux-writing.spec.md`, the breakpoints in `domain/layout.spec.md`, review the Constitution in `core/project.spec.md §1`, add the Figma token to `.mcp.json`
- an offer for the first task: "want to try `/design.audit` on a frame?"

## What not to do

- Do not ask questions the environment already answers (git config, whether a vault exists, the contents of `.mcp.json`) — read them and offer them as defaults.
- Do not apply changes before the step 2 confirmation.
- Do not leave partially removed modules.
- Do not touch `core/project.spec.md §1.1 Overrides` — that belongs to the human.
