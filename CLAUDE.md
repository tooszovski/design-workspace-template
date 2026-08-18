# CLAUDE.md

Bootstrap-документ для Claude Code и любых subagent-ов, работающих с этим design-workspace.

Все детальные правила вынесены в `specs/` (SDD spec-структура). Этот файл — entry point, не source of truth.

## Project

`<PROJECT_NAME>` — продуктовый дизайн для `<ORG_NAME>`.

- Основной инструмент: **Figma** (доступ через Figma MCP)
- Дизайн-система: `<DS_LIBRARY_NAME>`, файл `<FIGMA_DS_FILE_KEY>`
- Продуктовые макеты: файл `<FIGMA_PRODUCT_FILE_KEY>`
- Платформы: `<PLATFORMS>`
- Spacing-шкала: base `<SPACING_BASE>` → `<SPACING_SCALE>`
- Accessibility baseline: WCAG `<WCAG_LEVEL>`
- Dev language: `<DEV_LANGUAGE>`

Constitution (D-01..D-14) — `specs/core/project.spec.md §1`.

## Первый запуск

Если в файлах остались placeholder'ы вида `<UPPER_CASE>` — workspace не настроен. Запустить:

```
/design.init
```

Claude проведёт интервью (AskUserQuestion), проставит значения, отключит ненужные модули и вычистит `specs/INDEX.md`. Shell-альтернатива без Claude Code — `./scripts/init.sh`.

Проверка: `grep -rE '<[A-Z_]+>' specs/ CLAUDE.md README.md` — пусто.

## Workspace Layout

- Claude Code запускается из workspace root.
- Оркестраторные файлы (CLAUDE.md, `.claude/`, `specs/`) — здесь.
- Исходники дизайна живут **в Figma**, не в репозитории. Локально хранятся только спеки, токены и экспортированные ассеты.
- `specs/` — **symlink** на Obsidian vault `Projects/<PROJECT_NAME>/Specs/` (если при init выбран vault). Спеки живут в vault, в git workspace-репо не входят (`/specs` в `.gitignore`). Все пути `specs/...` работают через symlink — не «переносить их обратно» в репо.
- `./code` — опциональный symlink на кодовый репозиторий, нужен только для drift-check и экспорта токенов. По умолчанию отсутствует.
- `./exports` — сгенерированные токены и ассеты (gitignored, если не решено иначе).

См. `specs/core/workspace.spec.md`.

## Vault и onto-vault (зоны ответственности)

