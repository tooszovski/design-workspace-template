---
name: git-policy
layer: core
purpose: What not to commit, branches, rebase, push rules in a design workspace
always_loaded: true
owner: design-lead
---

# Git Policy

The workspace repository stores **rules and specs**, not designs. Everything heavy or generated stays out of git.

## Never commit

| What | Why |
|---|---|
| `CLAUDE.md`, `AGENTS.md`, `.cursorrules` | agent instructions, not project artifacts |
| `*-plan.md`, `*-scratch.md` | session scratch files |
| `.mcp.json` | contains credentials; only `.mcp.json.example` is committed |
| `.figma-cache/` | Figma exports that go stale within hours |
| `exports/assets/**` | binaries, regenerated from Figma |
| `*.png`, `*.jpg`, `*.fig`, `*.sketch` | designs and mockups — they live in Figma |
| `/specs` | in Obsidian mode, specs live in the vault |
| `.claude/settings.local.json` | personal settings |
| `.DS_Store`, `*.log` | noise |

Exception: `exports/tokens/**` is committed when init chose to version tokens in this repository.

## Branches

| Branch | Role |
|---|---|
| `<RELEASE_BRANCH>` | stable rules; new projects are cut from here |
| `<INTEGRATION_BRANCH>` | integration of spec changes |
| `design/<PROJECT_PREFIX>-NNN-<slug>` | work on a task |
| `ds/<slug>` | design-system changes |

## Rules

- **Rebase, not merge commits** when pulling `<INTEGRATION_BRANCH>` into a working branch. Spec history should read linearly.
- **Push your own branches only.** `<INTEGRATION_BRANCH>`, `<RELEASE_BRANCH>`, and tags are pushed by a human. Enforced by the `.claude/hooks/git-push-guard.sh` hook.
- **No `--force`** on shared branches. On your own branch, only if nobody else has it.
- Changing `core/*.spec.md` warrants its own commit and a clear message — every agent reads those files.

## What to do with binaries

If an export needs to reach engineering, route it through `<CODE_REPO_PATH>` or file sharing, not through this repository. Assets in git turn a workspace clone into gigabytes within six months.

## Cross-refs

- core/commits.spec.md — message format
- core/workspace.spec.md — what lives where
