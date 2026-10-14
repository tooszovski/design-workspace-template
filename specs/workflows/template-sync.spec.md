---
name: template-sync
layer: workflow
purpose: Two-way reconciliation of the scaffolding with its template — down (template → workspace) by marker and hook, up (workspace → template) through gate G7 on every change to the scaffolding
always_loaded: true
applies_to:
  loaded_for_modes: ["quick", "standard", "full"]
  paths: ["specs/**", ".claude/**", "drills/**", "scripts/**", "CLAUDE.md", ".template-sync", "docs/template-sync.md"]
  task_keywords: ["template", "template sync", "sync", "upstream", "scaffolding"]
owner: design-lead
---

# Template sync

The scaffolding drifts. Some edits made in a workspace are generic and belong in the template; some edits to the template belong in every workspace. This rule makes both flows mandatory and checkable.

Scaffolding = `specs/`, `.claude/` (agents, commands, hooks, `settings.json`), `drills/`, `scripts/`, `CLAUDE.md`. Designs, exports, and task artifacts are not scaffolding.

## Who is upstream

Two relationships, depending on where this file lives.

| Repository | Upstream | Remote `template` | Branch |
|---|---|---|---|
| **This template** (`tooszovski/design-workspace-template`) | the iOS workspace template `tooszovski/ai-workspace`, a **sibling template** and the source of process rules (gates, artifact discipline, loader, dispatch). Its code rules do not apply here. | `git@github.com:tooszovski/ai-workspace.git` | `master` |
| **A design workspace** built from this template | this template | `git@github.com:tooszovski/design-workspace-template.git` | `main` |

A sibling template is not a parent. Nothing comes down from it as is: every file is adopted, adapted to design, or rejected with a reason. Code-only mechanics (build, tests, TDD, device verification, push guards for code branches, code-review tooling) are rejected by default.

`/design.init` resets the marker and the remote for a new workspace: the remote becomes this template, and `sha` becomes the template commit the workspace was cloned from.

## Marker

`.template-sync` in the workspace root, one line:

```
sha=<40-hex upstream commit last reconciled against> date=<YYYY-MM-DD>
```

Committed. Updated only as the result of a down reconciliation.

## Down: upstream → here

**When.** The `.claude/hooks/template-sync-check.sh` hook prints a reminder at session start when upstream (`template/master` or `template/main`, or the local clone in `$TEMPLATE_DIR`) has moved past the marker's `sha`, or when the marker is older than 14 days. The reminder does not block work. Reconcile with `/template-sync down` at least every two weeks and before starting each epic.

**How.**

1. `git fetch template`.
2. `git diff <marker sha>..template/<branch> -- specs .claude drills scripts CLAUDE.md README.md`.
3. For each changed file, one of three: **take** as is, **adapt** (what was replaced and why), **reject** (reason: code-only, conflicts with the Constitution, a local rule is already more precise).
4. One line per file in `docs/template-sync.md`, section "Down". Move the marker to the upstream head.
5. `./scripts/validate-specs.sh` reports 0 errors. If `core/` or `workflows/` changed, run one task from `drills/typical-tasks.md` per `drills/README.md`.
6. One commit or PR: `docs: sync with template <short sha>`.

## Up: here → upstream (gate G7)

**When.** Every change that touches the scaffolding. Checked as G7 in `workflows/handoff-quality.spec.md` and part of the checklist before delivery. Applies in every mode, Quick included.

**How.** The PR description (or, for a direct commit to the template's `main`, the journal entry) carries an `Upstream` section, one line per changed scaffolding file, with a label:

- `generic` — goes upstream as is;
- `generic after generalizing: <what to strip>` — goes upstream after design-only detail is removed;
- `design-only: <why>` — stays here.

Every `generic` and `generic after generalizing` line is copied into `docs/template-sync.md`, section "To send", with the file, the section, and a one-sentence gist. That section is the queue: `/template-sync up` drains it with a PR to upstream, and once merged the line moves to "Sent upstream" with the upstream commit sha.

A change to the scaffolding without an `Upstream` section is not ready for delivery.

## One rule, two wordings

When the same rule lives here and upstream in different words, the more precise and checkable wording wins, and it is sent to the other side. Record the divergence in `docs/template-sync.md` at any reconciliation. The Constitution (`core/project.spec.md §1`) may tighten the template, never weaken it silently: weakening requires a DDR.

## Journal

`docs/template-sync.md`:

```
# Template sync

Upstream: <repo> <branch>. Marker: .template-sync.

## To send
| Date | File / section | Gist | Label |

## Sent upstream
| Date | File / section | Upstream commit |

## Down
| Date | Upstream commit | File | Taken / adapted / rejected | Reason |
```

## Cross-refs

- workflows/handoff-quality.spec.md — G7
- core/git-policy.spec.md — branches and pushes
- workflows/artifact-discipline.spec.md — session start and end protocols
