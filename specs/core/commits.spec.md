---
name: commits
layer: core
purpose: Conventional Commits for a design repository — scopes, author, language
always_loaded: true
owner: design-lead
---

# Commits

## Format

```
<type>(<scope>): <short description>
```

One line. **No body**, no bullet lists, no "why" — context lives in the task's `worklog.md`, not in git.

Description language is `<COMMIT_LANGUAGE>`. Author is `<GIT_USER_NAME> <<GIT_USER_EMAIL>>`.

## Types

| Type | When |
|---|---|
| `feat` | a new spec, a new component, a new rule |
| `fix` | correcting an error in a spec or in tokens |
| `docs` | README, comments, examples |
| `refactor` | restructuring specs without changing meaning |
| `chore` | scripts, configs, dependencies |
| `tokens` | updating exported tokens |

## Scopes

| Scope | Area |
|---|---|
| `core` | `specs/core/*` |
| `domain` | `specs/domain/*` |
| `workflow` | `specs/workflows/*` |
| `ds` | design-system rules |
| `a11y` | accessibility |
| `handoff` | specs for engineering |
| `tokens` | token export |
| `tooling` | scripts, `.claude/`, MCP |

## Examples

```
feat(domain): add form state spec
fix(a11y): correct minimum contrast for disabled
tokens(ds): update semantic palette to v2.3
docs(handoff): worked example of a screen spec
```

## Forbidden

- **Mentions of AI, agents, Claude, Codex** in messages or in the commit author.
- Co-authorship trailers naming a bot.
- Junk messages: `update`, `wip`, `fixes`, `.`.
- Multi-line messages enumerating everything done — that is a sign the commit should be split.

## Cross-refs

- core/git-policy.spec.md — what not to commit, branches
