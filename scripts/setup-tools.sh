#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# design-workspace-template — setup-tools.sh
#
# Checks and completes the environment: Claude Code, node, Figma MCP, and the
# optional utilities for tokens and SVG.
#
# Idempotent. Installs nothing silently — it asks first.
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

# ─── Required ────────────────────────────────────────────────────────────────
section "Required"

if have claude; then
    ok "Claude Code $(claude --version 2>/dev/null | head -1)"
else
    warn "Claude Code not found"
    note "Install: https://claude.com/claude-code"
fi

if have node; then
    NODE_MAJOR=$(node -v | sed 's/v\([0-9]*\).*/\1/')
    if (( NODE_MAJOR >= 18 )); then
        ok "node $(node -v)"
    else
        warn "node $(node -v) — Figma MCP needs 18+"
    fi
else
    warn "node not found — Figma MCP will not start without it"
    if have brew && ask_yn "Install node via brew?"; then
        brew install node && ok "node installed"
    else
        note "Install: https://nodejs.org"
    fi
fi

have git && ok "git $(git --version | awk '{print $3}')" || warn "git not found"

# ─── Figma MCP ───────────────────────────────────────────────────────────────
section "Figma MCP"

if [[ -f "$WORKSPACE_DIR/.mcp.json" ]]; then
    if grep -q "YOUR_FIGMA_TOKEN" "$WORKSPACE_DIR/.mcp.json"; then
        warn ".mcp.json exists but the token is not filled in"
        note "Token: figma.com → Settings → Security → Personal access tokens"
        note "Scope: File content (read). Nothing more is needed."
    else
        ok ".mcp.json is configured"
    fi
else
    if [[ -f "$WORKSPACE_DIR/.mcp.json.example" ]]; then
        if ask_yn "Create .mcp.json from the example?"; then
            cp "$WORKSPACE_DIR/.mcp.json.example" "$WORKSPACE_DIR/.mcp.json"
            ok ".mcp.json created"
            note "Add the token: figma.com → Settings → Security → Personal access tokens"
        fi
    else
        warn ".mcp.json.example is missing"
    fi
fi

# ─── Optional ────────────────────────────────────────────────────────────────
section "Optional"

if have npx; then
    ok "npx — style-dictionary and svgo are available without a global install"
    note "Tokens: npx style-dictionary build"
    note "SVG:    npx svgo --folder exports/assets"
else
    warn "npx not found — token export and SVG optimization are unavailable"
fi

# ─── Claude settings ─────────────────────────────────────────────────────────
section "Claude Code settings"

LOCAL="$WORKSPACE_DIR/.claude/settings.local.json"
if [[ -f "$LOCAL" ]]; then
    ok "settings.local.json is in place"
elif [[ -f "$LOCAL.example" ]]; then
    if ask_yn "Create settings.local.json from the example (removes permission prompts)?"; then
        cp "$LOCAL.example" "$LOCAL" && ok "settings.local.json created"
    fi
fi

[[ -x "$WORKSPACE_DIR/.claude/hooks/git-push-guard.sh" ]] \
    && ok "git-push-guard is executable" \
    || { chmod +x "$WORKSPACE_DIR/.claude/hooks/git-push-guard.sh" 2>/dev/null && ok "git-push-guard made executable"; }

# ─── Summary ─────────────────────────────────────────────────────────────────
section "Next"

cat <<TXT
  1. Add your Figma token to .mcp.json
  2. Configure the workspace:
     ${C_DIM}claude${C_OFF}  →  ${C_BOLD}/design.init${C_OFF}
     or, without Claude Code: ${C_DIM}./scripts/init.sh${C_OFF}

TXT