Obsidian vault делят два независимых агентских контура: **ты** (workspace-агент, дизайн по `specs/`) и **onto-агент** (онтологический слой знаний по CLAUDE.md vault'а). Ни один не читает bootstrap другого, поэтому таблица зон продублирована в обоих канонах и меняется **только синхронно**:

| Зона | Кто пишет | Твоя роль |
|---|---|---|
| `Projects/<P>/Specs/`, `Projects/<P>/Tasks/` | ты | твоя зона (через symlink / полный путь) |
| `Projects/<P>/ТЗ/` | человек / продуктовая команда | только чтение |
| `onto/`, `sources/`, `ontology.yaml`, `.ontovault/` | onto-агент | **не трогать никогда** |

**Задача считается завершённой по финальной записи в `worklog.md`** задачи (`— DONE: ...`) — это триггер дистилляции для onto-агента. Ссылки на vault-артефакты — всегда полным vault-относительным путём (`[[Projects/<P>/Tasks/<task-id>/worklog.md]]`), не basename.

Полный контракт: `specs/core/vault-contract.spec.md`.

## SDD Spec Structure

```
specs/
├── INDEX.md           — карта всех spec с триггерами
├── LOADER.md          — контракт on-demand подгрузки (schema v2)
├── core/              — always loaded
│   ├── project.spec.md         — Constitution D-01..D-14 + DoD + источники правды
│   ├── workspace.spec.md       — layout, Figma как source of truth
│   ├── vault-contract.spec.md  — контракт с Obsidian vault и onto-агентом
│   ├── design-system.spec.md   — иерархия ДС, что считается каноном
│   ├── naming.spec.md          — нейминг слоёв, компонентов, переменных, фреймов
│   ├── git-policy.spec.md      — что не коммитить, ветки
│   └── commits.spec.md         — Conventional Commits, author, language
├── domain/            — on-demand по triggers
│   └── figma-structure, components, variables, color, typography, layout,
│       states, accessibility, prototyping, ux-writing, tokens-export,
│       handoff, assets
├── workflows/         — по mode
│   └── task-modes, design-workflow, clarify, critique, review-pipeline,
│       handoff-quality, drift-check, decision-gates, versioning,
│       team-dispatch, agent-log, checkpoint, anti-patterns
├── per-epic/
│   └── EPIC-TEMPLATE.md        — дизайн-эпик (SDD level 2)
└── per-task/
    ├── DESIGN-TASK-TEMPLATE.spec.md — pre-spec дизайн-задачи (Job + AC + Guardrails + DoR)
    ├── QUICK-TEMPLATE.spec.md       — тонкая спека для Quick mode
    ├── COMPONENT-TEMPLATE.md        — спецификация компонента ДС
    └── DDR-TEMPLATE.md              — Design Decision Record
```

**Сквозной пример заполнения:** `bootstrap/examples/` — end-to-end mock-фича со всеми артефактами.

## Loading rules

**Every subagent must:**
1. Прочитать `specs/INDEX.md` — увидеть все доступные spec'и.
2. Прочитать **все `specs/core/*.spec.md`** — always loaded (включая Constitution в `project.spec.md §1`).
3. По task scope (figma_nodes / surfaces / task_keywords / attachments) подгрузить matching `specs/domain/*.spec.md`.
4. По mode (Quick / Standard / Full) подгрузить matching `specs/workflows/*.spec.md`.

См. `specs/LOADER.md` для полного контракта.

## Task entry point

Для **большого эпика** (>1 экран / новый раздел) — начать с `specs/per-epic/EPIC-TEMPLATE.md`.

Для новой задачи:

1. **Mode detection** — `specs/workflows/task-modes.spec.md`.
2. **Design workflow** (Standard/Full) — `specs/workflows/design-workflow.spec.md` (включая states-контракт 4a/4b/4c — `specs/workflows/handoff-quality.spec.md`).
3. **Pre-spec** — создать по соответствующему шаблону:
   - Standard / Full → `specs/per-task/DESIGN-TASK-TEMPLATE.spec.md`
   - Quick → `specs/per-task/QUICK-TEMPLATE.spec.md`
   - Новый компонент ДС → `specs/per-task/COMPONENT-TEMPLATE.md`
   - Спорное решение зафиксировать → `specs/per-task/DDR-TEMPLATE.md`
4. **Где живут per-task артефакты** — `<PER_TASK_SPEC_LOCATION>/<task-id>/`, см. `specs/core/project.spec.md §5`.

## Slash-команды

| Команда | Что делает |
|---|---|
| `/design.init` | Первичная настройка workspace: интервью + проставление значений |
| `/design.audit` | Аудит Figma-файла по правилам ДС: detached, хардкод, spacing, состояния |
| `/design.handoff` | Из фрейма Figma → handoff-спека для разработки |
| `/design.tokens` | Variables Figma → tokens JSON (+ платформенный экспорт) |
| `/design.drift` | Сверка реализации в `./code` с макетом |
| `/design.critique` | Дизайн-критика макета: иерархия, состояния, a11y, тексты |

## Hard rules (always applied)

Эти правила в core, **всегда** активны независимо от mode и domain:

- **Figma — единственный source of truth для визуала.** Локальные `.md` описывают, но не заменяют макет — `specs/core/workspace.spec.md`
- **Ничего не менять в Figma без явного разрешения человека** — Claude по умолчанию read-only в Figma; запись только через ручные шаги, описанные в handoff — `specs/core/design-system.spec.md`
- **Никаких хардкод-значений** там, где есть variable/style — `specs/domain/variables.spec.md`
- **Нейминг по контракту** — `specs/core/naming.spec.md`
- **Все состояния обязательны** до сдачи — `specs/domain/states.spec.md`
- **WCAG `<WCAG_LEVEL>` — минимум**, не пожелание — `specs/domain/accessibility.spec.md`
- **Conventional Commits (терсеный стиль, без body), no AI mentions** — `specs/core/commits.spec.md`
- **Never commit:** CLAUDE.md, `*-plan.md`, .md instructions, экспортированные PNG-мокапы, `.figma-cache/` — `specs/core/git-policy.spec.md`

## Stop conditions (Tier 2 — hard stop)

См. `specs/workflows/decision-gates.spec.md`:

- Clarify needed (продуктовый вопрос без ответа в ТЗ)
- Нужен выбор между несколькими валидными дизайн-направлениями
- Любой CRITICAL finding (DS_VIOLATION / A11Y / DESIGN_DRIFT)
- Изменение публичного компонента ДС (breaking change для потребителей)
- Scope violation (правка вне заявленных фреймов)
- Reroute limit reached
- Требуется запись в Figma (Claude read-only)

## Memory and auto-memory

Системный memory loader (если включён в Claude Code) загружается автоматически. Memory дополняет, не заменяет, специфику этого workspace.

## Template provenance

Этот workspace собран по шаблону `design-workspace-template`. После клонирования:

1. Запустить `./scripts/setup-tools.sh` (проверит Claude Code, node, подключит Figma MCP).
2. Запустить `/design.init` в Claude Code (или `./scripts/init.sh`).
3. Открыть `specs/core/project.spec.md` — проверить §1 Constitution (D-01..D-14), §2 DoD, §3 источники правды.
4. Открыть `specs/core/design-system.spec.md` — сверить иерархию ДС с реальным файлом.
5. Открыть `specs/domain/*` — подогнать шкалы, коллекции variables, брейкпоинты под реальный проект.
6. (Опционально) Скопировать `.claude/settings.local.json.example` → `.claude/settings.local.json`.
7. Открыть `README.md` — там пошаговая инструкция и таблица всех placeholder'ов.
