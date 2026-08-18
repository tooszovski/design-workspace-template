---
name: vault-contract
layer: core
purpose: Контракт с Obsidian vault и onto-агентом — symlink specs, Tasks/, запретные зоны, worklog как сигнал
always_loaded: true
owner: design-lead
---

# Vault Contract

Применяется, если при init выбрано хранение артефактов в Obsidian. Если выбран режим «только репозиторий» — весь файл сводится к тому, что `<PER_TASK_SPEC_LOCATION>` лежит внутри workspace, а раздел про onto-агента неактуален.

## Symlink-паттерн

```
workspace/specs  →  <VAULT>/Projects/<PROJECT_NAME>/Specs/
```

- Спеки физически живут в vault, чтобы быть доступными из Obsidian и попадать в дистилляцию знаний.
- В workspace остаётся symlink, поэтому все пути `specs/...` в спеках и промптах работают без изменений.
- `/specs` добавлен в `.gitignore` — спеки не дублируются в git.
- **Не «возвращать» specs/ в репозиторий.** Если symlink сломан — чинить symlink, не копировать файлы.

## Раскладка проекта в vault

```
<VAULT>/Projects/<PROJECT_NAME>/
├── ТЗ/                 — входящие требования (человек пишет, агент читает)
├── Specs/              — цель symlink'а specs/
├── Tasks/              — <PER_TASK_SPEC_LOCATION>: по папке на задачу
│   └── <PROJECT_PREFIX>-NNN/
│       ├── spec.md
│       ├── worklog.md
│       ├── handoff.md
│       └── agent-log.md
└── Agent Logs/         — <AGENT_LOGS_LOCATION>: кросс-задачный журнал
```

## Зоны ответственности

Vault делят два независимых агентских контура. Таблица продублирована в CLAUDE.md workspace'а и в CLAUDE.md vault'а — **менять только синхронно**.

| Зона | Кто пишет | Роль дизайн-агента |
|---|---|---|
| `Projects/<P>/Specs/`, `Projects/<P>/Tasks/` | дизайн-агент | своя зона |
| `Projects/<P>/ТЗ/` | человек / продукт | только чтение |
| `onto/`, `sources/`, `ontology.yaml`, `.ontovault/` | onto-агент | **не трогать никогда** |
| Остальной vault | человек | только чтение |

## worklog как сигнал завершения

Финальная строка `— DONE: <краткий итог>` в `worklog.md` — триггер дистилляции для onto-агента. Следствия:

- Не писать `DONE`, пока DoD (`core/project.spec.md §2`) не выполнен.
- Не писать `DONE` дважды в одном worklog.
- Если задача откатилась после `DONE` — новая запись `— REOPENED: <причина>`, затем работа и новый `— DONE`.

## Ссылки на артефакты

Всегда полным vault-относительным путём:

- ✅ `[[Projects/<PROJECT_NAME>/Tasks/<PROJECT_PREFIX>-142/handoff.md]]`
- ❌ `[[handoff.md]]` — basename ломается при совпадении имён между задачами

## Cross-refs

- core/workspace.spec.md — layout
- core/project.spec.md §5 — состав папки задачи
- workflows/agent-log.spec.md — формат финального отчёта
