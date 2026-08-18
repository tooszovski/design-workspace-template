---
name: agent-log
layer: workflow
purpose: Формат финального отчёта агентной сессии и append-only worklog
applies_to:
  task_keywords: ["worklog", "agent-log", "лог", "отчёт", "журнал"]
  loaded_for_modes: ["standard", "full"]
owner: design-lead
---

# Worklog & Agent Log

Два разных файла с разным назначением.

## worklog.md — append-only лог задачи

Пишется **по ходу**, только добавлением. Правка прошлых записей запрещена: лог теряет ценность, если его можно переписать задним числом.

```markdown
# Worklog · <PROJECT_PREFIX>-NNN

### 14:05 — START
Mode: standard. ТЗ: <ссылка>. Версия ДС: 2.3.0.

### 14:20 — CLARIFY
Отправлено 3 вопроса. Работаю по умолчаниям A/A/B.

### 15:10 — AUTO: выбран Card/Product вместо Card/Basic — чаще в продукте

### 16:30 — STATES 4b
Собраны: empty, empty-filtered, loading, error, data. offline — н/п, экран только онлайн.

### 17:00 — DRIFT: ответ на Q2 добавил экран подтверждения, mode standard→full

### 11:15 — REVIEW
3 ревьюера: 1 critical (нет focused у чипсов), 4 important, 2 minor.

### 12:40 — DONE: экран каталога, 5 состояний, handoff готов
```

Обязательные маркеры:

| Маркер | Когда |
|---|---|
| `START` | первая запись |
| `AUTO:` | Tier 1 решение |
| `STOP:` | Tier 2 остановка |
| `ESCALATE` | смена mode |
| `DRIFT:` | изменение scope |
| `REOPENED:` | возврат после DONE |
| `DONE:` | **последняя** запись, триггер дистилляции (`core/vault-contract.spec.md`) |

## agent-log.md — финальный отчёт

Пишется один раз в конце. Отвечает на вопрос «что здесь произошло», не пересказывая worklog.

```markdown
# Agent Log · <PROJECT_PREFIX>-NNN

## Итог
<Что сделано, одним абзацем>

## Артефакты
| Что | Где |
|---|---|
| Макет | Figma <ссылка с node-id> |
| Спека | spec.md |
| Handoff | handoff.md |
| DDR | ddr-001.md |

## Решения
| Решение | Почему | Tier |
|---|---|---|

## Findings
| Severity | Кол-во | Закрыто | Осталось |
|---|---|---|---|
| CRITICAL | 1 | 1 | 0 |
| IMPORTANT | 4 | 3 | 1 |
| MINOR | 2 | 0 | 2 |

## Долг
<Что осталось незакрытым и почему это допустимо>

## Что стоит поправить в спеках
<Места, где правила не дали ответа или дали неверный — вход для улучшения specs/>
```

Последний раздел — главная ценность лога. Задача, которая ничего не сказала о правилах, скорее всего была слишком простой либо агент не заметил трения.

## Куда попадает

Оба файла — в `<PER_TASK_SPEC_LOCATION>/<task-id>/`. Кросс-задачный журнал, если ведётся, — в `<AGENT_LOGS_LOCATION>`.

## Cross-refs

- core/vault-contract.spec.md — DONE как сигнал
- workflows/checkpoint.spec.md — промежуточные чекпойнты
- workflows/team-dispatch.spec.md — lean return
