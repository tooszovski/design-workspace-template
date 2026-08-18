---
name: tokens-export
layer: domain
purpose: Exporting Figma variables to tokens, format, platform transforms, syncing with code
applies_to:
  paths: ["exports/tokens/**", "<TOKENS_EXPORT_PATH>"]
  task_keywords: ["tokens", "export", "style dictionary", "sync", "variable export"]
  triggers: ["task moves design values into code"]
owner: figma-analyst
---

# Tokens Export

Tokens are a machine-readable projection of Figma variables. There is one source: `<FIGMA_DS_FILE_KEY>`. Hand-editing tokens is forbidden — the next export overwrites them.

## The pipeline

```
Figma variables → /design.tokens → exports/tokens/*.json → transform → <TOKENS_EXPORT_PATH>
```

Every step is reproducible: rerunning on an unchanged file produces an identical result. A non-deterministic export (random key order, timestamps inside the file) destroys diffs and makes review impossible.

## Format

The base format is [DTCG](https://tr.designtokens.org/) (`$value` / `$type` / `$description`):

```json
{
  "action": {
    "primary": {
      "$type": "color",
      "$value": "{color.blue.500}",
      "$description": "Primary action on a screen"
    }
  }
}
```

Rules:

- Aliases stay as `{path.to.token}` references and are never resolved into values. Resolving them kills the link and makes rebranding a manual job.
- One file per collection: `primitives.json`, `semantic.json`, `spacing.json`, `radius.json`, `typography.json`.
- Modes (themes) live as separate files or as a `$extensions.modes` section; the choice is fixed here at init and does not change afterwards.
- Keys in `kebab-case`, order alphabetical.

## Platform transforms

| Platform | Output | Notes |
|---|---|---|
| Web | CSS custom properties / JS object | `--action-primary`; themes via `[data-theme]` |
| iOS | Swift constants / Asset Catalog | colors in an Asset Catalog with light and dark |
| Android | XML resources / Compose | `colors.xml`, `dimens.xml` |

A transform adds no values that Figma does not have and renames nothing — it only changes syntax. If a platform needs a value the DS lacks, that is a DS task, not an export-script task.

## Syncing

1. Export runs **after** the library is published, never before.
2. The result reaches `<TOKENS_EXPORT_PATH>` through a pull request, not a direct commit: engineering has to see the diff.
3. A token diff reads like an API diff. Removing or renaming a token is a breaking change (`workflows/versioning.spec.md`).
4. Divergence between Figma and `<TOKENS_EXPORT_PATH>` is `TOKEN_DRIFT`:

| Severity | When |
|---|---|
| MINOR | `$description` differs |
| IMPORTANT | a token value differs |
| CRITICAL | a token exists in code but was removed from Figma, or the reverse |

## What is not tokenized

Values unique to a single screen, coordinates inside illustrations, values of `🚧` experiments. A token with exactly one use is not a token — it is a constant in the wrong place.

## Cross-refs

- domain/variables.spec.md — the source of tokens
- workflows/versioning.spec.md — versions and breaking changes
- workflows/drift-check.spec.md — comparing against implementation
- core/workspace.spec.md — where exports live
