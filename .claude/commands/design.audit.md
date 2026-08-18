---
description: Аудит Figma-фрейма по правилам дизайн-системы — detached, хардкод, spacing, состояния, нейминг
allowed-tools: Read, Write, Grep, Glob, Bash, mcp__figma__get_figma_data, mcp__figma__download_figma_images
---

# /design.audit

Автоматическая проверка макета на нарушения правил. Идёт **до** ревьюеров: не тратить их проход на то, что ловится машинно.

**Аргумент:** ссылка на фрейм Figma или `<file-key> <node-id>`. Без аргумента — спросить.

## Шаг 1 — Загрузка

1. Извлечь `file-key` и `node-id` из ссылки. В URL id через дефис (`1234-5678`), в API — через двоеточие (`1234:5678`).
2. Проверить кэш `.figma-cache/<file-key>/<node-id>.json`. Использовать, если `lastModified` файла не изменился.
3. `mcp__figma__get_figma_data` с `nodeId`. Сохранить в кэш.
4. Нет доступа → остановиться с `FAIL: figma access`. Не достраивать содержимое макета по названию задачи.

Читать спеки: `core/design-system`, `core/naming`, `domain/components`, `domain/variables`, `domain/layout`, `domain/states`, `domain/color`, `domain/typography`.

## Шаг 2 — Проверки

| # | Что | Как искать | Код | Severity |
|---|---|---|---|---|
| 1 | Detached-инстансы | узлы, визуально повторяющие библиотечный компонент, но без `componentId` | `DS_VIOLATION` | CRITICAL |
| 2 | Хардкод цвета | `fills` с прямым значением вместо `boundVariables` | `DS_VIOLATION` | CRITICAL |
| 3 | Хардкод отступа | `itemSpacing`/`padding*` вне `<SPACING_SCALE>` | `LAYOUT` | IMPORTANT |
| 4 | Ручная типографика | текстовый узел без `textStyleId` | `TYPO` | IMPORTANT |
| 5 | Прямая ссылка на primitive | компонент/экран ссылается на `color/*/NNN` вместо семантической роли | `DS_VIOLATION` | IMPORTANT |
| 6 | Автоимена | `Frame N`, `Group N`, `Rectangle N`, `Copy of` | `NAMING` | IMPORTANT |
| 7 | Слои `🚧` | префикс в имени | `NAMING` | CRITICAL, если фрейм на `✅`-странице |
| 8 | Отсутствующие состояния | нет фреймов `empty` / `loading` / `error` в секции | `STATE_MISSING` | CRITICAL |
| 9 | Нет `focused` | интерактивный компонент без варианта `State: focused` | `A11Y` | CRITICAL |
| 10 | Малый тач-таргет | интерактивный узел <44×44 без `spec:hit-area` рядом | `A11Y` | IMPORTANT |
| 11 | Контраст | пары текст/фон по всем режимам | `A11Y_CONTRAST` | CRITICAL для основного текста |
| 12 | Fixed-ширина | `Fixed` в адаптивном контейнере | `LAYOUT` | IMPORTANT |
| 13 | Deprecated-компонент | инстанс компонента с `[deprecated]` в описании | `DS_VIOLATION` | CRITICAL |
| 14 | Вложенность инстансов | глубина >3 | `DS_VIOLATION` | MINOR |
| 15 | Иконка без `spec:label` | инстанс из `Icon/*` внутри интерактивного узла без текста | `A11Y` | CRITICAL |

Контраст (11) считать по формуле WCAG для каждой реальной пары, включая placeholder, disabled-текст, текст на плашках и границы полей. Порог — `<WCAG_LEVEL>`.

## Шаг 3 — Отчёт

Записать в `<PER_TASK_SPEC_LOCATION>/<task-id>/audit.md` (или в `audit-<node-id>.md`, если задача не указана):

```markdown
# Audit · <фрейм> · <дата>

Источник: Figma <file-key> · node <node-id>
Проверок: 15 · Найдено: N critical, M important, K minor

## CRITICAL
### DS_VIOLATION: detached-инстанс кнопки
Где: `Checkout / actions / Frame 12`
Что: узел повторяет `Button/Primary`, но не связан с компонентом
Действие: заменить на инстанс `Button/Primary`, variant `primary/md`

## IMPORTANT
...

## MINOR
...

## Чисто
Проверки без нарушений: 3, 5, 7, 12, 14
```

Раздел «Чисто» обязателен: без него непонятно, проверка не сработала или нарушений не было.

## Шаг 4 — Возврат

```
Signal: COMPLETE | FAIL
Checkpoint: <путь к audit.md>
Findings: N critical, M important, K minor
SpecsUsed: [...]
SpecsMissing: [...]
```

Любой CRITICAL блокирует переход к ревью (`workflows/review-pipeline.spec.md`).

## Ограничения

- Аудит не правит макет: Claude read-only в Figma (D-02).
- Аудит не заменяет критику: он проверяет правила, а не решение задачи (`workflows/critique.spec.md`).
- Проверки 1 и 5 эвристические — помечать такие findings как `вероятно` и не выдавать за факт.
