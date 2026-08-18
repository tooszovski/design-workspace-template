# `.claude/agents/`

Materialized roles from `specs/workflows/team-dispatch.spec.md`. Each file defines a subagent: frontmatter with tool restrictions plus a system prompt that leans on the specs.

## Files

| File | Role | Launched by |
|---|---|---|
| `design-lead.md` | orchestrator for a Standard/Full task | the entry point |
| `figma-analyst.md` | export and breakdown through MCP | design-lead, step 2 |
| `handoff-author.md` | writes `handoff.md` | design-lead, step 8 |
| `reviewer-designsystem.md` | DS compliance review | design-lead, step 7 |
| `reviewer-a11y.md` | accessibility review | design-lead, step 7 |
| `reviewer-ux-copy.md` | copy review | design-lead, step 7 |

## How to invoke

```
Agent({
  description: "Review catalog a11y",
  subagent_type: "reviewer-a11y",
  prompt: "Frames for task ABC-142, node 1234:5678. Focus: filter states."
})
```

Launch the three reviewers **in one message** — they are independent and must not wait on each other.

## What is missing, and why

- **A "designer" agent** — designs are built by a human. Claude is read-only in Figma (D-02), so an agent that draws cannot exist.
- **`reviewer-motion`** — motion comes up rarely; the check is folded into `design-lead` through `domain/prototyping.spec.md`. Add a dedicated one if the need appears.
- **`tokens-engineer`** — token export is deterministic and lives in the `/design.tokens` command; a separate agent buys nothing.

## Fallback

If the subagent system is unavailable, `design-lead` uses `general-purpose` with a briefing assembled from the specs. That is equivalent: `.claude/agents/*.md` is a convenience, not a contract.

## Maintenance

When specs change, sync the prompts. Agents read specs at runtime, but key rules are duplicated in the prompts for reliability — and a mismatch between the two is worse than no duplication at all.
