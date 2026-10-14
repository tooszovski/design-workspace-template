---
name: critique
layer: workflow
purpose: Design critique — what to examine, the text check S-17..S-20 for design docs and UI copy, finding format, distinguishing critique from taste
applies_to:
  task_keywords: ["critique", "design review", "walkthrough", "slop", "anti-slop"]
  loaded_for_modes: ["standard", "full"]
owner: design-lead
---

# Design Critique

Critique asks whether the **design solves the problem**, not whether it is likeable. Checking compliance with rules is `/design.audit`, which is automatic and runs first.

## What gets examined

### 1. The problem

- Does the screen solve the user problem stated in `spec.md`?
- Is the primary action visible within a second (D-10)?
- Does the user understand first what they are meant to understand first?

### 2. Hierarchy

- Does the order of perception match the order of importance?
- Does secondary content compete with primary content on contrast and size?
- Does the grouping reflect meaning rather than build convenience (`domain/layout.spec.md`)?

### 3. Completeness

- Are the states built and meaningful (`domain/states.spec.md`)?
- Are edge cases shown on realistic data (D-09)?
- Does adaptivity cover the ends of the range (D-08)?

### 4. Consistency

- Does the pattern match how this is solved on other screens of the product?
- If it differs, is there a recorded reason in a DDR?
- Do the terms match the glossary (`domain/ux-writing.spec.md`)?

### 5. Buildability

- Can an engineer assemble this from existing components?
- What here is expensive, and is there a cheaper alternative with the same result?

### 6. Text (anti-slop S-17..S-20)

Applies to `spec.md`, DDRs, `epic.md`, `handoff.md`, `critique.md`, and the UI copy on the screen. Each sign is a defect until justified in one line in `agent-log.md`: the code, the file or frame, why it has to stay. The design lead checks the documents; `reviewer-ux-copy` checks the UI copy in its own pass. There is no separate slop reviewer.

| # | Sign | How it is caught |
|---|---|---|
| S-17 | A sentence that can be deleted with no loss of information: preambles, summaries, "it is worth noting" | review |
| S-18 | A claim without evidence: "clear", "intuitive", "accessible", "consistent" with no measurement, research link, or reference to a rule | review; a11y claims need the recorded contrast numbers |
| S-19 | Emoji, exclamations, promotional tone in UI copy and public text (handoff, release notes, store text). In workspace specs only the ✅/❌ marks on "do / don't" examples and the `🚧` / `✅` layer and page markers from `core/naming.spec.md` are allowed | grep for emoji, review |
| S-20 | Text diverging from the design: the spec or handoff describes a frame, state, component, or token that is not in Figma | review, node check against the fresh export |

Finding code: `COPY` for UI copy, `HANDOFF` for the handoff, `CRITIQUE` for other documents, with the sign number in the first line (`COPY: S-18 …`).

## Finding format

```
<CODE>: <what is wrong, in one sentence>
Severity: MINOR | IMPORTANT | CRITICAL
Where: <frame> · <layer or region>
Why: <the consequence for the user or for engineering>
Proposal: <a concrete action, not "think about it">
```

Finding codes are defined in the domain specs: `DS_VIOLATION`, `A11Y`, `A11Y_CONTRAST`, `LAYOUT`, `TYPO`, `COPY`, `STATE_MISSING`, `MOTION`, `ASSET`, `NAMING`, `STRUCTURE`, `HANDOFF`, `DESIGN_DRIFT`, `TOKEN_DRIFT`.

For critique without a formal code, use `CRITIQUE`.

## Before the verdict

The critique closes with the four control questions from `workflows/review-pipeline.spec.md` (non-existent references, contradicting numbers, missing alternatives, the lead's question) in the `Questions:` block. Question 3 is where critique and the DDR meet: a structural choice with no recorded alternative goes back to the author, not into the handoff.

## What critique is not

| Not a finding | Why |
|---|---|
| "I think blue would be better here" | no consequence stated |
| "Feels empty" | describes neither the problem nor a fix |
| "Make it prettier" | not verifiable |
| "Dribbble does it differently" | someone else's context is not an argument |

Every finding must answer "what breaks for the user or for engineering if this is not fixed". If it cannot, it is a preference; preferences go into a separate "Ideas" list, not into findings.

## Resolving disagreement

1. The author answers every finding: accepted, or rejected with a reason.
2. A rejected CRITICAL is a Tier 2 stop; a human decides (`workflows/decision-gates.spec.md`).
3. A dispute about a principle rather than a specific screen becomes a DDR and a spec edit. The same argument happening twice means there is a hole in the rules.

## Cross-refs

- workflows/review-pipeline.spec.md — who critiques and when
- workflows/decision-gates.spec.md — escalation
- per-task/DDR-TEMPLATE.md — recording the decision
- workflows/research.spec.md — primary sources behind platform claims
