---
name: naming
layer: core
purpose: Контракт нейминга страниц, фреймов, слоёв, компонентов, variables и файлов экспорта
always_loaded: true
owner: design-lead
---

# Naming

Нейминг — это API дизайна. По имени должно быть понятно, что это, без открытия слоя.

## Общие правила

- Язык имён — **английский** для всего, что попадает в код (компоненты, variables, стили, экспорт ассетов). `<DEV_LANGUAGE>` допустим только в текстовых слоях контента и названиях страниц/секций.
- Регистр: `PascalCase` для компонентов, `kebab-case` для variables и файлов, `Sentence case` для страниц и секций.
- Никаких `Frame 427`, `Group 12`, `Rectangle 3`, `Copy of ...`, `Component 1`. Автоимя = технический долг.
- Никаких дат и инициалов в именах слоёв — история живёт в версиях Figma, не в неймингах.

## Страницы файла

```
📐 Cover
🚧 WIP
✅ <Раздел>
📦 Components        (только в файле ДС)
🎨 Foundations       (только в файле ДС)
🗃 Archive
```

Эмодзи-префикс задаёт статус страницы, читается агентом при аудите (`domain/figma-structure.spec.md`).

## Фреймы экранов

```
<PROJECT_PREFIX>-<номер> · <Экран> · <Состояние> · <Брейкпоинт>
```

Примеры:

- `<PROJECT_PREFIX>-142 · Checkout · default · desktop`
- `<PROJECT_PREFIX>-142 · Checkout · empty-cart · mobile`
- `<PROJECT_PREFIX>-142 · Checkout · error-payment · mobile`

Разделитель — ` · ` (пробел, middle dot, пробел). Он парсится агентом, поэтому не заменяется на дефис или слэш.

## Слои внутри фрейма

Имя описывает **роль**, а не внешность:

| ✅ | ❌ |
|---|---|
| `header` | `Frame 12` |
| `price-total` | `Text bold 24` |
| `divider` | `Line 3` |
| `state:empty` | `Group 8 copy` |

Служебные префиксы:

| Префикс | Значение |
|---|---|
| `state:` | слой-состояние, показывается взаимоисключающе (`state:loading`) |
| `spec:` | аннотация для разработки, не часть UI, не экспортируется |
| `🚧` | эксперимент/незакрытое решение, блокирует сдачу |
| `_` | вспомогательный слой (маска, направляющая), игнорируется аудитом |

## Компоненты

```
<Category>/<Name>
<Category>/<Name>/<Subcomponent>
```

Примеры: `Button/Primary`, `Input/Text`, `Card/Product`, `Navigation/Tab Bar`, `Icon/24/Chevron Right`.

Variant properties — `Title Case` с предсказуемыми значениями:

| Property | Значения |
|---|---|
| `Size` | `sm` / `md` / `lg` |
| `State` | `default` / `hover` / `pressed` / `focused` / `disabled` |
| `Variant` | `primary` / `secondary` / `tertiary` / `danger` |
| `Icon` | boolean |

Одно и то же property в разных компонентах называется одинаково. `State` в одном месте и `Status` в другом — DS_VIOLATION.

## Variables

```
<коллекция>/<группа>/<роль>[/<модификатор>]
```

| Тип | Пример |
|---|---|
| primitive color | `color/blue/500` |
| semantic color | `action/primary`, `text/secondary`, `surface/raised` |
| spacing | `space/xs`, `space/inline-sm`, `space/stack-lg` |
| radius | `radius/sm`, `radius/pill` |
| typography | `font/body/md`, `font/heading/lg` |

Semantic-имя описывает **назначение**, не вид: `text/danger`, не `text/red`.

## Экспорт ассетов

```
<категория>-<имя>[-<вариант>]@<масштаб>.<ext>
```

Примеры: `icon-chevron-right@2x.png`, `illustration-empty-cart.svg`, `logo-primary-dark.svg`.

Только `kebab-case`, только ASCII, без пробелов. Полные правила — `domain/assets.spec.md`.

## Проверка

`/design.audit` проверяет нейминг и выдаёт findings `NAMING`:

| Severity | Когда |
|---|---|
| MINOR | автоимя вспомогательного слоя |
| IMPORTANT | автоимя значимого слоя, неконсистентное variant property |
| CRITICAL | `🚧`-слой в фрейме, помеченном готовым к сдаче |

## Cross-refs

- domain/figma-structure.spec.md — страницы и секции
- domain/components.spec.md — анатомия компонента
- domain/variables.spec.md — коллекции
- domain/assets.spec.md — экспорт
