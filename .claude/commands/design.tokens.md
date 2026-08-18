---
description: Выгрузить Figma variables в design tokens и трансформировать под платформы
allowed-tools: Read, Write, Edit, Grep, Glob, Bash, mcp__figma__get_figma_data
---

# /design.tokens

Экспорт `<FIGMA_DS_FILE_KEY>` → `exports/tokens/` → `<TOKENS_EXPORT_PATH>`.

## Предусловия

- Библиотека опубликована. Экспорт до публикации выгрузит неопубликованные значения.
- Есть доступ к файлу ДС через MCP.

## Шаг 1 — Выгрузка

`mcp__figma__get_figma_data` по файлу `<FIGMA_DS_FILE_KEY>`. Собрать коллекции: `Primitives`, `Semantic`, `Spacing`, `Radius`, `Typography` (`domain/variables.spec.md`).

Для каждой переменной зафиксировать: имя, тип, значение в каждом режиме, алиас (если ссылается на другую), описание.

## Шаг 2 — Проверка перед записью

| Проверка | Действие при провале |
|---|---|
| Переменная без значения в одном из режимов | CRITICAL, остановиться: в этой теме экраны сломаются |
| Semantic содержит сырой hex вместо алиаса | IMPORTANT, вынести в отчёт |
| Цепочка алиасов длиннее двух шагов | MINOR |
| Имя вне контракта `core/naming.spec.md` | IMPORTANT |

Экспортировать при CRITICAL нельзя — сломанное значение уедет в код.

## Шаг 3 — Запись в DTCG

`exports/tokens/<collection>.json`, формат `$value` / `$type` / `$description`:

```json
{
  "action": {
    "primary": {
      "$type": "color",
      "$value": "{color.blue.500}",
      "$description": "Основное действие на экране"
    }
  }
}
```

Обязательно:

- Алиасы остаются ссылками `{path.to.token}` — **не разворачивать** в значения.
- Ключи `kebab-case`, порядок алфавитный.
- Никаких таймстемпов и случайного порядка внутри файла: повторный запуск на неизменённом файле обязан дать побайтово тот же результат.
- Режимы — по схеме, зафиксированной в `domain/tokens-export.spec.md` при init.

## Шаг 4 — Трансформация

Только если задан `<TOKENS_EXPORT_PATH>`. Для каждой платформы из `<PLATFORMS>`:

| Платформа | Выход |
|---|---|
| Web | CSS custom properties + JS-объект; темы через `[data-theme]` |
| iOS | Swift-константы или Asset Catalog с light/dark |
| Android | `colors.xml`, `dimens.xml` или Compose |

Трансформация меняет **только синтаксис**. Не добавлять значений, которых нет в Figma, и не переименовывать.

## Шаг 5 — Дифф

Сравнить с предыдущей версией в `<TOKENS_EXPORT_PATH>` и классифицировать (`workflows/versioning.spec.md`):

| Изменение | Категория |
|---|---|
| новый токен | additive |
| изменено значение | modifying |
| удалён или переименован токен | **breaking** |

Breaking → не записывать молча. Показать список, потребовать подтверждения, напомнить про DDR и changelog.

## Шаг 6 — Отчёт

```
Signal: COMPLETE | FAIL
Checkpoint: exports/tokens/REPORT.md
Токенов: N · Добавлено: A · Изменено: M · Удалено: D
Категория изменения: additive | modifying | breaking
```

Запись в `<TOKENS_EXPORT_PATH>` идёт через pull request, не прямым коммитом: разработка должна увидеть дифф.
