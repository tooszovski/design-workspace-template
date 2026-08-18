# A worked example

The mock task `ACM-142 · Product catalog` in the `AcmeShop` project. It shows **what** filled-in artifacts look like — not what to copy, but how much depth each document is expected to carry.

## The chain

```
epic-example.md          the "Catalog" section epic
    ↓
design-task-example.md   pre-spec for task ACM-142
    ↓
ddr-example.md           the decision about filters
    ↓
worklog-example.md       the work log, closed with DONE
    ↓
critique-example.md      findings from three reviewers
    ↓
handoff-example.md       the spec for engineering
    ↓
agent-log-example.md     the final report
```

## How to read it

| If you are unsure about | Look at |
|---|---|
| how deep a pre-spec should go | `design-task-example.md` §4–6 |
| what a filled state matrix looks like | `design-task-example.md` §6 |
| what counts as a real finding versus a preference | `critique-example.md` |
| how detailed a handoff should be | `handoff-example.md`, Behavior and Data |
| how to record a decision so it survives six months | `ddr-example.md` |
| what to write in a worklog as you go | `worklog-example.md` |

## What the example is not

Real Figma links or a real product — this is a mock. `AcmeShop`, `ACM`, and node ids like `1234:5678` are invented.

The examples are **not** rewritten for your project by `/design.init`: they stay as they are, serving as a reference for form.
