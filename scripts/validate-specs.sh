#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# design-workspace — validate-specs.sh
#
# Checks spec-structure integrity against the specs/LOADER.md contract:
#   • required frontmatter fields
#   • layer matches the directory
#   • no forbidden fields
#   • loaded_for_modes limited to quick/standard/full
#   • templates carry kind: template
#   • cross-refs resolve to existing files
#   • no <UPPER_CASE> placeholders remain
#
# Run after any frontmatter change or spec rename.
# ─────────────────────────────────────────────────────────────────────────────

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"
SPECS_DIR="$WORKSPACE_DIR/specs"

C_RED='\033[0;31m'; C_GREEN='\033[0;32m'; C_YELLOW='\033[0;33m'
C_BLUE='\033[0;34m'; C_DIM='\033[2m'; C_BOLD='\033[1m'; C_OFF='\033[0m'

ERRORS=0; WARNINGS=0

err()  { printf "${C_RED}✗${C_OFF} %s\n" "$1"; ERRORS=$((ERRORS+1)); }
warn() { printf "${C_YELLOW}!${C_OFF} %s\n" "$1"; WARNINGS=$((WARNINGS+1)); }
ok()   { printf "${C_GREEN}✓${C_OFF} %s\n" "$1"; }
sect() { printf "\n${C_BOLD}${C_BLUE}==> %s${C_OFF}\n" "$1"; }

[[ -d "$SPECS_DIR" ]] || { printf "${C_RED}specs/ not found in %s${C_OFF}\n" "$WORKSPACE_DIR"; exit 1; }

# Extracts a field value from frontmatter (the first --- ... --- block)
fm_get() {
    awk -v key="$2" '
        NR==1 && $0=="---" { inside=1; next }
        inside && $0=="---" { exit }
        inside {
            if ($0 ~ "^"key":") { sub("^"key":[[:space:]]*", ""); print; exit }
        }
    ' "$1"
}

has_frontmatter() { [[ "$(head -1 "$1")" == "---" ]]; }

# ─── Spec frontmatter ────────────────────────────────────────────────────────
sect "Frontmatter: core / domain / workflows"

FORBIDDEN_FIELDS="symbols always_for_orchestrator triggers_on_task_attachments"

for layer_dir in core domain workflows; do
    [[ -d "$SPECS_DIR/$layer_dir" ]] || continue
    expected_layer="$layer_dir"
    [[ "$layer_dir" == "workflows" ]] && expected_layer="workflow"

    for f in "$SPECS_DIR/$layer_dir"/*.spec.md; do
        [[ -e "$f" ]] || continue
        rel="${f#$WORKSPACE_DIR/}"

        has_frontmatter "$f" || { err "$rel — no frontmatter"; continue; }

        for field in name layer purpose owner; do
            [[ -n "$(fm_get "$f" "$field")" ]] || err "$rel — missing required field '$field'"
        done

        actual_layer=$(fm_get "$f" layer)
        [[ "$actual_layer" == "$expected_layer" ]] || \
            err "$rel — layer '$actual_layer', expected '$expected_layer'"

        for bad in $FORBIDDEN_FIELDS; do
            grep -qE "^\s{0,4}${bad}:" "$f" && err "$rel — forbidden field '$bad' (see LOADER.md)"
        done

        if grep -q "loaded_for_modes:" "$f"; then
            modes=$(grep -A0 "loaded_for_modes:" "$f" | sed 's/.*loaded_for_modes:[[:space:]]*//')
            for m in $(printf '%s' "$modes" | tr -d '[]",' ); do
                case "$m" in
                    quick|standard|full|"") ;;
                    *) err "$rel — invalid mode '$m' (only quick/standard/full)" ;;
                esac
            done
        fi

        if [[ "$layer_dir" == "core" ]]; then
            [[ "$(fm_get "$f" always_loaded)" == "true" ]] || \
                warn "$rel — core spec without 'always_loaded: true'"
        fi
    done
done

SPEC_COUNT=$(find "$SPECS_DIR"/{core,domain,workflows} -name '*.spec.md' 2>/dev/null | wc -l | tr -d ' ')
ok "specs checked: $SPEC_COUNT"

# ─── Templates ───────────────────────────────────────────────────────────────
sect "Templates: per-task / per-epic"

