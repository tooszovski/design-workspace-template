# Template sync

Upstream for process rules: `tooszovski/ai-workspace` `master`, the sibling iOS workspace template (remote `template`). Marker: `.template-sync`. Rule: `specs/workflows/template-sync.spec.md`.

Design workspaces built from this template use this repository (`tooszovski/design-workspace-template` `main`) as their upstream instead.

## To send

| Date | File / section | Gist | Label |
|---|---|---|---|
| 2026-10-14 | `.claude/hooks/template-sync-check.sh` | Check both `template/master` and `template/main`; read a local clone only from an explicit `TEMPLATE_DIR`, not a hardcoded path | generic |
| 2026-10-14 | `specs/workflows/team-dispatch.spec.md` §Model routing | State that an agent without a `model:` field runs on the session model; the upstream text claims the field is pinned while no agent sets it | generic |

## Sent upstream

| Date | File / section | Upstream commit |
|---|---|---|
| 2026-10-14 | `workflows/drift-check.spec.md` — comparing the build against the design as its own task after implementation | 834f7f7 |
| 2026-10-14 | `workflows/versioning.spec.md` — versioning public surfaces like an API: change classes, changelog, deprecation, consumer migration | 834f7f7 |
| 2026-10-14 | `scripts/validate-specs.sh` — warn level: unfilled placeholders, spec missing from INDEX, core spec without `always_loaded` | 834f7f7 |
| 2026-10-14 | `domain/states.spec.md` + task template §6a — failure modes inside states: how the user gets out of each state | 834f7f7 |
| 2026-10-14 | `spec:sensitive` marking — sensitive fields named in the spec and masked in previews | 834f7f7 |
| 2026-10-14 | `drills/` — fixed typical tasks plus the scoring rubric for regression runs of the scaffolding | 834f7f7 |

## Down

Range `efc2879..834f7f7`. Items marked "morning port" were brought over earlier on 2026-10-14 and verified in this sync.

