---
name: quick-template
kind: template
purpose: Thin spec for Quick mode — editing 1-2 frames with no new components or states
owner: design-lead
---

# <PROJECT_PREFIX>-NNN · <Title>

```yaml
task_id: <PROJECT_PREFIX>-NNN
mode: quick
figma_file: <FIGMA_PRODUCT_FILE_KEY>
figma_nodes: [<node-id>]
```

## What changes

One or two sentences.

## Why

One sentence.

## Boundaries

Only these frames: `<list>`. Nothing else is touched.

## Checks

- [ ] `/design.audit` reports no CRITICALs
- [ ] Existing states are not broken
- [ ] Nothing came detached from the DS
- [ ] `worklog.md` closed with `— DONE: ...`

## Escalation

If it turns out that a new component is needed, a new state appeared, a product question surfaced, or the edit pulled in neighboring screens — **stop** and switch to `DESIGN-TASK-TEMPLATE.spec.md` with mode `standard`. Worklog entry: `— ESCALATE Quick→Standard, reason: ...`.
