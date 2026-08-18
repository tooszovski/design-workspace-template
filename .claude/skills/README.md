# `.claude/skills/`

Local skill bundles for this workspace. Empty by default — most work is covered by the specs in `specs/` and the commands in `.claude/commands/`.

## When to write a skill instead of a spec

| Skill | Spec |
|---|---|
| A step-by-step procedure the agent executes | A rule the agent must know |
| Needs its own scripts and resources alongside | Text is enough |
| Applies outside the context of a design task | Part of a task's workflow |

A design-system rule is a spec. A procedure like "generate an icon font from an SVG set" is a skill.

## What the commands already cover

`/design.init`, `/design.audit`, `/design.handoff`, `/design.tokens`, `/design.drift`, `/design.critique` live in `.claude/commands/`; there is no need to duplicate them as skills.

## Format

```
.claude/skills/<name>/SKILL.md
```

Frontmatter: `name` and `description` (when to use it — that text is how the skill gets selected). The body is the instruction. Supporting files sit alongside.
