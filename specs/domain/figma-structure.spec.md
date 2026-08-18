---
name: figma-structure
layer: domain
purpose: Figma file organization — pages, sections, statuses, cover, working through MCP
applies_to:
  task_keywords: ["figma", "file", "structure", "page", "section", "file navigation", "cover"]
  triggers: ["need to locate a frame inside a file", "audit of file organization"]
owner: figma-analyst
---

# Figma File Structure

## File roles

| File | Key | Contents |
|---|---|---|
| Design System | `<FIGMA_DS_FILE_KEY>` | Foundations, components, icons — published as a library |
| Product | `<FIGMA_PRODUCT_FILE_KEY>` | Product screens, consumes the library |

Mixing the roles is forbidden: a component that lives in the product file longer than one task is a candidate for the library (`core/design-system.spec.md`).

## Pages

Order and prefixes follow `core/naming.spec.md`:

| Page | Purpose | Audit status |
|---|---|---|
| `📐 Cover` | cover: name, owner, DS version, links | skipped |
| `🚧 WIP` | work in progress, unstable | audited only on request |
| `✅ <Section>` | delivered screens | **always audited** |
| `📦 Components` | components (DS file only) | audited |
| `🎨 Foundations` | color, type, spacing, effects | audited |
| `🗃 Archive` | obsolete | skipped |

A frame on `🚧 WIP` cannot be the source of a handoff. Moving it to `✅` is a claim of readiness and starts the DoD check.

## Sections within a page

Screens are grouped into sections by flow, not by creation date:

```
✅ Checkout
├── [Section] Cart
├── [Section] Delivery
├── [Section] Payment
└── [Section] Confirmation
```

One section is one step of the flow with all its states and breakpoints. Section order, left to right, mirrors the order the user experiences.

## The cover

`📐 Cover` carries the product name, the design owner, the consumed library version, the date of the last review, and links to requirements and to the repository. The agent reads the cover first — that is where the DS version for comparison comes from.

## Working through MCP

### The right order

1. Ask the human for the **file key plus node id** of the frame or section. Never pull a whole file without a node id.
2. `mcp__figma__get_figma_data` with `nodeId` → structure, layers, bindings to variables and styles.
3. Cache the response in `.figma-cache/<file-key>/<node-id>.json`.
4. `mcp__figma__download_figma_images` — only when you need a visual check (hierarchy, density, feel), not a composition check.

### Getting a node id

From a Figma link: `.../design/<FILE_KEY>/<name>?node-id=<NODE_ID>`. The URL uses a hyphen (`1234-5678`); the API uses a colon (`1234:5678`). Convert on request.

### Limits

- A response for a large section easily exceeds a workable context — request one frame at a time.
- If MCP is unavailable or the file is permission-locked, that is `FAIL: figma access`, not license to reconstruct the structure from guesswork (`core/workspace.spec.md`).

## Findings

| Code | Severity | When |
|---|---|---|
| `STRUCTURE` | MINOR | frame outside any section |
| `STRUCTURE` | IMPORTANT | a screen on a `✅` page missing breakpoints; sections that do not mirror flow order |
| `STRUCTURE` | CRITICAL | a handoff pointing at a frame on `🚧 WIP` or `🗃 Archive` |

## Cross-refs

- core/naming.spec.md — page and frame names
- domain/states.spec.md — which states a section must contain
- domain/handoff.spec.md — what reaches the engineering spec
