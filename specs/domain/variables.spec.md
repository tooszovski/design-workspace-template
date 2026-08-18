---
name: variables
layer: domain
purpose: Коллекции Figma variables, режимы (темы/платформы/плотность), алиасинг, запрет хардкода
applies_to:
  task_keywords: ["variable", "переменная", "токен", "token", "тема", "theme", "dark mode", "режим", "mode", "алиас"]
  triggers: ["задача затрагивает цветовую схему, темы или значения дизайн-токенов"]
owner: reviewer-designsystem
---

# Variables

## Коллекции

| Коллекция | Содержит | Режимы |
|---|---|---|
| `Primitives` | сырые значения: палитра, числовая шкала | один режим |
| `Semantic` | роли: `action/primary`, `text/secondary`, `surface/raised` | темы (light / dark / …) |
| `Spacing` | шкала отступов `<SPACING_SCALE>` | плотность (comfortable / compact), если нужна |
| `Radius` | радиусы скругления | один режим |
| `Typography` | размеры, межстрочные, начертания | платформы `<PLATFORMS>`, если различаются |

## Алиасинг

Правило одного шага: **semantic ссылается на primitive, компонент ссылается на semantic.**

```
color/blue/500   (Primitives, hex)
      ↑
action/primary   (Semantic, alias)
      ↑
Button/Primary → fill = action/primary
```

Нарушения:

| Нарушение | Severity |
|---|---|
| Компонент ссылается на primitive напрямую | IMPORTANT |
| Semantic содержит сырой hex вместо алиаса | IMPORTANT |
| Цепочка алиасов длиннее двух шагов | MINOR |
| Слой с сырым значением там, где есть подходящая variable | CRITICAL |

## Режимы

Режим — это **ось вариативности**, а не «ещё одна тема на всякий случай».

Правила:

1. Все переменные коллекции обязаны иметь значение во всех режимах. Пустое значение в режиме — CRITICAL: в этой теме экран сломается.
2. Режимы не добавляются в `Primitives`. Палитра одна, роли меняются.
3. При добавлении режима перепроверяется **контраст во всех парах** text/surface (`domain/accessibility.spec.md`). Тёмная тема — самая частая точка отказа контраста.
4. Смена режима не должна менять размеры и раскладку. Если в тёмной теме поехала вёрстка — режим используют не по назначению.

## Именование значений

Semantic-имя описывает роль:

| ✅ | ❌ | Почему |
|---|---|---|
| `text/danger` | `text/red` | в тёмной теме он не красный |
| `surface/raised` | `surface/white` | в тёмной теме он не белый |
| `action/primary` | `action/blue-500` | привязка к палитре ломает ребрендинг |
| `space/stack-md` | `space/16` | значение меняется, роль — нет |

## Хардкод

Сырое значение допустимо ровно в двух случаях:

1. Слой помечен `🚧` — эксперимент, блокирующий сдачу (D-03).
2. Значение физически не токенизируемо (координата в иллюстрации, точка градиента в декоративном фоне) — и это отмечено слоем `spec:` рядом.

Всё остальное — `DS_VIOLATION severity CRITICAL`.

## Экспорт

Variables — источник для `exports/tokens/` (`domain/tokens-export.spec.md`). Следствие: имя variable попадёт в код. Переименование = breaking change для потребителей токенов, оформляется по `workflows/versioning.spec.md`.

## Cross-refs

- core/design-system.spec.md — уровни ДС
- core/naming.spec.md — формат имён
- domain/color.spec.md — палитра и контраст
- domain/tokens-export.spec.md — выгрузка в код
- domain/accessibility.spec.md — проверка контраста по режимам
