---
name: loader
purpose: Contract for on-demand spec loading by the orchestrator and agents, plus the frontmatter schema
schema_version: 2
---

# Loader Contract

**Goal:** shrink each agent's context budget and eliminate divergent readings of the same requirements.

## Bootstrap

Every agent in this workspace reads:

1. `CLAUDE.md` — the slim bootstrap, which points at INDEX and LOADER.
2. `specs/INDEX.md` — the trigger map.
3. Every `specs/core/*.spec.md` — **always loaded**.
4. Every `specs/**/*.spec.md` marked `always_loaded: true`, regardless of layer.

## Frontmatter schema (schema_version: 2)

### Required (`core/`, `domain/`, `workflows/`)

Templates in `per-task/` and `per-epic/` follow a separate schema — instead of `layer` they carry `kind: template`.

| Field | Type | Values |
|---|---|---|
| `name` | string | a unique kebab-case slug |
| `layer` | string | `core` / `domain` / `workflow` |
| `purpose` | string | one line: what and why |
| `owner` | string | `design-lead` / `figma-analyst` / `handoff-author` / `reviewer-designsystem` / `reviewer-a11y` / `reviewer-ux-copy` |

### Conditional

| Field | Required when | Values |
|---|---|---|
| `always_loaded` | `core/*` and any spec that always loads | `true` |
| `applies_to` | `domain/*` and `workflows/*` | object — see below |

### `applies_to` sub-fields

| Sub-field | Type | Purpose | Matching rule |
|---|---|---|---|
| `task_keywords` | `[string]` | words from the requirements, task title, or description | case-insensitive substring against `task.title + task.description` |
| `paths` | `[string]` (glob) | paths in scope, for specs that work with files (`code/`, `exports/`) | any `scope.paths[i]` matches any `applies_to.paths[j]` |
| `loaded_for_modes` | `[string]` | `layer: workflow` only — auto-load by mode | the mode is in the list |
| `task_attachments` | `[string]` | `figma_link` / `screenshot` / `reference` / `recording` | any attachment matches |
| `triggers` | `[string]` | free-form description for the LLM orchestrator, a fallback | orchestrator judgment, with the reason logged |

### Schema rules

- `task_keywords` are **lowercase** natural language, English by default. When `<DEV_LANGUAGE>` is not English, add local-language keywords alongside the English ones — requirements arrive in the local language while design terms stay English, and the loader matches either.
- `paths` are globs. In a design workspace they apply only to `code/**`, `exports/**`, and `<TOKENS_EXPORT_PATH>`; designs have no paths, and `task_keywords` plus `task_attachments` play that role instead.
- **Unknown fields are ignored** by the loader but are a smell — fix them at review time.

### Forbidden fields

| Field | Why | Use instead |
|---|---|---|
| `symbols` | inherited from the code template; a design has no symbols | `task_keywords` |
| `always_for_orchestrator` | duplicates `always_loaded` | `always_loaded: true` |
| `triggers_on_task_attachments` | renamed | `task_attachments` |

## Per-task bundle

> **Three SDD levels** (`core/project.spec.md §4`):
> - **PROJECT** — `core/*` (always loaded)
> - **EPIC** — `<PER_TASK_SPEC_LOCATION>/<epic-id>/epic.md`, attached when `task.epic_ref` is set
> - **TASK** — `<PER_TASK_SPEC_LOCATION>/<task-id>/spec.md`
>
> A DDR is attached when the pre-spec references specific DDR IDs.

Input: the task's `spec.md` (problem, scope, `task_keywords`, `mode`, `attachments`).

Algorithm:

1. **Always-loaded:** every `**/*.spec.md` with `always_loaded: true`.
2. **Mode-based workflows:** every `workflows/*.spec.md` whose `applies_to.loaded_for_modes` contains the current mode.
3. **Trigger-based workflows:**
   - `versioning` — when the task touches `<DS_LIBRARY_NAME>`
   - `checkpoint` — when `mode: full` or the estimate exceeds 2 hours
   - `drift-check` — when the task is about accepting an implementation
   - `clarify` — Standard/Full, before work starts
4. **Domain by keyword:** `domain/*.spec.md` whose `applies_to.task_keywords` intersect the task's keywords.
5. **Domain by attachment:** specs whose `applies_to.task_attachments` match `task.attachments`.
6. **Domain by path:** only for tasks touching `code/**` or `exports/**`.
7. **Domain defaults for any screen task:** `states`, `accessibility`, `layout` — they apply almost always; skip them only for pure token or asset tasks.
8. **Free-form fallback:** if nothing matched but the orchestrator judges `applies_to.triggers` relevant, include it and log the reason.
9. Deduplicate and hand the bundle to the agent.

## Subagent input contract

```
<spec-bundle>
core: [project, workspace, vault-contract, design-system, naming, git-policy, commits]
workflows: [task-modes, design-workflow, review-pipeline, ...]
domain: [states, accessibility, layout, ...]
task: <PER_TASK_SPEC_LOCATION>/<task-id>/spec.md
figma: <file-key> · <node-id> · <path to cache>
scope: <the task's frames>
</spec-bundle>
```

An agent receives **no** specs outside the bundle. If it needs another one mid-flight, it signals `REROUTE` with `SpecsMissing`; the orchestrator decides.

## Subagent output contract (lean return) — canonical

One format for every agent in this workspace:

```
Signal: COMPLETE | FAIL | REROUTE
Checkpoint: <path to the file holding the detail>
SpecsUsed: [specs that were loaded]
SpecsMissing: [specs that turned out to be needed but were not loaded]
```

`SpecsUsed` is for audit. `SpecsMissing` is loader feedback: triggers in `INDEX.md` and in the specs themselves get corrected from it.

## Convention: referencing other specs

A reference to another spec is a path relative to `specs/`:

- ✅ `see core/naming.spec.md`
- ❌ `see the "Naming" section` — ungreppable without a path

Integrity check: `grep -rE '\.spec\.md' specs/`.

## Validation

```bash
./scripts/validate-specs.sh
```

It checks that:

- every `.spec.md` has the required fields and a `layer` matching its directory
- no forbidden fields are present
- `loaded_for_modes` contains only `quick` / `standard` / `full`
- templates in `per-task/` and `per-epic/` carry `kind: template`
- every cross-ref resolves to an existing file
- no `<UPPER_CASE>` placeholders remain after init

Run it after any frontmatter change and after adding or renaming a spec.