for f in "$SPECS_DIR"/per-task/*.md "$SPECS_DIR"/per-epic/*.md; do
    [[ -e "$f" ]] || continue
    base=$(basename "$f")
    [[ "$base" == "README.md" ]] && continue
    rel="${f#$WORKSPACE_DIR/}"
    has_frontmatter "$f" || { err "$rel — no frontmatter"; continue; }
    [[ "$(fm_get "$f" kind)" == "template" ]] || err "$rel — missing 'kind: template'"
done
ok "templates checked"

# ─── Cross-refs ──────────────────────────────────────────────────────────────
sect "Cross-refs"

BROKEN=0
while IFS= read -r line; do
    src="${line%%:*}"
    ref="${line#*:}"
    [[ -f "$SPECS_DIR/$ref" ]] || { err "${src#$WORKSPACE_DIR/} → missing specs/$ref"; BROKEN=$((BROKEN+1)); }
done < <(
    grep -rhoE '^.*$' /dev/null 2>/dev/null
    for f in $(find "$SPECS_DIR" -name '*.md'); do
        grep -oE '(core|domain|workflows|per-task|per-epic)/[a-zA-Z0-9._-]+\.(spec\.)?md' "$f" 2>/dev/null \
            | sort -u | sed "s|^|$f:|"
    done
)
(( BROKEN == 0 )) && ok "every reference resolves"

# ─── Placeholders ────────────────────────────────────────────────────────────
sect "Placeholders"

# Documentation example tokens — not real placeholders
DOC_TOKENS='<FILE_KEY>|<NODE_ID>|<UPPER_CASE>|<VAULT>|<KEY>|<MAJOR>|<MINOR>|<PATCH>|<CODE>|<N>'

# Optional: left unfilled when the corresponding module is off
OPT_TOKENS='<CODE_REPO_PATH>|<TOKENS_EXPORT_PATH>|<REFERENCE_PLATFORM>|<FIGMA_DS_FILE_KEY>|<FIGMA_PRODUCT_FILE_KEY>'

ALL=$(grep -rhoE '<[A-Z][A-Z_]{2,}>' "$SPECS_DIR" "$WORKSPACE_DIR/CLAUDE.md" "$WORKSPACE_DIR/README.md" 2>/dev/null \
    | grep -vE "^($DOC_TOKENS)$" | sort -u)
REQUIRED=$(printf '%s' "$ALL" | grep -vE "^($OPT_TOKENS)$" || true)
OPTIONAL=$(printf '%s' "$ALL" | grep -E "^($OPT_TOKENS)$" || true)

if [[ -n "$REQUIRED" ]]; then
    warn "workspace not configured — required placeholders are unfilled:"
    printf "${C_DIM}%s${C_OFF}\n" "$(printf '%s' "$REQUIRED" | sed 's/^/    /')"
    printf "${C_DIM}    run /design.init or ./scripts/init.sh${C_OFF}\n"
else
    ok "required placeholders are filled in"
fi

if [[ -n "$OPTIONAL" ]]; then
    printf "${C_DIM}    unfilled optional placeholders (those modules are off):${C_OFF}\n"
    printf "${C_DIM}%s${C_OFF}\n" "$(printf '%s' "$OPTIONAL" | sed 's/^/      /')"
fi

# ─── INDEX ───────────────────────────────────────────────────────────────────
sect "INDEX.md"

if [[ -f "$SPECS_DIR/INDEX.md" ]]; then
    MISSING_IN_INDEX=0
    for f in $(find "$SPECS_DIR"/{core,domain,workflows} -name '*.spec.md' 2>/dev/null); do
        rel="${f#$SPECS_DIR/}"
        grep -qF "$rel" "$SPECS_DIR/INDEX.md" || { warn "$rel is not listed in INDEX.md"; MISSING_IN_INDEX=$((MISSING_IN_INDEX+1)); }
    done
    (( MISSING_IN_INDEX == 0 )) && ok "every spec is listed in INDEX.md"
else
    err "specs/INDEX.md is missing"
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
printf "\n${C_BOLD}Summary:${C_OFF} errors ${C_RED}%d${C_OFF}, warnings ${C_YELLOW}%d${C_OFF}\n" "$ERRORS" "$WARNINGS"
(( ERRORS > 0 )) && exit 1
exit 0
