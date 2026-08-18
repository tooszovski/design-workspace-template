---
name: decision-gates
layer: workflow
purpose: Tier 1 auto-proceed and Tier 2 hard stop — when the agent decides, when it asks
applies_to:
  task_keywords: ["decision", "gate", "stop", "ask", "escalation"]
  loaded_for_modes: ["quick", "standard", "full"]
owner: design-lead
---

# Decision Gates

Two tiers. Tier 1: the agent decides and continues, recording the decision. Tier 2: the agent stops and asks a human through `AskUserQuestion`.

## Tier 1 — auto-proceed

The decision is made independently and logged in the worklog as `— AUTO: ...`.

| Situation | Default decision |
|---|---|
| A choice between two equivalent DS components | the one used more often in the product |
| Spacing not specified in the requirements | the nearest scale value under the proximity law |
| Copy wording | per `domain/ux-writing.spec.md` |
| Order of secondary fields | as on existing comparable screens |
| Review returned MINORs only | close them or record them as debt |
| A state is clearly not applicable | mark `n/a` with a reason |

The rule: if the decision is easy to reverse and sets no precedent, it is Tier 1.

## Tier 2 — hard stop

Work halts and the question goes to a human. Continuing "at your own discretion" is forbidden.

| Trigger | Why |
|---|---|
| **Clarify needed** — a product question the sources of truth do not answer | design has no authority to invent a product rule |
| **Design direction choice** — several valid options with different consequences | that is a product decision, not an executor's |
| **Any CRITICAL finding** | blocking by definition |
| **Changing a public DS component** | a breaking change for every consumer (D-11) |
| **A write to Figma is required** | Claude is read-only (D-02) |
| **Scope violation** — an edit outside the declared frames | expanding the task without agreement |
| **Reroute limit** — 3 per pair or 5 per task | an edit loop means the problem is upstream |
| **Conflicting sources of truth** | the §3 table does not resolve the conflict |
| **A clarify answer changes the mode** | the task is no longer the one that was estimated |
| **No Figma MCP access** | continuing would mean guessing |

## Stop format

```markdown
## Tier 2 stop · <PROJECT_PREFIX>-NNN

**Trigger:** <which one from the table>
**Situation:** <2-3 sentences>
**Done so far:** <so the human does not lose context>
**Options:**
- A — <option> → <consequence>
- B — <option> → <consequence>
**Recommendation:** <which one and why>
**Blocked:** <what cannot continue without an answer>
```

The Recommendation line is mandatory: stopping without an opinion hands the whole job back to the human.

## What to do while stopped

Do not idle. Everything that does not depend on the answer gets finished: other states, copy, assets, a draft handoff. Only the dependent branch of work halts.

## Cross-refs

- workflows/clarify.spec.md — question format
- workflows/review-pipeline.spec.md — reroute limits
- core/project.spec.md §3 — sources of truth
