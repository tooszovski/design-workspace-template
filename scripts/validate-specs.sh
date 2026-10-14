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
#   • no one-word task_keywords shorter than 3 characters in domain specs
#   • warn: unfilled <UPPER_CASE> placeholders, spec missing from INDEX.md,
#     core spec without always_loaded
#
#   ./scripts/validate-specs.sh                      — every check, exit 0 clean / exit 1 errors
#   ./scripts/validate-specs.sh --keywords <spec.md> — loader dry run on task_keywords for a task
#                                                      spec (LOADER.md §Matching): which domain specs fire
#
# Run after any frontmatter change or spec rename. bash 3.2 (macOS), python3.
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

# Reference implementation of task_keywords matching (LOADER.md §Matching): whole tokens, phrases in order.
keyword_hits() { # <task spec.md> -> lines "<domain> <tab> <keyword>[, <keyword>...]"
    python3 - "$SPECS_DIR" "$1" <<'PYKW'
import glob, os, re, sys
specs_dir, task = sys.argv[1], sys.argv[2]
text = open(task, encoding="utf-8").read()
def tokens(s): return re.findall(r"[^\W_]+", s.lower())
body = re.sub(r"\A---\n.*?\n---\n", "", text, flags=re.S)
parts = []
m = re.search(r"^# (.+)$", body, re.M)
if m: parts.append(m.group(1))
for sec in re.split(r"^## ", body, flags=re.M)[1:]:
    title = sec.split("\n", 1)[0].strip()
    if re.match(r"(1\.|3\.|What changes|Why|Boundaries)", title):
        # the out list names what the task does NOT touch, so it is not matched
        parts.append(re.split(r"^\*\*Out:?\*\*", sec, flags=re.M)[0])
tt = tokens(" ".join(parts))
def hit(kw):
    kt = tokens(kw)
    n = len(kt)
    return n > 0 and any(tt[i:i + n] == kt for i in range(len(tt) - n + 1))
for f in sorted(glob.glob(os.path.join(specs_dir, "domain", "*.spec.md"))):
    fm = open(f, encoding="utf-8").read().split("---", 2)[1]
    m = re.search(r"^\s*task_keywords:\s*\[(.*?)\]\s*$", fm, re.M)
    if not m: continue
    hits = [k for k in re.findall(r'"([^"]+)"', m.group(1)) if hit(k)]
    if hits:
        print(f"{os.path.basename(f)[:-len('.spec.md')]}\t{', '.join(hits)}")
PYKW
}

if [[ "${1:-}" == "--keywords" ]]; then
    [[ -f "${2:-}" ]] || { echo "usage: $0 --keywords <PER_TASK_SPEC_LOCATION>/<task-id>/spec.md"; exit 2; }
    echo "keywords: domain specs that fire for $2 (LOADER.md §Matching):"
    out=$(keyword_hits "$2")
    if [[ -n "$out" ]]; then echo "$out" | sed 's/^/  /'; else echo "  (none — attachments, paths, and screen-task defaults only)"; fi
    exit 0
fi

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

# ─── task_keywords ───────────────────────────────────────────────────────────
sect "task_keywords (domain)"

SHORT=$(python3 - "$SPECS_DIR" <<'PYSHORT'
import glob, os, re, sys
for f in sorted(glob.glob(os.path.join(sys.argv[1], "domain", "*.spec.md"))):
    fm = open(f, encoding="utf-8").read().split("---", 2)[1]
    m = re.search(r"^\s*task_keywords:\s*\[(.*?)\]\s*$", fm, re.M)
    if not m: continue
    for kw in re.findall(r'"([^"]+)"', m.group(1)):
        if " " not in kw.strip() and len(kw.strip()) < 3:
            print(f'{os.path.relpath(f, os.path.dirname(sys.argv[1]))} — task_keyword "{kw}" is shorter than 3 characters; drop it or use a phrase')
PYSHORT
)
if [[ -n "$SHORT" ]]; then
    while IFS= read -r line; do err "$line"; done <<< "$SHORT"
else
    ok "no task_keywords shorter than 3 characters"
fi

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
    # find -L: specs/ may be a symlink into a vault; without -L find does not descend into it and the check passes vacuously
    for f in $(find -L "$SPECS_DIR" -name '*.md'); do
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
