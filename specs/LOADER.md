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
| `task_keywords` | `[string]` | words and phrases from the task text | **whole tokens**, not substrings — see §Matching `task_keywords` |
| `paths` | `[string]` (glob) | paths in scope, for specs that work with files (`code/`, `exports/`) | any `scope.paths[i]` matches any `applies_to.paths[j]` |
| `loaded_for_modes` | `[string]` | `layer: workflow` only — auto-load by mode | the mode is in the list |
| `task_attachments` | `[string]` | `figma_link` / `screenshot` / `reference` / `recording` | any attachment matches |
| `triggers` | `[string]` | free-form description for the LLM orchestrator, a fallback | orchestrator judgment, with the reason logged |

### Matching `task_keywords`

Matching works on **whole words (tokens)**, not substrings: a substring match on short keywords (`text`, `mode`, `state`, `file`) catches almost any spec and loads domain specs into tasks that have nothing to do with them.

- **Task text** = the H1 title + §1 "The user problem" + §3 "Scope" **up to** the `**Out:**` list of a DESIGN-TASK spec (QUICK: H1 + "What changes" + "Why" + "Boundaries"). The out list names what the task does not touch and is not matched; the rest of the spec (AC, state matrix, failure modes) is not matched either — `task_attachments`, `paths`, and the screen-task defaults cover it.
- **Tokenizing:** text and keyword are lowercased and split on every character that is not a letter (any alphabet) or a digit. `auto-layout` → `auto`, `layout`; `[DEVICE]` → `device`; `dark mode` → `dark`, `mode`.
- **A match:** all of a keyword's tokens appear in the text consecutively and in order. A one-word keyword is one whole token (`mode` does not match `modes`, `state` does not match `statement`, `icon` does not match `iconography`).
- **No morphology:** a keyword must match a real word form. List the common forms in `applies_to.task_keywords` (`component`, `components`), not a stem. When `<DEV_LANGUAGE>` is not English, the same applies to local-language keywords.
- The reference implementation is `keyword_hits` in `scripts/validate-specs.sh`; `./scripts/validate-specs.sh --keywords <spec.md>` prints which domain specs fire for that task spec and on which words.

### Schema rules

- `task_keywords` are **lowercase** natural language, English by default. A one-word keyword shorter than 3 characters is a validator error; words that appear in almost any spec (`screen`, `design`, `user`, `button`) do not go into keywords. When `<DEV_LANGUAGE>` is not English, add local-language keywords alongside the English ones — requirements arrive in the local language while design terms stay English, and the loader matches either.
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
   - `research` — Standard/Full, when the task leans on a platform pattern, component, or symbol new to the product, or the requirements assert platform behavior
4. **Domain by keyword:** `domain/*.spec.md` with at least one `applies_to.task_keywords` entry matching the **task text** by the §Matching rules (whole tokens; text = title + problem + scope without the out list).
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
- `task_keywords` in domain specs: no one-word keyword shorter than 3 characters

At **warn** level (printed, exit code unchanged):

- unfilled `<UPPER_CASE>` placeholders: required ones (the workspace is not configured — `/design.init`) and optional ones for modules that are off, printed separately
- a spec in `core/`, `domain/`, or `workflows/` not listed in `INDEX.md`
- a `core/` spec without `always_loaded: true`

`./scripts/validate-specs.sh --keywords <spec.md>` is not a check but a loader dry run on keywords: it prints the domain specs that fire for the task and the matched words.

Run it after any frontmatter change, after adding or renaming a spec, and before handing a task spec over.
