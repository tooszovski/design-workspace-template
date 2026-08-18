---
name: quick-template
kind: template
purpose: Тонкая спека для Quick-режима — правка 1-2 фреймов без новых компонентов и состояний
owner: design-lead
---

# <PROJECT_PREFIX>-NNN · <Название>

```yaml
task_id: <PROJECT_PREFIX>-NNN
mode: quick
figma_file: <FIGMA_PRODUCT_FILE_KEY>
figma_nodes: [<node-id>]
```

## Что меняем

Одно-два предложения.

## Почему

Одно предложение.

## Границы

Только фреймы: `<перечислить>`. Всё остальное не трогаем.

## Проверка

- [ ] `/design.audit` без CRITICAL
- [ ] Существующие состояния не сломаны
- [ ] Ничего не отцепилось от ДС
- [ ] `worklog.md` закрыт `— DONE: ...`

## Эскалация

Если по ходу выяснилось, что нужен новый компонент, появилось новое состояние, всплыл продуктовый вопрос или правка потянула соседние экраны — **остановиться** и перейти на `DESIGN-TASK-TEMPLATE.spec.md` с mode `standard`. Запись в worklog: `— ESCALATE Quick→Standard, причина: ...`.
