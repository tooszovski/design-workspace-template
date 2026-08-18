---
name: tokens-export
layer: domain
purpose: Экспорт Figma variables в токены, формат, платформенная трансформация, синхронизация с кодом
applies_to:
  paths: ["exports/tokens/**", "<TOKENS_EXPORT_PATH>"]
  task_keywords: ["токены", "tokens", "экспорт", "export", "style dictionary", "синхронизация", "выгрузка переменных"]
  triggers: ["задача про перенос значений дизайна в код"]
owner: figma-analyst
---

# Tokens Export

Токены — машиночитаемая проекция Figma variables. Источник один: `<FIGMA_DS_FILE_KEY>`. Правка токенов руками запрещена — она будет затёрта следующей выгрузкой.

## Поток

```
Figma variables → /design.tokens → exports/tokens/*.json → трансформация → <TOKENS_EXPORT_PATH>
```

Каждый шаг воспроизводим: повторный запуск на неизменённом файле даёт идентичный результат. Недетерминированный экспорт (случайный порядок ключей, таймстемпы внутри файла) ломает диффы и делает ревью невозможным.

## Формат

Базовый формат — [DTCG](https://tr.designtokens.org/) (`$value` / `$type` / `$description`):

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

Правила:

- Алиасы сохраняются как ссылки `{path.to.token}`, не разворачиваются в значения. Развёртка убивает связь и делает ребрендинг ручным.
- Один файл на коллекцию: `primitives.json`, `semantic.json`, `spacing.json`, `radius.json`, `typography.json`.
- Режимы (темы) — отдельные файлы или отдельная секция `$extensions.modes`, выбор фиксируется здесь при init и дальше не меняется.
- Ключи в `kebab-case`, порядок — алфавитный.

## Платформенная трансформация

| Платформа | Выход | Особенности |
|---|---|---|
| Web | CSS custom properties / JS-объект | `--action-primary`; темы через `[data-theme]` |
| iOS | Swift-константы / Asset Catalog | цвета в Asset Catalog с light/dark |
| Android | XML resources / Compose | `colors.xml`, `dimens.xml` |

Трансформация не добавляет значений, которых нет в Figma, и не переименовывает — только меняет синтаксис. Если платформе нужно значение, которого нет в ДС, это задача на ДС, а не на скрипт экспорта.

## Синхронизация

1. Экспорт запускается **после** публикации библиотеки, не до.
2. Результат попадает в `<TOKENS_EXPORT_PATH>` через pull request, не прямым коммитом: разработка должна увидеть дифф.
3. Дифф токенов читается как API-дифф. Удаление или переименование токена — breaking change (`workflows/versioning.spec.md`).
4. Расхождение между Figma и `<TOKENS_EXPORT_PATH>` — `TOKEN_DRIFT`:

| Severity | Когда |
|---|---|
| MINOR | отличается `$description` |
| IMPORTANT | отличается значение токена |
| CRITICAL | токен есть в коде, но удалён из Figma (или наоборот) |

## Что не токенизируется

Уникальные значения одного экрана, координаты внутри иллюстраций, значения экспериментов `🚧`. Токен, у которого одно применение, — не токен, а константа не на своём месте.

## Cross-refs

- domain/variables.spec.md — источник токенов
- workflows/versioning.spec.md — версии и breaking changes
- workflows/drift-check.spec.md — сверка с реализацией
- core/workspace.spec.md — где лежат экспорты
