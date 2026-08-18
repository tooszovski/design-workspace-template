#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# design-workspace-template — init.sh
#
# Shell-альтернатива команде /design.init. Спрашивает значения placeholder'ов
# и проставляет их во все спеки, команды, агентов и конфиги.
#
# Запускается ОДИН раз после копирования шаблона. Идемпотентен.
# Основной путь настройки — /design.init в Claude Code: он умнее подставляет
# умолчания и вычищает отключённые модули. Этот скрипт — на случай, когда
# Claude Code недоступен.
# ─────────────────────────────────────────────────────────────────────────────

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

C_BLUE=$'\033[0;34m'; C_GREEN=$'\033[0;32m'; C_YELLOW=$'\033[0;33m'
C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'; C_OFF=$'\033[0m'

section() { printf "\n${C_BOLD}${C_BLUE}==> %s${C_OFF}\n" "$1"; }
ok()      { printf "    ${C_GREEN}✓${C_OFF} %s\n" "$1"; }
note()    { printf "    ${C_DIM}%s${C_OFF}\n" "$1"; }

ask() {
    local prompt="$1" default="${2:-}" var
    if [[ -n "$default" ]]; then
        printf "    ${C_YELLOW}?${C_OFF} %s ${C_DIM}[%s]${C_OFF}: " "$prompt" "$default" >&2
    else
        printf "    ${C_YELLOW}?${C_OFF} %s: " "$prompt" >&2
    fi
    read -r var
    echo "${var:-$default}"
}

ask_required() {
    local prompt="$1" value
    while true; do
        value=$(ask "$prompt")
        [[ -n "$value" ]] && { echo "$value"; return; }
        printf "      ${C_YELLOW}значение обязательно${C_OFF}\n" >&2
    done
}

# Достаёт file key из полной ссылки Figma либо возвращает ввод как есть
figma_key() {
    printf '%s' "$1" | sed -E 's#.*figma\.com/(file|design)/([A-Za-z0-9]+).*#\2#'
}

cat <<EOF
${C_BOLD}design-workspace — init wizard${C_OFF}

Заполняет placeholder'ы во всех спеках, командах, агентах и конфигах.
Выполнять ОДИН РАЗ после копирования шаблона.

Workspace: ${WORKSPACE_DIR}
${C_DIM}Более умный путь — /design.init в Claude Code.${C_OFF}

EOF

if [[ ! -f "$WORKSPACE_DIR/CLAUDE.md" ]] || [[ ! -d "$WORKSPACE_DIR/specs/core" ]]; then
    printf "${C_YELLOW}!${C_OFF} Не похоже на корень workspace'а из шаблона.\n"
    printf "  Ожидаем CLAUDE.md + specs/core/ в %s\n" "$WORKSPACE_DIR"
    exit 1
fi

# ─── 1. Проект ───────────────────────────────────────────────────────────────
section "Проект"
PROJECT_NAME=$(ask_required "PROJECT_NAME (CamelCase, без пробелов)")
ORG_NAME=$(ask_required "ORG_NAME (организация или продукт)")
PROJECT_PREFIX=$(ask_required "PROJECT_PREFIX (префикс задач, напр. ABC)")
DEV_LANGUAGE=$(ask "DEV_LANGUAGE (язык интерфейса продукта)" "ru")

# ─── 2. Figma ────────────────────────────────────────────────────────────────
section "Figma"
note "Можно вставить полную ссылку — ключ извлечётся автоматически."
FIGMA_DS_RAW=$(ask "Файл дизайн-системы (ссылка или file key)" "")
FIGMA_PRODUCT_RAW=$(ask "Продуктовый файл (ссылка или file key)" "")
FIGMA_DS_FILE_KEY=$([[ -n "$FIGMA_DS_RAW" ]] && figma_key "$FIGMA_DS_RAW" || echo "")
FIGMA_PRODUCT_FILE_KEY=$([[ -n "$FIGMA_PRODUCT_RAW" ]] && figma_key "$FIGMA_PRODUCT_RAW" || echo "")
DS_LIBRARY_NAME=$(ask "Название библиотеки" "${PROJECT_NAME} DS")

# ─── 3. Платформы и шкалы ────────────────────────────────────────────────────
section "Платформы и шкалы"
PLATFORMS=$(ask "PLATFORMS (через запятую: Web, iOS, Android, Desktop)" "Web, iOS, Android")
SPACING_BASE=$(ask "SPACING_BASE (база spacing-шкалы)" "4")
if [[ "$SPACING_BASE" == "8" ]]; then
    DEFAULT_SCALE="8, 16, 24, 32, 48, 64"
else
    DEFAULT_SCALE="4, 8, 12, 16, 24, 32, 48, 64"
fi
SPACING_SCALE=$(ask "SPACING_SCALE" "$DEFAULT_SCALE")
WCAG_LEVEL=$(ask "WCAG_LEVEL (A / AA / AAA)" "AA")

# ─── 4. Кодовый репозиторий ──────────────────────────────────────────────────
section "Кодовый репозиторий (опционально)"
note "Нужен только для /design.drift и /design.tokens. Пусто — эти команды не работают."
CODE_REPO_PATH=$(ask "CODE_REPO_PATH (путь к репозиторию реализации)" "")
CODE_REPO_PATH="${CODE_REPO_PATH/#\~/$HOME}"
if [[ -n "$CODE_REPO_PATH" ]]; then
    TOKENS_EXPORT_PATH=$(ask "TOKENS_EXPORT_PATH" "$CODE_REPO_PATH/tokens")
else
    TOKENS_EXPORT_PATH=$(ask "TOKENS_EXPORT_PATH (можно оставить пустым)" "")
fi

# ─── 5. Хранилище артефактов ─────────────────────────────────────────────────
section "Хранилище артефактов — ТЗ, спеки задач, worklog"

OBSIDIAN_BASE="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
USE_OBSIDIAN_DEFAULT="n"
[[ -d "$OBSIDIAN_BASE" ]] && USE_OBSIDIAN_DEFAULT="y"

USE_OBSIDIAN=$(ask "Использовать Obsidian vault? (y/N)" "$USE_OBSIDIAN_DEFAULT")
OBSIDIAN_VAULT=""
OBSIDIAN_PROJECT_DIR=""

if [[ "$USE_OBSIDIAN" =~ ^[Yy]$ ]]; then
    if [[ -d "$OBSIDIAN_BASE" ]]; then
        VAULTS=()
        for d in "$OBSIDIAN_BASE"/*/; do [[ -d "$d" ]] && VAULTS+=("${d%/}"); done
        if (( ${#VAULTS[@]} == 1 )); then
            OBSIDIAN_VAULT="${VAULTS[0]}"
            note "Найден vault: $(basename "$OBSIDIAN_VAULT")"
        elif (( ${#VAULTS[@]} > 1 )); then
            note "Найдено несколько vault'ов:"
            for i in "${!VAULTS[@]}"; do note "  [$((i+1))] $(basename "${VAULTS[$i]}")"; done
            VAULT_CHOICE=$(ask "Номер vault'а" "1")
            VAULT_INDEX=$((VAULT_CHOICE - 1))
            (( VAULT_INDEX >= 0 && VAULT_INDEX < ${#VAULTS[@]} )) && OBSIDIAN_VAULT="${VAULTS[$VAULT_INDEX]}"
        fi
    fi
    if [[ -z "$OBSIDIAN_VAULT" ]]; then
        OBSIDIAN_VAULT=$(ask_required "Путь к vault'у (можно с ~)")
        OBSIDIAN_VAULT="${OBSIDIAN_VAULT/#\~/$HOME}"
    fi
    OBSIDIAN_PROJECT_DIR="$OBSIDIAN_VAULT/Projects/$PROJECT_NAME"
    TASK_SPEC_SOURCE_PATH=$(ask "TASK_SPEC_SOURCE_PATH (где живут ТЗ)" "$OBSIDIAN_PROJECT_DIR/ТЗ")
    PER_TASK_SPEC_LOCATION=$(ask "PER_TASK_SPEC_LOCATION (спеки задач и worklog)" "$OBSIDIAN_PROJECT_DIR/Tasks")
    AGENT_LOGS_LOCATION=$(ask "AGENT_LOGS_LOCATION (кросс-задачный журнал)" "$OBSIDIAN_PROJECT_DIR/Agent Logs")
else
    TASK_SPEC_SOURCE_PATH=$(ask "TASK_SPEC_SOURCE_PATH (трекер или путь)" "Linear")
    PER_TASK_SPEC_LOCATION=$(ask "PER_TASK_SPEC_LOCATION" "tasks")
    AGENT_LOGS_LOCATION=$(ask "AGENT_LOGS_LOCATION" "$PER_TASK_SPEC_LOCATION")
fi

# ─── 6. Трекер и git ─────────────────────────────────────────────────────────
section "Трекер и git"
TRACKER_NAME=$(ask "TRACKER_NAME (Jira / Linear / Bitrix24 / YouTrack)" "Jira")
TRACKER_TESTING_STATUS=$(ask "TRACKER_TESTING_STATUS (статус «на проверке»)" "Testing")
TRACKER_BLOCKED_STATUS=$(ask "TRACKER_BLOCKED_STATUS (статус «заблокировано»)" "Blocked")
GIT_DEFAULT_NAME=$(git config user.name 2>/dev/null || echo "")
GIT_DEFAULT_EMAIL=$(git config user.email 2>/dev/null || echo "")
GIT_USER_NAME=$(ask "GIT_USER_NAME" "$GIT_DEFAULT_NAME")
GIT_USER_EMAIL=$(ask "GIT_USER_EMAIL" "$GIT_DEFAULT_EMAIL")
COMMIT_LANGUAGE=$(ask "COMMIT_LANGUAGE (Russian / English)" "Russian")
INTEGRATION_BRANCH=$(ask "INTEGRATION_BRANCH" "develop")
RELEASE_BRANCH=$(ask "RELEASE_BRANCH" "main")
REFERENCE_PLATFORM=$(ask "REFERENCE_PLATFORM (референс-платформа, пусто если нет)" "")

# ─── Подтверждение ───────────────────────────────────────────────────────────
section "Проверьте"

cat <<EOF
  PROJECT_NAME            = ${C_BOLD}${PROJECT_NAME}${C_OFF}
  ORG_NAME                = ${ORG_NAME}
  PROJECT_PREFIX          = ${PROJECT_PREFIX}
  DEV_LANGUAGE            = ${DEV_LANGUAGE}
  FIGMA_DS_FILE_KEY       = ${FIGMA_DS_FILE_KEY:-<пусто>}
  FIGMA_PRODUCT_FILE_KEY  = ${FIGMA_PRODUCT_FILE_KEY:-<пусто>}
  DS_LIBRARY_NAME         = ${DS_LIBRARY_NAME}
  PLATFORMS               = ${PLATFORMS}
  SPACING_BASE            = ${SPACING_BASE}
  SPACING_SCALE           = ${SPACING_SCALE}
  WCAG_LEVEL              = ${WCAG_LEVEL}
  CODE_REPO_PATH          = ${CODE_REPO_PATH:-<пусто>}
  TOKENS_EXPORT_PATH      = ${TOKENS_EXPORT_PATH:-<пусто>}
  TASK_SPEC_SOURCE_PATH   = ${TASK_SPEC_SOURCE_PATH}
  PER_TASK_SPEC_LOCATION  = ${PER_TASK_SPEC_LOCATION}
  AGENT_LOGS_LOCATION     = ${AGENT_LOGS_LOCATION}
  TRACKER_NAME            = ${TRACKER_NAME}
  TRACKER_TESTING_STATUS  = ${TRACKER_TESTING_STATUS}
  TRACKER_BLOCKED_STATUS  = ${TRACKER_BLOCKED_STATUS}
  GIT_USER_NAME           = ${GIT_USER_NAME}
  GIT_USER_EMAIL          = ${GIT_USER_EMAIL}
  COMMIT_LANGUAGE         = ${COMMIT_LANGUAGE}
  INTEGRATION_BRANCH      = ${INTEGRATION_BRANCH}
  RELEASE_BRANCH          = ${RELEASE_BRANCH}
  REFERENCE_PLATFORM      = ${REFERENCE_PLATFORM:-<пусто>}
EOF
[[ -n "$OBSIDIAN_VAULT" ]] && printf "  Obsidian vault          = %s\n" "$OBSIDIAN_VAULT"
echo

printf "    ${C_YELLOW}?${C_OFF} Применить ко всем файлам? [y/N]: "
read -r confirm
[[ ! "$confirm" =~ ^[Yy]$ ]] && { printf "    Отмена.\n"; exit 0; }

# ─── Применение ──────────────────────────────────────────────────────────────
section "Применяю"

FILES_LIST=$(find "$WORKSPACE_DIR" \
    \( -name ".git" -o -name "node_modules" -o -name ".figma-cache" \) -prune -o \
    -type f \( -name "*.md" -o -name "*.json" -o -name "*.yml" -o -name "*.yaml" -o -name "*.sh" -o -name ".gitignore" \) \
    ! -path "*/scripts/init.sh" \
    ! -path "*/scripts/setup-tools.sh" \
    -print)

declare -a REPLACEMENTS=(
    "<PROJECT_NAME>=$PROJECT_NAME"
    "<ORG_NAME>=$ORG_NAME"
    "<PROJECT_PREFIX>=$PROJECT_PREFIX"
    "<DEV_LANGUAGE>=$DEV_LANGUAGE"
    "<DS_LIBRARY_NAME>=$DS_LIBRARY_NAME"
    "<PLATFORMS>=$PLATFORMS"
    "<SPACING_BASE>=$SPACING_BASE"
    "<SPACING_SCALE>=$SPACING_SCALE"
    "<WCAG_LEVEL>=$WCAG_LEVEL"
    "<TASK_SPEC_SOURCE_PATH>=$TASK_SPEC_SOURCE_PATH"
    "<PER_TASK_SPEC_LOCATION>=$PER_TASK_SPEC_LOCATION"
    "<AGENT_LOGS_LOCATION>=$AGENT_LOGS_LOCATION"
    "<TRACKER_NAME>=$TRACKER_NAME"
    "<TRACKER_TESTING_STATUS>=$TRACKER_TESTING_STATUS"
    "<TRACKER_BLOCKED_STATUS>=$TRACKER_BLOCKED_STATUS"
    "<GIT_USER_NAME>=$GIT_USER_NAME"
    "<GIT_USER_EMAIL>=$GIT_USER_EMAIL"
    "<COMMIT_LANGUAGE>=$COMMIT_LANGUAGE"
    "<INTEGRATION_BRANCH>=$INTEGRATION_BRANCH"
    "<RELEASE_BRANCH>=$RELEASE_BRANCH"
)

[[ -n "$FIGMA_DS_FILE_KEY" ]]      && REPLACEMENTS+=("<FIGMA_DS_FILE_KEY>=$FIGMA_DS_FILE_KEY")
[[ -n "$FIGMA_PRODUCT_FILE_KEY" ]] && REPLACEMENTS+=("<FIGMA_PRODUCT_FILE_KEY>=$FIGMA_PRODUCT_FILE_KEY")
[[ -n "$CODE_REPO_PATH" ]]         && REPLACEMENTS+=("<CODE_REPO_PATH>=$CODE_REPO_PATH")
[[ -n "$TOKENS_EXPORT_PATH" ]]     && REPLACEMENTS+=("<TOKENS_EXPORT_PATH>=$TOKENS_EXPORT_PATH")
[[ -n "$REFERENCE_PLATFORM" ]]     && REPLACEMENTS+=("<REFERENCE_PLATFORM>=$REFERENCE_PLATFORM")

count_total=0; count_files=0

while IFS= read -r file; do
    [[ -f "$file" ]] || continue
    file_changed=0
    for kv in "${REPLACEMENTS[@]}"; do
        key="${kv%%=*}"; value="${kv#*=}"
        before=$(grep -c -F "$key" "$file" 2>/dev/null || echo 0)
        if (( before > 0 )); then
            esc_key=$(printf '%s' "$key" | sed -e 's/[]\/$*.^[]/\\&/g')
            esc_value=$(printf '%s' "$value" | sed -e 's/[\/&]/\\&/g')
            sed -i '' "s/${esc_key}/${esc_value}/g" "$file"
            count_total=$((count_total + before)); file_changed=1
        fi
    done
    (( file_changed > 0 )) && { count_files=$((count_files + 1)); ok "${file#$WORKSPACE_DIR/}"; }
done <<< "$FILES_LIST"

note "Файлов изменено: $count_files, замен: $count_total"

# ─── Obsidian ────────────────────────────────────────────────────────────────
if [[ -n "$OBSIDIAN_PROJECT_DIR" ]]; then
    section "Obsidian — папки проекта"
    printf "    ${C_YELLOW}?${C_OFF} Создать сейчас? [Y/n]: "
    read -r mk
    if [[ ! "$mk" =~ ^[Nn]$ ]]; then
        for d in "$TASK_SPEC_SOURCE_PATH" "$PER_TASK_SPEC_LOCATION" "$AGENT_LOGS_LOCATION"; do
            mkdir -p "$d" 2>/dev/null && ok "${d/#$HOME/~}" || printf "    ${C_YELLOW}!${C_OFF} не создано: %s\n" "$d"
        done
    fi

    SPECS_VAULT_DIR="$OBSIDIAN_PROJECT_DIR/Specs"
    if [[ -d "$WORKSPACE_DIR/specs" && ! -L "$WORKSPACE_DIR/specs" ]]; then
        section "Obsidian — перенести specs/ в vault (symlink-паттерн)"
        printf "    ${C_YELLOW}?${C_OFF} Перенести в %s и оставить symlink? [Y/n]: " "${SPECS_VAULT_DIR/#$HOME/~}"
        read -r mv_specs
        if [[ ! "$mv_specs" =~ ^[Nn]$ ]]; then
            if [[ -e "$SPECS_VAULT_DIR" ]]; then
                printf "    ${C_YELLOW}!${C_OFF} %s уже существует — перенос пропущен\n" "${SPECS_VAULT_DIR/#$HOME/~}"
            else
                mkdir -p "$OBSIDIAN_PROJECT_DIR"
                mv "$WORKSPACE_DIR/specs" "$SPECS_VAULT_DIR"
                ln -s "$SPECS_VAULT_DIR" "$WORKSPACE_DIR/specs"
                ok "specs/ → ${SPECS_VAULT_DIR/#$HOME/~}"
                if ! grep -qx "/specs" "$WORKSPACE_DIR/.gitignore" 2>/dev/null; then
                    printf '\n/specs\n' >> "$WORKSPACE_DIR/.gitignore"
                    ok "/specs добавлен в .gitignore"
                fi
            fi
        fi
    fi
fi

# ─── symlink code/ ───────────────────────────────────────────────────────────
if [[ -n "$CODE_REPO_PATH" && -d "$CODE_REPO_PATH" && ! -e "$WORKSPACE_DIR/code" ]]; then
    section "Symlink ./code"
    printf "    ${C_YELLOW}?${C_OFF} Создать ./code → %s? [Y/n]: " "${CODE_REPO_PATH/#$HOME/~}"
    read -r ln_code
    [[ ! "$ln_code" =~ ^[Nn]$ ]] && ln -s "$CODE_REPO_PATH" "$WORKSPACE_DIR/code" && ok "./code создан"
fi

# ─── Конфиги ─────────────────────────────────────────────────────────────────
section "Конфиги"
[[ ! -f "$WORKSPACE_DIR/.mcp.json" && -f "$WORKSPACE_DIR/.mcp.json.example" ]] && {
    cp "$WORKSPACE_DIR/.mcp.json.example" "$WORKSPACE_DIR/.mcp.json"
    ok ".mcp.json создан — подставьте токен Figma"
}
[[ ! -f "$WORKSPACE_DIR/.claude/settings.local.json" && -f "$WORKSPACE_DIR/.claude/settings.local.json.example" ]] && {
    cp "$WORKSPACE_DIR/.claude/settings.local.json.example" "$WORKSPACE_DIR/.claude/settings.local.json"
    ok "settings.local.json создан"
}

section "Git config"
printf "    ${C_YELLOW}?${C_OFF} Прописать user.name/user.email в этом репозитории? [y/N]: "
read -r set_git
if [[ "$set_git" =~ ^[Yy]$ ]]; then
    ( cd "$WORKSPACE_DIR" && git config user.name "$GIT_USER_NAME" && git config user.email "$GIT_USER_EMAIL" ) || true
    ok "git config обновлён"
fi

# ─── Итог ────────────────────────────────────────────────────────────────────
section "Готово"

cat <<EOF
${C_BOLD}Дальше:${C_OFF}

  1. Проверьте оставшиеся placeholder'ы:
     ${C_DIM}grep -rEo '<[A-Z_]+>' specs/ CLAUDE.md README.md | sed 's/.*://' | sort -u${C_OFF}

  2. Провалидируйте спеки:
     ${C_DIM}./scripts/validate-specs.sh${C_OFF}

  3. Заполните руками:
     ${C_DIM}specs/domain/layout.spec.md${C_OFF}      — брейкпоинты под ${PLATFORMS}
     ${C_DIM}specs/domain/ux-writing.spec.md${C_OFF}  — словарь терминов
     ${C_DIM}specs/core/project.spec.md §1${C_OFF}    — сверьте Constitution D-01..D-14

  4. Подставьте токен Figma в .mcp.json

  5. Первая задача: ${C_BOLD}/design.audit${C_OFF} на любом фрейме

EOF
