#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# design-workspace — validate-specs.sh
#
# Проверяет целостность spec-структуры по контракту specs/LOADER.md:
#   • обязательные поля frontmatter
#   • layer соответствует директории
#   • нет forbidden fields
#   • loaded_for_modes только quick/standard/full
#   • шаблоны имеют kind: template
#   • cross-refs резолвятся в существующие файлы
#   • не осталось placeholder'ов <UPPER_CASE>
#
# Запускать после любого изменения frontmatter или переименования спек.
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

[[ -d "$SPECS_DIR" ]] || { printf "${C_RED}specs/ не найден в %s${C_OFF}\n" "$WORKSPACE_DIR"; exit 1; }

# Извлекает значение поля из frontmatter (первый блок между --- ... ---)
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

# ─── 1. Frontmatter спек ─────────────────────────────────────────────────────
sect "Frontmatter: core / domain / workflows"

FORBIDDEN_FIELDS="symbols always_for_orchestrator triggers_on_task_attachments"

for layer_dir in core domain workflows; do
    [[ -d "$SPECS_DIR/$layer_dir" ]] || continue
    expected_layer="$layer_dir"
    [[ "$layer_dir" == "workflows" ]] && expected_layer="workflow"

    for f in "$SPECS_DIR/$layer_dir"/*.spec.md; do
        [[ -e "$f" ]] || continue
        rel="${f#$WORKSPACE_DIR/}"

        has_frontmatter "$f" || { err "$rel — нет frontmatter"; continue; }

        for field in name layer purpose owner; do
            [[ -n "$(fm_get "$f" "$field")" ]] || err "$rel — нет обязательного поля '$field'"
        done

        actual_layer=$(fm_get "$f" layer)
        [[ "$actual_layer" == "$expected_layer" ]] || \
            err "$rel — layer '$actual_layer', ожидался '$expected_layer'"

        for bad in $FORBIDDEN_FIELDS; do
            grep -qE "^\s{0,4}${bad}:" "$f" && err "$rel — forbidden field '$bad' (см. LOADER.md)"
        done

        if grep -q "loaded_for_modes:" "$f"; then
            modes=$(grep -A0 "loaded_for_modes:" "$f" | sed 's/.*loaded_for_modes:[[:space:]]*//')
            for m in $(printf '%s' "$modes" | tr -d '[]",' ); do
                case "$m" in
                    quick|standard|full|"") ;;
                    *) err "$rel — недопустимый mode '$m' (только quick/standard/full)" ;;
                esac
            done
        fi

        if [[ "$layer_dir" == "core" ]]; then
            [[ "$(fm_get "$f" always_loaded)" == "true" ]] || \
                warn "$rel — core-спека без 'always_loaded: true'"
        fi
    done
done

SPEC_COUNT=$(find "$SPECS_DIR"/{core,domain,workflows} -name '*.spec.md' 2>/dev/null | wc -l | tr -d ' ')
ok "проверено спек: $SPEC_COUNT"

# ─── 2. Шаблоны ──────────────────────────────────────────────────────────────
sect "Шаблоны: per-task / per-epic"

for f in "$SPECS_DIR"/per-task/*.md "$SPECS_DIR"/per-epic/*.md; do
    [[ -e "$f" ]] || continue
    base=$(basename "$f")
    [[ "$base" == "README.md" ]] && continue
    rel="${f#$WORKSPACE_DIR/}"
    has_frontmatter "$f" || { err "$rel — нет frontmatter"; continue; }
    [[ "$(fm_get "$f" kind)" == "template" ]] || err "$rel — нет 'kind: template'"
done
ok "шаблоны проверены"

# ─── 3. Cross-refs ───────────────────────────────────────────────────────────
sect "Cross-refs"

BROKEN=0
while IFS= read -r line; do
    src="${line%%:*}"
    ref="${line#*:}"
    [[ -f "$SPECS_DIR/$ref" ]] || { err "${src#$WORKSPACE_DIR/} → отсутствует specs/$ref"; BROKEN=$((BROKEN+1)); }
done < <(
    grep -rhoE '^.*$' /dev/null 2>/dev/null
    for f in $(find "$SPECS_DIR" -name '*.md'); do
        grep -oE '(core|domain|workflows|per-task|per-epic)/[a-zA-Z0-9._-]+\.(spec\.)?md' "$f" 2>/dev/null \
            | sort -u | sed "s|^|$f:|"
    done
)
(( BROKEN == 0 )) && ok "все ссылки резолвятся"

# ─── 4. Placeholders ─────────────────────────────────────────────────────────
sect "Placeholders"

# Токены-примеры в документации — не настоящие placeholder'ы
DOC_TOKENS='<FILE_KEY>|<NODE_ID>|<UPPER_CASE>|<VAULT>|<KEY>|<MAJOR>|<MINOR>|<PATCH>'

# Опциональные: остаются незаполненными, если соответствующий модуль выключен
OPT_TOKENS='<CODE_REPO_PATH>|<TOKENS_EXPORT_PATH>|<REFERENCE_PLATFORM>|<FIGMA_DS_FILE_KEY>|<FIGMA_PRODUCT_FILE_KEY>'

ALL=$(grep -rhoE '<[A-Z][A-Z_]{2,}>' "$SPECS_DIR" "$WORKSPACE_DIR/CLAUDE.md" "$WORKSPACE_DIR/README.md" 2>/dev/null \
    | grep -vE "^($DOC_TOKENS)$" | sort -u)
REQUIRED=$(printf '%s' "$ALL" | grep -vE "^($OPT_TOKENS)$" || true)
OPTIONAL=$(printf '%s' "$ALL" | grep -E "^($OPT_TOKENS)$" || true)

if [[ -n "$REQUIRED" ]]; then
    warn "workspace не настроен — не заполнены обязательные placeholder'ы:"
    printf "${C_DIM}%s${C_OFF}\n" "$(printf '%s' "$REQUIRED" | sed 's/^/    /')"
    printf "${C_DIM}    запустите /design.init или ./scripts/init.sh${C_OFF}\n"
else
    ok "обязательные placeholder'ы заполнены"
fi

if [[ -n "$OPTIONAL" ]]; then
    printf "${C_DIM}    не заполнены опциональные (соответствующие модули выключены):${C_OFF}\n"
    printf "${C_DIM}%s${C_OFF}\n" "$(printf '%s' "$OPTIONAL" | sed 's/^/      /')"
fi

# ─── 5. INDEX ────────────────────────────────────────────────────────────────
sect "INDEX.md"

if [[ -f "$SPECS_DIR/INDEX.md" ]]; then
    MISSING_IN_INDEX=0
    for f in $(find "$SPECS_DIR"/{core,domain,workflows} -name '*.spec.md' 2>/dev/null); do
        rel="${f#$SPECS_DIR/}"
        grep -qF "$rel" "$SPECS_DIR/INDEX.md" || { warn "$rel не упомянут в INDEX.md"; MISSING_IN_INDEX=$((MISSING_IN_INDEX+1)); }
    done
    (( MISSING_IN_INDEX == 0 )) && ok "все спеки перечислены в INDEX.md"
else
    err "specs/INDEX.md отсутствует"
fi

# ─── Итог ────────────────────────────────────────────────────────────────────
printf "\n${C_BOLD}Итог:${C_OFF} ошибок ${C_RED}%d${C_OFF}, предупреждений ${C_YELLOW}%d${C_OFF}\n" "$ERRORS" "$WARNINGS"
(( ERRORS > 0 )) && exit 1
exit 0
