#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# design-workspace-template — init.sh
#
# The shell alternative to /design.init. Asks for placeholder values and writes
# them into every spec, command, agent, and config file.
#
# Run ONCE after copying the template. Idempotent.
# The primary path is /design.init inside Claude Code: it infers better defaults
# and strips out disabled modules. This script exists for when Claude Code is
# not available.
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
        printf "      ${C_YELLOW}a value is required${C_OFF}\n" >&2
    done
}

# Pulls the file key out of a full Figma URL, or returns the input unchanged
figma_key() {
    printf '%s' "$1" | sed -E 's#.*figma\.com/(file|design)/([A-Za-z0-9]+).*#\2#'
}

cat <<EOF
${C_BOLD}design-workspace — init wizard${C_OFF}

Fills in placeholders across every spec, command, agent, and config.
Run ONCE after copying the template.

Workspace: ${WORKSPACE_DIR}
${C_DIM}The smarter path is /design.init inside Claude Code.${C_OFF}

EOF

if [[ ! -f "$WORKSPACE_DIR/CLAUDE.md" ]] || [[ ! -d "$WORKSPACE_DIR/specs/core" ]]; then
    printf "${C_YELLOW}!${C_OFF} This does not look like a template workspace root.\n"
    printf "  Expected CLAUDE.md and specs/core/ in %s\n" "$WORKSPACE_DIR"
    exit 1
fi

# ─── 1. Project ──────────────────────────────────────────────────────────────
section "Project"
PROJECT_NAME=$(ask_required "PROJECT_NAME (CamelCase, no spaces)")
ORG_NAME=$(ask_required "ORG_NAME (organization or product)")
PROJECT_PREFIX=$(ask_required "PROJECT_PREFIX (task prefix, e.g. ABC)")
DEV_LANGUAGE=$(ask "DEV_LANGUAGE (product interface language)" "en")

# ─── 2. Figma ────────────────────────────────────────────────────────────────
section "Figma"
note "You can paste a full URL — the key is extracted automatically."
FIGMA_DS_RAW=$(ask "Design-system file (URL or file key)" "")
FIGMA_PRODUCT_RAW=$(ask "Product file (URL or file key)" "")
FIGMA_DS_FILE_KEY=$([[ -n "$FIGMA_DS_RAW" ]] && figma_key "$FIGMA_DS_RAW" || echo "")
FIGMA_PRODUCT_FILE_KEY=$([[ -n "$FIGMA_PRODUCT_RAW" ]] && figma_key "$FIGMA_PRODUCT_RAW" || echo "")
DS_LIBRARY_NAME=$(ask "Library name" "${PROJECT_NAME} DS")

# ─── 3. Platforms and scales ─────────────────────────────────────────────────
section "Platforms and scales"
PLATFORMS=$(ask "PLATFORMS (comma-separated: Web, iOS, Android, Desktop)" "Web, iOS, Android")
SPACING_BASE=$(ask "SPACING_BASE (spacing scale base)" "4")
if [[ "$SPACING_BASE" == "8" ]]; then
    DEFAULT_SCALE="8, 16, 24, 32, 48, 64"
else
    DEFAULT_SCALE="4, 8, 12, 16, 24, 32, 48, 64"
fi
SPACING_SCALE=$(ask "SPACING_SCALE" "$DEFAULT_SCALE")
WCAG_LEVEL=$(ask "WCAG_LEVEL (A / AA / AAA)" "AA")

# ─── 4. Code repository ──────────────────────────────────────────────────────
section "Code repository (optional)"
note "Needed only for /design.drift and /design.tokens. Leave empty and those commands stay off."
CODE_REPO_PATH=$(ask "CODE_REPO_PATH (path to the implementation repository)" "")
CODE_REPO_PATH="${CODE_REPO_PATH/#\~/$HOME}"
if [[ -n "$CODE_REPO_PATH" ]]; then
    TOKENS_EXPORT_PATH=$(ask "TOKENS_EXPORT_PATH" "$CODE_REPO_PATH/tokens")
else
    TOKENS_EXPORT_PATH=$(ask "TOKENS_EXPORT_PATH (may be left empty)" "")
fi

# ─── 5. Artifact storage ─────────────────────────────────────────────────────
section "Artifact storage — requirements, task specs, worklogs"

OBSIDIAN_BASE="$HOME/Library/Mobile Documents/iCloud~md~obsidian/Documents"
USE_OBSIDIAN_DEFAULT="n"
[[ -d "$OBSIDIAN_BASE" ]] && USE_OBSIDIAN_DEFAULT="y"

USE_OBSIDIAN=$(ask "Use an Obsidian vault? (y/N)" "$USE_OBSIDIAN_DEFAULT")
OBSIDIAN_VAULT=""
OBSIDIAN_PROJECT_DIR=""

