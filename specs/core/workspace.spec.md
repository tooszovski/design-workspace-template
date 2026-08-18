---
name: workspace
layer: core
purpose: Layout design-workspace, границы зон, Figma как внешний source of truth
always_loaded: true
owner: design-lead
---

# Workspace Layout

## Структура

```
<workspace-root>/
├── CLAUDE.md              — bootstrap, не коммитится
├── README.md
├── .mcp.json              — Figma MCP (gitignored, из .mcp.json.example)
├── .claude/               — агенты, команды, настройки
├── scripts/
├── specs/                 — symlink на vault Projects/<PROJECT_NAME>/Specs/ (или обычная папка)
├── exports/               — сгенерированные токены и ассеты (gitignored)
│   ├── tokens/
│   └── assets/
├── code/                  — опциональный symlink на <CODE_REPO_PATH> (только чтение)
└── bootstrap/             — REQUIREMENTS + сквозные примеры
```

## Границы

| Зона | Право агента |
|---|---|
| `specs/`, `<PER_TASK_SPEC_LOCATION>/` | чтение + запись |
| `exports/` | чтение + запись (перегенерируется, руками не правится) |
| Figma через MCP | **только чтение** (D-02) |
| `code/` | **только чтение** — для drift-check; правки делает разработка |
| `<TASK_SPEC_SOURCE_PATH>` (ТЗ) | только чтение |
| `.claude/`, `CLAUDE.md` | правка только по явной просьбе человека |

## Figma как внешний source of truth

Макеты не лежат в репозитории. Следствия:

1. **Нельзя «прочитать проект» с диска.** Состояние дизайна получается через Figma MCP (`mcp__figma__get_figma_data`) по file key + node id. Без node id тянуть весь файл дорого — сначала уточнить у человека фрейм.
2. **Кэш обязателен для больших файлов.** Выгруженный JSON кладётся в `.figma-cache/<file-key>/<node-id>.json` (gitignored) и переиспользуется в рамках задачи. Кэш считается протухшим при смене `lastModified` файла.
3. **Скриншоты — вспомогательный канал.** `mcp__figma__download_figma_images` в `.figma-cache/img/`. Изображение отвечает на «как выглядит», JSON — на «из чего собрано». Для аудита нужен JSON.
4. **Нет доступа к MCP → нет аудита.** Не выдумывать содержимое макета по названию задачи. Отсутствие доступа — это FAIL с причиной, а не догадка.

## Опциональный `code/`

Появляется, только если при init указан `<CODE_REPO_PATH>`. Нужен для двух сценариев:

- `/design.drift` — сверка реализации с макетом (`workflows/drift-check.spec.md`)
- `/design.tokens` — запись экспорта в `<TOKENS_EXPORT_PATH>` (`domain/tokens-export.spec.md`)

Во всех остальных случаях `code/` не читается — он раздувает контекст и не относится к дизайн-задаче.

## Запуск

Claude Code запускается из workspace root. Пути в спеках — относительные от root (`specs/...`, `exports/...`).

## Cross-refs

- core/vault-contract.spec.md — что живёт в Obsidian
- core/git-policy.spec.md — что не коммитить
- domain/figma-structure.spec.md — как устроен файл в Figma
- workflows/drift-check.spec.md — работа с `code/`
