---
name: team-dispatch
layer: workflow
purpose: Состав команды агентов, размер, параллельный запуск, lean return
applies_to:
  task_keywords: ["dispatch", "команда", "агенты", "параллельно", "subagent"]
  loaded_for_modes: ["standard", "full"]
owner: design-lead
---

# Team Dispatch

## Роли

| Агент | Когда запускается | Что делает |
|---|---|---|
| `design-lead` | оркестратор, Standard/Full | ведёт задачу, критикует, держит гейты, не рисует сам |
| `figma-analyst` | нужна выгрузка и разбор макета | тянет данные через MCP, готовит структурированный отчёт |
| `handoff-author` | шаг 8 | пишет `handoff.md` |
| `reviewer-designsystem` | ревью | компоненты, токены, нейминг |
| `reviewer-a11y` | ревью | доступность |
| `reviewer-ux-copy` | ревью | тексты |

## Размер команды по режимам

| Mode | Состав |
|---|---|
| Quick | один агент, без оркестратора |
| Standard | `design-lead` + `figma-analyst` + 3 ревьюера + `handoff-author` |
| Full | то же + отдельный проход по ДС и чекпойнты |

Больше агентов ≠ лучше. Каждый лишний агент — это ещё один контекст, который надо согласовать.

## Параллельность

Ревьюеры **всегда** запускаются одним сообщением с несколькими вызовами `Agent`. Они независимы: `reviewer-a11y` не должен ждать `reviewer-ux-copy`.

Последовательно запускается только то, где второй шаг зависит от результата первого: `figma-analyst` → ревьюеры (им нужна выгрузка), ревьюеры → `handoff-author` (спека пишется по финальному макету).

## Что передаётся агенту

```
<spec-bundle>
core: [project, workspace, design-system, naming, ...]
workflows: [task-modes, review-pipeline, ...]
domain: [states, accessibility, ...]
task: <PER_TASK_SPEC_LOCATION>/<task-id>/spec.md
figma: <file-key> · <node-id> · <путь к кэшу выгрузки>
scope: <какие фреймы входят в задачу>
</spec-bundle>
```

Агент не получает спеки вне bundle. Если по ходу нужна ещё одна — возвращает `SpecsMissing`, решение о догрузке принимает оркестратор.

## Lean return

Единый формат возврата **для всех агентов** этого workspace:

```
Signal: COMPLETE | FAIL | REROUTE
Checkpoint: <путь к файлу с деталями>
SpecsUsed: [...]
SpecsMissing: [...]
```

Агент не пересказывает свою работу в ответе — детали лежат в checkpoint-файле. Пересказ раздувает контекст оркестратора ровно тем, что уже записано на диск.

`SpecsMissing` — обратная связь для лоадера: по нему правятся триггеры в `INDEX.md`.

## Ограничения

- Агент не пишет в Figma (D-02).
- Агент не правит спеки в `core/` без явного указания.
- Агент не закрывает задачу в трекере — это делает человек или оркестратор на шаге 9.
- Ревьюер не правит макет: он возвращает findings.

## Cross-refs

- LOADER.md — как собирается bundle
- workflows/review-pipeline.spec.md — порядок ревью
- workflows/agent-log.spec.md — финальный отчёт
