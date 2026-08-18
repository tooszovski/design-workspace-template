---
name: design-workflow
layer: workflow
purpose: Шаги дизайн-задачи от ТЗ до сдачи, включая states-контракт
applies_to:
  task_keywords: ["workflow", "процесс", "шаги", "как делать задачу"]
  loaded_for_modes: ["quick", "standard", "full"]
owner: design-lead
---

# Design Workflow

## Шаг 0 — Приём задачи

1. Прочитать ТЗ из `<TASK_SPEC_SOURCE_PATH>`.
2. Определить mode (`workflows/task-modes.spec.md`).
3. Создать `<PER_TASK_SPEC_LOCATION>/<task-id>/` и `worklog.md` с первой записью.
4. Проверить версию потребляемой библиотеки в `📐 Cover` продуктового файла.

Выход: папка задачи, mode зафиксирован.

## Шаг 1 — Clarify

Только Standard/Full. Собрать все неясности **одним пакетом** и задать до начала работы (`workflows/clarify.spec.md`). Один вопрос в день растягивает задачу на неделю.

Если ТЗ отвечает на всё — записать в worklog `— CLARIFY: не требуется` и идти дальше.

Выход: `spec.md` по `per-task/DESIGN-TASK-TEMPLATE.spec.md` со статусом `approved`.

## Шаг 2 — Контекст

1. Найти существующие решения похожей задачи в продукте — переиспользовать, а не изобретать.
2. Выгрузить нужные фреймы через Figma MCP (`domain/figma-structure.spec.md`).
3. Проверить, каких компонентов не хватает в `<DS_LIBRARY_NAME>`.
4. Для Full — посмотреть `<REFERENCE_PLATFORM>`, если она задана.

Выход: список переиспользуемых компонентов, список недостающих.

## Шаг 3 — Структура

Сначала скелет: иерархия, порядок блоков, что главное на экране (D-10). На этом шаге не выбираются цвета и не полируются отступы.

Для Full — 2–3 варианта структуры с явным сравнением, выбор фиксируется в DDR (`per-task/DDR-TEMPLATE.md`).

Выход: каркас экрана, согласованный с человеком, если вариантов было несколько.

## Шаг 4 — States-контракт

Порядок обязателен, полировка `data`-состояния до сборки остальных запрещена (`domain/states.spec.md`).

| Шаг | Действие | Проверка |
|---|---|---|
| **4a** | Заполнить матрицу покрытия в `spec.md` | ни одной пустой клетки |
| **4b** | Собрать каждое `✅`-состояние отдельным фреймом | имена по `core/naming.spec.md` |
| **4c** | Сверить матрицу с Figma | каждая `✅` = реальный фрейм; расхождение — FAIL |

## Шаг 5 — Полировка

Токены, отступы по шкале, типографика, тексты, адаптив, ассеты. Здесь применяются `domain/layout`, `color`, `typography`, `ux-writing`, `assets`.

## Шаг 6 — Самопроверка

Запустить `/design.audit` по фреймам задачи. Все CRITICAL закрыть до критики — не отдавать ревьюерам то, что ловится автоматически.

## Шаг 7 — Критика и ревью

По `workflows/review-pipeline.spec.md`. Standard/Full — параллельный запуск ревьюеров ДС / a11y / текстов.

Findings классифицируются, CRITICAL закрываются, IMPORTANT — закрываются или обосновываются в worklog.

## Шаг 8 — Handoff

Написать `handoff.md` по `domain/handoff.spec.md`. Пройти гейты G1–G6 (`workflows/handoff-quality.spec.md`).

## Шаг 9 — Сдача

1. Перевести фреймы на `✅`-страницу.
2. Проверить DoD (`core/project.spec.md §2`).
3. Закрыть `worklog.md` строкой `— DONE: <итог>`.
4. Перевести задачу в `<TRACKER_TESTING_STATUS>`.
5. Написать `agent-log.md` (`workflows/agent-log.spec.md`).

## Шаг 10 — Приёмка реализации

После реализации — `/design.drift` (`workflows/drift-check.spec.md`). Это отдельная задача в трекере, не хвост текущей.

## Сокращённый путь для Quick

Шаги 0 → 5 → 6 → 9. Clarify, структура, states-контракт, критика и handoff пропускаются, если правка не создаёт новых состояний и не трогает ДС.

## Cross-refs

- workflows/task-modes.spec.md — выбор режима
- workflows/clarify.spec.md — формат вопросов
- workflows/review-pipeline.spec.md — ревью
- workflows/handoff-quality.spec.md — гейты сдачи
- workflows/decision-gates.spec.md — где останавливаться
