---
name: verify
layer: workflow
purpose: Single source of truth for checks — the minimum before a commit, the full final re-check before closing an artifact (task delivered, DDR accepted, epic closed), the closing algorithm
applies_to:
  loaded_for_modes: ["quick", "standard", "full"]
  task_keywords: ["verify", "re-check", "closing", "close the task", "definition of done", "archive"]
owner: design-lead
---

# Verify

One list of checks. The DoD (`core/project.spec.md §2`), the handoff gates (`workflows/handoff-quality.spec.md`), and the DDR template point here. If any check fails, the task state and the DDR `status` **stay as they are**.

## §1. Minimum before a commit

```bash
./scripts/validate-specs.sh        # 0 errors
git status                         # no stray files: no PNG mockups, no .figma-cache/, no *-plan.md
```

If the commit touches the scaffolding, the `Upstream` lines exist (G7, `workflows/template-sync.spec.md`).

## §2. Minimum before closing an artifact

- `/design.audit` on the delivered frames: zero CRITICALs, zero detached instances, zero hardcoded values outside `🚧` and `spec:` layers.
- The Figma export is fresh: the cached export's `lastModified` matches the file. A stale cache is re-exported, not trusted (`workflows/checkpoint.spec.md`).
- Gates G1–G6 pass in order, plus G7 when the scaffolding changed (`workflows/handoff-quality.spec.md`).

## §3. Full final re-check

- **Every referenced node exists.** Every Figma node id in `spec.md`, `handoff.md`, DDRs, and the coverage matrix resolves in the current file. A node that is gone is a FAIL, not "renamed along the way".
- **Every AC is covered.** Each AC in §5 of the pre-spec maps to a frame or a prototype flow, with the link written next to it (`✅ <node id or frame name>`). An AC with no frame is open.
- **The coverage matrix is closed.** No empty cells, every `n/a` has a reason, every applicable failure mode in §6a maps to a frame or a handoff line.
- **Accessibility measured, not assumed.** Contrast numbers recorded per mode; `a11y-privacy.md` complete when the screen required it (`per-task/A11Y-PRIVACY-CHECKLIST.md`).
- **Constitution spot-check** against `core/project.spec.md §1`: no hardcoded values, no detached copies of components, realistic content, one primary action, terms from the glossary.
- **Public DS surface.** No unrecorded change to a public component or a semantic variable. A breaking change has a DDR, a version bump, and a consumer list (`workflows/versioning.spec.md`).
- **Links resolve.** Referenced DDRs exist and are not `superseded`. Links in `spec.md`, `handoff.md`, and `epic.md` are not broken, checked by grep.
- **Text passes critique §Text** (`workflows/critique.spec.md`): S-17..S-20 in the spec, DDRs, handoff, and UI copy.
- **agent-log.** The task's `agent-log.md` exists (`workflows/agent-log.spec.md`).
- **Everything ran in this session.** Each item above was checked in the current session, not "remembered from yesterday".

## §4. Closing algorithm (one for tasks, DDRs, and epics)

1. Every checklist item (DoR, DoD, coverage matrix, epic breakdown, DDR consumer table) is `[x]` with a `✅` link (`workflows/artifact-discipline.spec.md §1`).
2. Every item in §3 was checked **in the current session**.
3. Any item fails → record it in the artifact → uncheck the related `[x]` with the reason → fix → re-check.
4. Only after a fully green re-check: move the task to `<TRACKER_TESTING_STATUS>`, set the DDR to `accepted`, or close the epic.
5. After closing: the final `worklog.md` entry is `— DONE: ...` (`core/vault-contract.spec.md`), links from indexes to the task folder still resolve, and the closed artifacts are not edited again (`workflows/artifact-discipline.spec.md §2`).

## Cross-refs

- core/project.spec.md — §2 DoD, which these checks operationalize
- workflows/handoff-quality.spec.md — gates G1–G7
- workflows/artifact-discipline.spec.md — checkbox discipline, session protocols
- workflows/agent-log.spec.md — the agent-log required before closing
- per-task/DDR-TEMPLATE.md — DDR status model
