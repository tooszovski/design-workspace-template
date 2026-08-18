---
name: component-template
kind: template
purpose: Спецификация компонента дизайн-системы — API, анатомия, состояния, правила применения
owner: reviewer-designsystem
---

# <Category>/<Name>

```yaml
component: <Category>/<Name>
status: draft | review | published | deprecated
version_added: <MAJOR.MINOR.PATCH>
replaces: <компонент или ->
figma_node: <node-id в FIGMA_DS_FILE_KEY>
```

## Назначение

Одно предложение: какую задачу решает.

## Когда применять

- <сценарий>

## Когда НЕ применять

- <сценарий> → использовать `<другой компонент>`

Этот раздел важнее предыдущего: без него компонент начнут использовать везде.

## Анатомия

| Часть | Обязательна | Токен / компонент |
|---|---|---|
| контейнер | да | `surface/raised`, `radius/md`, `space/inset-md` |
| иконка | нет | `Icon/24/*`, цвет наследует текст |
| заголовок | да | `font/label/md`, `text/primary` |

## API

### Variants

| Property | Значения | По умолчанию | Назначение |
|---|---|---|---|
| `Variant` | primary / secondary / danger | primary | визуальный вес действия |
| `Size` | sm / md / lg | md | плотность контекста |
| `State` | default / hover / pressed / focused / disabled | default | — |

### Boolean

| Property | По умолчанию | Что показывает |
|---|---|---|

### Слоты

| Property | Тип | Что подставляется |
|---|---|---|
| `label` | text | текст действия |
| `icon` | instance swap | иконка из `Icon/24/*` |

Общее число комбинаций: `<N>`. Больше 40 — разделить компонент (`domain/components.spec.md`).

## Состояния

| State | Отличие | Токены |
|---|---|---|
| default | — | `action/primary` |
| hover | фон темнее | `action/primary-hover` |
| pressed | фон темнее + сжатие 98% | `action/primary-hover` |
| focused | внешняя обводка 2pt | `border/focus`, контраст ≥3:1 |
| disabled | пониженная насыщенность, курсор не меняется | `action/disabled`, `text/disabled` |

`focused` обязателен (`domain/accessibility.spec.md`).

## Поведение

- Минимальная ширина / максимальная ширина
- Что при длинном тексте: перенос или усечение
- Что при отсутствии слота
- Тач-таргет ≥44×44pt даже при `Size: sm`

## Адаптив

| Брейкпоинт | Поведение |
|---|---|

## Доступность

- Роль: `<button / link / ...>`
- Доступное имя: из `label`; при отсутствии текста обязателен `spec:label`
- Порядок фокуса: <правило>
- Контраст: проверен во всех режимах

## Чеклист промоушена в библиотеку

- [ ] Используется на ≥2 экранах
- [ ] Все значения на variables
- [ ] Все состояния собраны, включая `focused` и `disabled`
- [ ] Properties названы по `core/naming.spec.md`
- [ ] Контраст проверен во всех режимах
- [ ] Описание «когда применять / когда нет» заполнено
- [ ] Число комбинаций ≤40
- [ ] Внесён в changelog (`workflows/versioning.spec.md`)
