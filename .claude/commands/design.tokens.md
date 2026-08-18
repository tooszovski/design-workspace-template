---
description: Export Figma variables to design tokens and transform them per platform
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, mcp__figma__get_figma_data
---

# /design.tokens

Export `<FIGMA_DS_FILE_KEY>` → `exports/tokens/` → `<TOKENS_EXPORT_PATH>`.

## Preconditions

- The library is published. Exporting before publication ships unpublished values.
- MCP can reach the DS file.

## Step 1 — Export

Call `mcp__figma__get_figma_data` on file `<FIGMA_DS_FILE_KEY>`. Collect the collections: `Primitives`, `Semantic`, `Spacing`, `Radius`, `Typography` (`domain/variables.spec.md`).

For each variable, record the name, the type, the value in every mode, the alias (if it references another), and the description.

## Step 2 — Pre-write checks

| Check | Action on failure |
|---|---|
| A variable with no value in one of the modes | CRITICAL, stop: screens break in that theme |
| Semantic holding a raw hex instead of an alias | IMPORTANT, put it in the report |
| Alias chain longer than two hops | MINOR |
| A name off the `core/naming.spec.md` contract | IMPORTANT |

Exporting with a CRITICAL outstanding is forbidden — the broken value would reach the code.

## Step 3 — Write DTCG

`exports/tokens/<collection>.json`, in `$value` / `$type` / `$description` form:

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

Mandatory:

- Aliases stay as `{path.to.token}` references — **never resolve** them into values.
- Keys in `kebab-case`, alphabetical order.
- No timestamps and no random ordering inside the file: rerunning on an unchanged file must produce a byte-identical result.
- Modes follow the scheme fixed in `domain/tokens-export.spec.md` at init.

## Step 4 — Transform

Only when `<TOKENS_EXPORT_PATH>` is set. For each platform in `<PLATFORMS>`:

| Platform | Output |
|---|---|
| Web | CSS custom properties plus a JS object; themes via `[data-theme]` |
| iOS | Swift constants or an Asset Catalog with light and dark |
| Android | `colors.xml`, `dimens.xml`, or Compose |

A transform changes **syntax only**. It adds no values Figma does not have and renames nothing.

## Step 5 — Diff

Compare against the previous version in `<TOKENS_EXPORT_PATH>` and classify (`workflows/versioning.spec.md`):

| Change | Category |
|---|---|
| new token | additive |
| changed value | modifying |
| removed or renamed token | **breaking** |

Breaking → do not write silently. Show the list, require confirmation, and remind about the DDR and the changelog.

## Step 6 — Report

```
Signal: COMPLETE | FAIL
Checkpoint: exports/tokens/REPORT.md
Tokens: N · Added: A · Changed: M · Removed: D
Change category: additive | modifying | breaking
```

Writing to `<TOKENS_EXPORT_PATH>` goes through a pull request, not a direct commit: engineering has to see the diff.
