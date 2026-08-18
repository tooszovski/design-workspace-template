---
name: git-policy
layer: core
purpose: Что не коммитить, ветки, rebase, правила пуша в design-workspace
always_loaded: true
owner: design-lead
---

# Git Policy

Репозиторий workspace'а хранит **правила и спеки**, не макеты. Всё тяжёлое и генерируемое остаётся вне git.

## Never commit

| Что | Почему |
|---|---|
| `CLAUDE.md`, `AGENTS.md`, `.cursorrules` | инструкции агента, не артефакт проекта |
| `*-plan.md`, `*-scratch.md` | черновики сессии |
| `.mcp.json` | содержит доступы; коммитится только `.mcp.json.example` |
| `.figma-cache/` | выгрузки Figma, протухают за часы |
| `exports/assets/**` | бинарники, генерируются из Figma |
| `*.png`, `*.jpg`, `*.fig`, `*.sketch` | макеты и мокапы — они в Figma |
| `/specs` | если выбран Obsidian-режим, спеки живут в vault |
| `.claude/settings.local.json` | личные настройки |
| `.DS_Store`, `*.log` | мусор |

Исключение: `exports/tokens/**` коммитится, если при init выбран режим версионирования токенов в этом репозитории.

## Ветки

| Ветка | Роль |
|---|---|
| `<RELEASE_BRANCH>` | стабильные правила, из неё разворачиваются новые проекты |
| `<INTEGRATION_BRANCH>` | интеграция изменений спек |
| `design/<PROJECT_PREFIX>-NNN-<slug>` | работа по задаче |
| `ds/<slug>` | изменения дизайн-системы |

## Правила

- **Rebase, не merge-commit** при подтягивании `<INTEGRATION_BRANCH>` в рабочую ветку. История спек должна читаться линейно.
- **Push только своих веток.** `<INTEGRATION_BRANCH>`, `<RELEASE_BRANCH>` и теги пушит человек. Enforced хуком `.claude/hooks/git-push-guard.sh`.
- **Никаких `--force`** в общих ветках. В своей — только если ветка не расшарена.
- Изменение `core/*.spec.md` требует отдельного коммита и внятного сообщения — эти файлы читают все агенты.

## Что делать с бинарниками

Если экспорт нужно передать разработке — путь через `<CODE_REPO_PATH>` или файловый обмен, не через этот репозиторий. Ассеты в git превращают клон workspace'а в гигабайты за полгода.

## Cross-refs

- core/commits.spec.md — формат сообщений
- core/workspace.spec.md — что где лежит
