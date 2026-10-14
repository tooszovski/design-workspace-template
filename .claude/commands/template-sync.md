---
description: Reconcile the workspace scaffolding with its template — down (template → workspace), up (workspace → template), or both
argument-hint: [down|up|all]
allowed-tools: Read, Write, Edit, Grep, Glob, Bash
---

# /template-sync

Mode: $ARGUMENTS (default `all`). The rule is `specs/workflows/template-sync.spec.md`; read it first. Scaffolding = `specs/`, `.claude/`, `drills/`, `scripts/`, `CLAUDE.md`.

## down

1. Check the `template` remote (`git remote -v`). If it is missing, add the upstream from the spec's "Who is upstream" table. `git fetch template`.
2. Read `.template-sync`. No marker → take the current upstream head as the baseline after a manual pass over the whole tree.
3. `git diff <sha>..template/<branch> --stat -- specs .claude drills scripts CLAUDE.md README.md`, then the diff file by file.
4. For each file decide: take / adapt / reject. Keep this workspace's names, paths, and Constitution intact. When upstream is the sibling iOS template, adapt process rules to design and English, and reject code-only mechanics with the reason. A conflict with `core/project.spec.md §1` → reject with a reason, or a DDR.
5. Apply, run `./scripts/validate-specs.sh` (0 errors), add one line per file to `docs/template-sync.md` "Down", move the marker to the upstream head with today's date.
6. If `core/` or `workflows/` changed, run one task from `drills/typical-tasks.md` per `drills/README.md`.
7. Commit `docs: sync with template <short sha>`. In a design workspace this goes through a branch and PR; protected branches are pushed by a human (`core/git-policy.spec.md`).

## up

1. Read `docs/template-sync.md`, section "To send". Empty → check `git log` of the scaffolding since the last send and add what was missed.
2. For each line: generalize (strip design-only detail), find its place upstream (a clone of `template/<branch>`), apply it. Upstream has its own validator and INDEX.
3. Upstream: branch `feat/<workspace>-upstream-<date>`, PR into its default branch. Without access, leave a `git format-patch` in `docs/template-sync/` and a line with its path in the journal.
4. After the upstream merge, move the lines to "Sent upstream" with the sha.

## Output

Short: how many files were taken / adapted / rejected down, how many were sent up, the new marker, a link to the PR.