| Date | Upstream commit | File | Taken / adapted / rejected | Reason |
|---|---|---|---|---|
| 2026-10-14 | 834f7f7 | specs/workflows/template-sync.spec.md | adapted | English; upstream table: this template syncs with the sibling iOS template, design workspaces sync with this template; label `design-only`; G7 also covers direct commits to the template |
| 2026-10-14 | 834f7f7 | .claude/hooks/template-sync-check.sh | adapted | English; checks `template/master` and `template/main`; local clone only via `TEMPLATE_DIR` |
| 2026-10-14 | 834f7f7 | .claude/settings.json | adapted | SessionStart hook added next to the local push guard |
| 2026-10-14 | 834f7f7 | .claude/commands/template-sync.md | adapted | English; design paths; sibling-template guidance; branch and PR rule follows local git-policy |
| 2026-10-14 | 834f7f7 | specs/workflows/handoff-quality.spec.md | adapted | G7 Upstream added as a conditional seventh gate; the `[DEVICE]` line, the PR Privacy section, and the drift-check line rejected: device checks are code-only, privacy is covered by `A11Y-PRIVACY-CHECKLIST.md` in the DoR, drift-check is triggered by the loader |
| 2026-10-14 | 834f7f7 | CLAUDE.md | adapted | template-sync hard rule, `/template-sync` command, provenance step 8, artifact-discipline rule; research line is a morning port; security, device, anti-slop gate, and `code_base_branch` lines rejected as code-only |
| 2026-10-14 | 834f7f7 | README.md | adapted | template-sync paragraph and tree entries |
| 2026-10-14 | 834f7f7 | specs/workflows/verify.spec.md | adapted | design checks: validator, audit, fresh export, gates, node existence, AC to frame links, DDR links; build, test, lint, coverage, and bundle checks rejected as code-only |
| 2026-10-14 | 834f7f7 | specs/workflows/artifact-discipline.spec.md | adapted | checkboxes link to nodes, files, or commits; DDR `accepted`/`superseded` immutable; four checks after splitting a brief; session start and end protocols for Figma work |
| 2026-10-14 | 834f7f7 | specs/workflows/checkpoint.spec.md | adapted | session handover section added with Figma files and `lastModified`; the `estimated_time` yaml field rejected, the local trigger stays "estimate above 2 hours" |
| 2026-10-14 | 834f7f7 | specs/per-task/ADR-TEMPLATE.md | adapted | only the session journal and immutability went into `per-task/DDR-TEMPLATE.md`; plan, final re-check, and code status model rejected |
| 2026-10-14 | 834f7f7 | specs/workflows/anti-slop.spec.md | adapted | only the Text signs S-17..S-20 went into `workflows/critique.spec.md` §6 and `reviewer-ux-copy`; S-01..S-16 rejected as code and test signs |
| 2026-10-14 | 834f7f7 | .claude/agents/reviewer-slop.md | rejected | no separate slop reviewer; text signs live in critique and the copy reviewer |
| 2026-10-14 | 834f7f7 | specs/workflows/team-dispatch.spec.md | adapted | model routing with design roles and signals (automatic-Full zones replace risky domains), inbox drain, crash recovery |
| 2026-10-14 | 834f7f7 | specs/workflows/task-modes.spec.md | adapted | explicit mode is a starting point, only a human downgrades (replaces the local "de-escalation forbidden"), escalation recorded in three places; the `risky_domain` table rejected, the local automatic-Full list covers it |
| 2026-10-14 | 834f7f7 | specs/LOADER.md | adapted | whole-token `task_keywords` matching over title, problem, and scope without the out list; short-keyword error; warn-level list; the `symbols`, `./ios` paths, ADR index, and task-spec yaml rules rejected as code-only |
| 2026-10-14 | 834f7f7 | scripts/validate-specs.sh | adapted | took the short-keyword error and the `--keywords` dry run (`keyword_hits` reads DESIGN-TASK and QUICK sections); "not in INDEX" and "core without always_loaded" were already here, this is where upstream got them; ADR index, `./ios` path, and task-spec yaml checks rejected |
| 2026-10-14 | 834f7f7 | specs/INDEX.md | adapted | template-sync, verify, artifact-discipline added; code rows rejected |
| 2026-10-14 | 834f7f7 | specs/workflows/research.spec.md | adapted | morning port, verified |
| 2026-10-14 | 834f7f7 | specs/per-task/SECURITY-CHECKLIST.md | adapted | morning port as `per-task/A11Y-PRIVACY-CHECKLIST.md`, verified |
| 2026-10-14 | 834f7f7 | specs/per-task/STORY-TEMPLATE.spec.md | adapted | morning port: failure modes as §6a of the design task template, `spec:sensitive`; code yaml fields rejected |
| 2026-10-14 | 834f7f7 | specs/per-task/README.md | adapted | morning port, verified |
| 2026-10-14 | 834f7f7 | specs/workflows/review-pipeline.spec.md | adapted | morning port: four control questions; reviewer-slop ordering rejected |
| 2026-10-14 | 834f7f7 | drills/README.md | adapted | morning port, verified |
| 2026-10-14 | 834f7f7 | drills/typical-tasks.md | adapted | morning port, verified |
| 2026-10-14 | 834f7f7 | specs/workflows/drift-check.spec.md | rejected | originated here; the local design version is more precise for design acceptance |
| 2026-10-14 | 834f7f7 | specs/workflows/versioning.spec.md | rejected | originated here; the upstream version is rewritten for code modules and API contracts |
| 2026-10-14 | 834f7f7 | .claude/commands/drift-check.md | rejected | the local `/design.drift` covers it and is the origin |
| 2026-10-14 | 834f7f7 | specs/workflows/agent-log.spec.md | rejected | Privacy and Drift sections are code-side; sensitive data is covered by `a11y-privacy.md` and `spec:sensitive`, drift-check is a separate later task |
| 2026-10-14 | 834f7f7 | specs/workflows/clarify.spec.md | rejected | the roadmap-decision and SDK-stamp checks lean on code `design.md` and ADRs; reconsider if design epics need a roadmap check |
| 2026-10-14 | 834f7f7 | specs/per-task/QUICK-TEMPLATE.spec.md | rejected | code yaml fields: `estimated_time`, `contract_change`, `risky_domain`, branch, targets |
| 2026-10-14 | 834f7f7 | specs/workflows/spec-authoring.spec.md | rejected | no spec-author role here; the design lead writes the pre-spec |
| 2026-10-14 | 834f7f7 | .claude/agents/spec-author.md | rejected | no spec-author role; its research and checklist hooks went into `design-lead` in the morning port |
| 2026-10-14 | 834f7f7 | specs/workflows/decomposition.spec.md | rejected | `tasks.md` is a code artifact; the four breakdown checks live in `workflows/artifact-discipline.spec.md` §3 |
| 2026-10-14 | 834f7f7 | specs/workflows/task-workflow.spec.md | rejected | code task steps; `workflows/design-workflow.spec.md` is the local equivalent |
| 2026-10-14 | 834f7f7 | specs/workflows/tdd-contract.spec.md | rejected | TDD, code only |
| 2026-10-14 | 834f7f7 | specs/domain/testing.spec.md | rejected | code tests |
| 2026-10-14 | 834f7f7 | specs/domain/device-verification.spec.md | rejected | `[DEVICE]` rows verify built apps on hardware, code only |
| 2026-10-14 | 834f7f7 | specs/domain/di.spec.md | rejected | code only |
| 2026-10-14 | 834f7f7 | specs/domain/swiftui.spec.md | rejected | code only |
| 2026-10-14 | 834f7f7 | specs/core/no-comments.spec.md | rejected | code comments, no design counterpart |
| 2026-10-14 | 834f7f7 | specs/core/project.spec.md | rejected | C-14 and code DoD; the local Constitution D-01..D-14 stands |
| 2026-10-14 | 834f7f7 | specs/core/workspace.spec.md | rejected | `code_base_branch` and `./ios` layout |
| 2026-10-14 | 834f7f7 | specs/core/git-policy.spec.md | rejected | code base-branch rules |
| 2026-10-14 | 834f7f7 | specs/workflows/gitflow.spec.md | rejected | code gitflow |
| 2026-10-14 | 834f7f7 | specs/workflows/codex-review.spec.md | rejected | Codex code review |
| 2026-10-14 | 834f7f7 | scripts/codex-review.sh | rejected | Codex code review |
| 2026-10-14 | 834f7f7 | scripts/codex-adversarial.prompt | rejected | Codex code review |
| 2026-10-14 | 834f7f7 | .claude/hooks/git-push-guard.sh | rejected | code branch model; the local guard for integration and release branches stays |
| 2026-10-14 | 834f7f7 | scripts/test-push-guard.sh | rejected | tests for the code push guard |
| 2026-10-14 | 834f7f7 | scripts/init.sh | rejected | the Nextcloud vault path fix is already here (18275b3) |
| 2026-10-14 | 834f7f7 | docs/adr/README.md | rejected | code ADR index; DDRs live in task folders |
| 2026-10-14 | 834f7f7 | .claude/agents/coder.md | rejected | code role |
| 2026-10-14 | 834f7f7 | .claude/agents/reviewer-concurrency.md | rejected | code role |
| 2026-10-14 | 834f7f7 | .claude/agents/reviewer-networking.md | rejected | code role |
| 2026-10-14 | 834f7f7 | .claude/agents/reviewer-swiftui.md | rejected | code role |
| 2026-10-14 | 1c0b6d5 | .claude/agents/tech-lead.md, .claude/commands/speckit.implement.md | reject | code roles only: Step 6/8 end with a PR instead of a local merge |
