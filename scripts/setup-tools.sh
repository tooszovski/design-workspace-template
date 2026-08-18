#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# design-workspace-template — setup-tools.sh
#
# Проверяет и доустанавливает окружение: Claude Code, node, Figma MCP,
# опциональные утилиты для токенов и SVG.
#
# Идемпотентен. Ничего не ставит молча — спрашивает перед установкой.
# ─────────────────────────────────────────────────────────────────────────────

set -uo pipefail

C_BLUE=$'\033[0;34m'; C_GREEN=$'\033[0;32m'; C_YELLOW=$'\033[0;33m'
C_DIM=$'\033[2m'; C_BOLD=$'\033[1m'; C_OFF=$'\033[0m'

section() { printf "\n${C_BOLD}${C_BLUE}==> %s${C_OFF}\n" "$1"; }
ok()      { printf "    ${C_GREEN}✓${C_OFF} %s\n" "$1"; }
warn()    { printf "    ${C_YELLOW}!${C_OFF} %s\n" "$1"; }
note()    { printf "    ${C_DIM}%s${C_OFF}\n" "$1"; }

have() { command -v "$1" >/dev/null 2>&1; }

ask_yn() {
    printf "    ${C_YELLOW}?${C_OFF} %s [y/N]: " "$1"
    read -r a
    [[ "$a" =~ ^[Yy]$ ]]
}

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORKSPACE_DIR="$(dirname "$SCRIPT_DIR")"

printf "${C_BOLD}design-workspace — setup-tools${C_OFF}\n"
printf "Workspace: %s\n" "$WORKSPACE_DIR"

# ─── Обязательное ────────────────────────────────────────────────────────────
section "Обязательное"

if have claude; then
    ok "Claude Code $(claude --version 2>/dev/null | head -1)"
else
    warn "Claude Code не найден"
    note "Установка: https://claude.com/claude-code"
fi

if have node; then
    NODE_MAJOR=$(node -v | sed 's/v\([0-9]*\).*/\1/')
    if (( NODE_MAJOR >= 18 )); then
        ok "node $(node -v)"
    else
        warn "node $(node -v) — нужен 18+ для Figma MCP"
    fi
else
    warn "node не найден — без него не запустится Figma MCP"
    if have brew && ask_yn "Установить node через brew?"; then
        brew install node && ok "node установлен"
    else
        note "Установка: https://nodejs.org"
    fi
fi

have git && ok "git $(git --version | awk '{print $3}')" || warn "git не найден"

# ─── Figma MCP ───────────────────────────────────────────────────────────────
section "Figma MCP"

if [[ -f "$WORKSPACE_DIR/.mcp.json" ]]; then
    if grep -q "YOUR_FIGMA_TOKEN" "$WORKSPACE_DIR/.mcp.json"; then
        warn ".mcp.json есть, но токен не подставлен"
        note "Токен: figma.com → Settings → Security → Personal access tokens"
        note "Права: File content (read). Больше не нужно."
    else
        ok ".mcp.json настроен"
    fi
else
    if [[ -f "$WORKSPACE_DIR/.mcp.json.example" ]]; then
        if ask_yn "Создать .mcp.json из примера?"; then
            cp "$WORKSPACE_DIR/.mcp.json.example" "$WORKSPACE_DIR/.mcp.json"
            ok ".mcp.json создан"
            note "Подставьте токен: figma.com → Settings → Security → Personal access tokens"
        fi
    else
        warn ".mcp.json.example отсутствует"
    fi
fi

# ─── Опциональное ────────────────────────────────────────────────────────────
section "Опциональное"

if have npx; then
    ok "npx — доступны style-dictionary и svgo без глобальной установки"
    note "Токены: npx style-dictionary build"
    note "SVG:    npx svgo --folder exports/assets"
else
    warn "npx не найден — экспорт токенов и оптимизация SVG недоступны"
fi

# ─── Настройки Claude ────────────────────────────────────────────────────────
section "Настройки Claude Code"

LOCAL="$WORKSPACE_DIR/.claude/settings.local.json"
if [[ -f "$LOCAL" ]]; then
    ok "settings.local.json на месте"
elif [[ -f "$LOCAL.example" ]]; then
    if ask_yn "Создать settings.local.json из примера (снимает permission prompts)?"; then
        cp "$LOCAL.example" "$LOCAL" && ok "settings.local.json создан"
    fi
fi

[[ -x "$WORKSPACE_DIR/.claude/hooks/git-push-guard.sh" ]] \
    && ok "git-push-guard исполняемый" \
    || { chmod +x "$WORKSPACE_DIR/.claude/hooks/git-push-guard.sh" 2>/dev/null && ok "git-push-guard сделан исполняемым"; }

# ─── Итог ────────────────────────────────────────────────────────────────────
section "Дальше"

cat <<TXT
  1. Подставьте токен Figma в .mcp.json
  2. Запустите настройку workspace:
     ${C_DIM}claude${C_OFF}  →  ${C_BOLD}/design.init${C_OFF}
     или без Claude Code: ${C_DIM}./scripts/init.sh${C_OFF}

TXT