if [[ "$USE_OBSIDIAN" =~ ^[Yy]$ ]]; then
    if [[ -d "$OBSIDIAN_BASE" ]]; then
        VAULTS=()
        for d in "$OBSIDIAN_BASE"/*/; do [[ -d "$d" ]] && VAULTS+=("${d%/}"); done
        if (( ${#VAULTS[@]} == 1 )); then
            OBSIDIAN_VAULT="${VAULTS[0]}"
            note "Found vault: $(basename "$OBSIDIAN_VAULT")"
        elif (( ${#VAULTS[@]} > 1 )); then
            note "Several vaults found:"
            for i in "${!VAULTS[@]}"; do note "  [$((i+1))] $(basename "${VAULTS[$i]}")"; done
            VAULT_CHOICE=$(ask "Vault number" "1")
            VAULT_INDEX=$((VAULT_CHOICE - 1))
            (( VAULT_INDEX >= 0 && VAULT_INDEX < ${#VAULTS[@]} )) && OBSIDIAN_VAULT="${VAULTS[$VAULT_INDEX]}"
        fi
    fi
    if [[ -z "$OBSIDIAN_VAULT" ]]; then
        OBSIDIAN_VAULT=$(ask_required "Path to the vault (~ is fine)")
        OBSIDIAN_VAULT="${OBSIDIAN_VAULT/#\~/$HOME}"
    fi
    OBSIDIAN_PROJECT_DIR="$OBSIDIAN_VAULT/Projects/$PROJECT_NAME"
    TASK_SPEC_SOURCE_PATH=$(ask "TASK_SPEC_SOURCE_PATH (where requirements live)" "$OBSIDIAN_PROJECT_DIR/Requirements")
    PER_TASK_SPEC_LOCATION=$(ask "PER_TASK_SPEC_LOCATION (task specs and worklogs)" "$OBSIDIAN_PROJECT_DIR/Tasks")
    AGENT_LOGS_LOCATION=$(ask "AGENT_LOGS_LOCATION (cross-task journal)" "$OBSIDIAN_PROJECT_DIR/Agent Logs")
else
    TASK_SPEC_SOURCE_PATH=$(ask "TASK_SPEC_SOURCE_PATH (tracker or path)" "Linear")
    PER_TASK_SPEC_LOCATION=$(ask "PER_TASK_SPEC_LOCATION" "tasks")
    AGENT_LOGS_LOCATION=$(ask "AGENT_LOGS_LOCATION" "$PER_TASK_SPEC_LOCATION")
fi

# ─── 6. Tracker and git ──────────────────────────────────────────────────────
section "Tracker and git"
TRACKER_NAME=$(ask "TRACKER_NAME (Jira / Linear / Bitrix24 / YouTrack)" "Jira")
TRACKER_TESTING_STATUS=$(ask "TRACKER_TESTING_STATUS (the \"in review\" status)" "Testing")
TRACKER_BLOCKED_STATUS=$(ask "TRACKER_BLOCKED_STATUS (the \"blocked\" status)" "Blocked")
GIT_DEFAULT_NAME=$(git config user.name 2>/dev/null || echo "")
GIT_DEFAULT_EMAIL=$(git config user.email 2>/dev/null || echo "")
GIT_USER_NAME=$(ask "GIT_USER_NAME" "$GIT_DEFAULT_NAME")
GIT_USER_EMAIL=$(ask "GIT_USER_EMAIL" "$GIT_DEFAULT_EMAIL")
COMMIT_LANGUAGE=$(ask "COMMIT_LANGUAGE (English / Russian / ...)" "English")
INTEGRATION_BRANCH=$(ask "INTEGRATION_BRANCH" "develop")
RELEASE_BRANCH=$(ask "RELEASE_BRANCH" "main")
REFERENCE_PLATFORM=$(ask "REFERENCE_PLATFORM (reference platform, empty if none)" "")

# ─── Confirmation ────────────────────────────────────────────────────────────
section "Review"

cat <<EOF
  PROJECT_NAME            = ${C_BOLD}${PROJECT_NAME}${C_OFF}
  ORG_NAME                = ${ORG_NAME}
  PROJECT_PREFIX          = ${PROJECT_PREFIX}
  DEV_LANGUAGE            = ${DEV_LANGUAGE}
  FIGMA_DS_FILE_KEY       = ${FIGMA_DS_FILE_KEY:-<empty>}
  FIGMA_PRODUCT_FILE_KEY  = ${FIGMA_PRODUCT_FILE_KEY:-<empty>}
  DS_LIBRARY_NAME         = ${DS_LIBRARY_NAME}
  PLATFORMS               = ${PLATFORMS}
  SPACING_BASE            = ${SPACING_BASE}
  SPACING_SCALE           = ${SPACING_SCALE}
  WCAG_LEVEL              = ${WCAG_LEVEL}
  CODE_REPO_PATH          = ${CODE_REPO_PATH:-<empty>}
  TOKENS_EXPORT_PATH      = ${TOKENS_EXPORT_PATH:-<empty>}
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
  REFERENCE_PLATFORM      = ${REFERENCE_PLATFORM:-<empty>}
EOF
[[ -n "$OBSIDIAN_VAULT" ]] && printf "  Obsidian vault          = %s\n" "$OBSIDIAN_VAULT"
echo

printf "    ${C_YELLOW}?${C_OFF} Apply to every file? [y/N]: "
read -r confirm
[[ ! "$confirm" =~ ^[Yy]$ ]] && { printf "    Cancelled.\n"; exit 0; }

# ─── Applying ────────────────────────────────────────────────────────────────
section "Applying"

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

note "Files changed: $count_files, replacements: $count_total"

# ─── Obsidian ────────────────────────────────────────────────────────────────
if [[ -n "$OBSIDIAN_PROJECT_DIR" ]]; then
    section "Obsidian — project folders"
    printf "    ${C_YELLOW}?${C_OFF} Create them now? [Y/n]: "
    read -r mk
    if [[ ! "$mk" =~ ^[Nn]$ ]]; then
        for d in "$TASK_SPEC_SOURCE_PATH" "$PER_TASK_SPEC_LOCATION" "$AGENT_LOGS_LOCATION"; do
            mkdir -p "$d" 2>/dev/null && ok "${d/#$HOME/~}" || printf "    ${C_YELLOW}!${C_OFF} not created: %s\n" "$d"
        done
    fi

    SPECS_VAULT_DIR="$OBSIDIAN_PROJECT_DIR/Specs"
    if [[ -d "$WORKSPACE_DIR/specs" && ! -L "$WORKSPACE_DIR/specs" ]]; then
        section "Obsidian — move specs/ into the vault (symlink pattern)"
        printf "    ${C_YELLOW}?${C_OFF} Move it to %s and leave a symlink? [Y/n]: " "${SPECS_VAULT_DIR/#$HOME/~}"
        read -r mv_specs
        if [[ ! "$mv_specs" =~ ^[Nn]$ ]]; then
            if [[ -e "$SPECS_VAULT_DIR" ]]; then
                printf "    ${C_YELLOW}!${C_OFF} %s already exists — move skipped\n" "${SPECS_VAULT_DIR/#$HOME/~}"
            else
                mkdir -p "$OBSIDIAN_PROJECT_DIR"
                mv "$WORKSPACE_DIR/specs" "$SPECS_VAULT_DIR"
                ln -s "$SPECS_VAULT_DIR" "$WORKSPACE_DIR/specs"
                ok "specs/ → ${SPECS_VAULT_DIR/#$HOME/~}"
                if ! grep -qx "/specs" "$WORKSPACE_DIR/.gitignore" 2>/dev/null; then
                    printf '\n/specs\n' >> "$WORKSPACE_DIR/.gitignore"
                    ok "/specs added to .gitignore"
                fi
            fi
        fi
    fi
fi

# ─── symlink code/ ───────────────────────────────────────────────────────────
if [[ -n "$CODE_REPO_PATH" && -d "$CODE_REPO_PATH" && ! -e "$WORKSPACE_DIR/code" ]]; then
    section "The ./code symlink"
    printf "    ${C_YELLOW}?${C_OFF} Create ./code → %s? [Y/n]: " "${CODE_REPO_PATH/#$HOME/~}"
    read -r ln_code
    [[ ! "$ln_code" =~ ^[Nn]$ ]] && ln -s "$CODE_REPO_PATH" "$WORKSPACE_DIR/code" && ok "./code created"
fi

# ─── Configs ─────────────────────────────────────────────────────────────────
section "Configs"
[[ ! -f "$WORKSPACE_DIR/.mcp.json" && -f "$WORKSPACE_DIR/.mcp.json.example" ]] && {
    cp "$WORKSPACE_DIR/.mcp.json.example" "$WORKSPACE_DIR/.mcp.json"
    ok ".mcp.json created — add your Figma token"
}
[[ ! -f "$WORKSPACE_DIR/.claude/settings.local.json" && -f "$WORKSPACE_DIR/.claude/settings.local.json.example" ]] && {
    cp "$WORKSPACE_DIR/.claude/settings.local.json.example" "$WORKSPACE_DIR/.claude/settings.local.json"
    ok "settings.local.json created"
}

section "Git config"
printf "    ${C_YELLOW}?${C_OFF} Set user.name/user.email in this repository? [y/N]: "
read -r set_git
if [[ "$set_git" =~ ^[Yy]$ ]]; then
    ( cd "$WORKSPACE_DIR" && git config user.name "$GIT_USER_NAME" && git config user.email "$GIT_USER_EMAIL" ) || true
    ok "git config updated"
fi

# ─── Summary ─────────────────────────────────────────────────────────────────
section "Done"

cat <<EOF
${C_BOLD}Next:${C_OFF}

  1. Check for leftover placeholders:
     ${C_DIM}grep -rEo '<[A-Z_]+>' specs/ CLAUDE.md README.md | sed 's/.*://' | sort -u${C_OFF}

  2. Validate the specs:
     ${C_DIM}./scripts/validate-specs.sh${C_OFF}

  3. Fill in by hand:
     ${C_DIM}specs/domain/layout.spec.md${C_OFF}      — breakpoints for ${PLATFORMS}
     ${C_DIM}specs/domain/ux-writing.spec.md${C_OFF}  — the product glossary
     ${C_DIM}specs/core/project.spec.md §1${C_OFF}    — review Constitution D-01..D-14

  4. Add your Figma token to .mcp.json

  5. First task: ${C_BOLD}/design.audit${C_OFF} on any frame

EOF
