---
name: ddr-template
kind: template
purpose: Design Decision Record — capturing a choice between valid alternatives
owner: design-lead
---

# DDR-NNN · <The decision in one line>

```yaml
ddr_id: DDR-NNN
task_ref: <PROJECT_PREFIX>-NNN
status: proposed | accepted | superseded
supersedes: <DDR-NNN or ->
date: <YYYY-MM-DD>
```

## Context

What is going on and why a decision was needed at all. Without context the record is useless six months from now: the "what" will be clear, the "why" will not.

The constraints in force at the time: deadlines, technical limits, existing patterns, agreements with engineering.

Platform and guideline claims behind the options link to the task's `research.md` (`workflows/research.spec.md`). An option resting on an unconfirmed claim says so.

## Options

### A — <name>
Description. **Pros:** … **Cons:** …

### B — <name>
Description. **Pros:** … **Cons:** …

"Leave it as it is" is also an option and deserves a line whenever it was considered.

## Decision

**<Option>** was chosen.

Why that one: which property tipped the balance. Not "it is better", but "it is better on <criterion>, because on this project <criterion> outweighs <other criterion>".

## Consequences

**Good:**
- <what became possible>

**Bad:**
- <what it cost — this list is mandatory; a decision with no price is not a decision>

**Affected consumers** (for DS changes):

| Screen / component | What needs doing | Task |
|---|---|---|

## Session journal

A `proposed` DDR is extended by appending lines here, never by rewriting the sections above: `> Added in session <date>: …`. An `accepted` or `superseded` DDR is immutable; a correction is a new DDR with `supersedes:` (`workflows/artifact-discipline.spec.md §2`).

## When to revisit

The condition under which the decision stops being right: "if a third breakpoint appears", "if the library moves to 3.0". Without this, a DDR becomes permanent law.
