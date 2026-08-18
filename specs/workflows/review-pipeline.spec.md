---
name: review-pipeline
layer: workflow
purpose: Кто ревьюит, в каком порядке, параллельность, критерий прохождения
applies_to:
  task_keywords: ["review", "ревью", "пайплайн", "проверка", "приёмка"]
  loaded_for_modes: ["quick", "standard", "full"]
owner: design-lead
---

# Review Pipeline

## Порядок

```
/design.audit  →  ревьюеры  →  critique  →  handoff-quality  →  сдача
 (автоматика)     (параллельно)  (смысл)     (гейты G1-G6)
```

Ревьюеры не запускаются, пока `/design.audit` не чист по CRITICAL: они не должны тратить проход на то, что ловится автоматически.

## Пайплайн по режимам

| Mode | Кто |
|---|---|
| **Quick** | только `/design.audit`; `reviewer-designsystem`, если задет компонент ДС |
| **Standard** | параллельно: `reviewer-designsystem` + `reviewer-a11y` + `reviewer-ux-copy` |
| **Full** | то же + `design-lead` делает critique по `workflows/critique.spec.md` + отдельный проход по изменениям ДС (`workflows/versioning.spec.md`) |

Ревьюеры Standard/Full запускаются **одним сообщением** с несколькими вызовами `Agent` — они независимы и не должны ждать друг друга.

## Зоны ответственности

| Ревьюер | Проверяет | Не проверяет |
|---|---|---|
| `reviewer-designsystem` | компоненты, variables, spacing, нейминг, консистентность с ДС | тексты, контраст |
| `reviewer-a11y` | контраст, фокус, тач-таргеты, семантика, аннотации `spec:` | соответствие ДС |
| `reviewer-ux-copy` | тексты, термины, тон, тексты состояний | визуал |
| `design-lead` (critique) | задачу, иерархию, полноту, реализуемость | то, что покрыто выше |

Пересечения зон намеренно минимальны: дублирующие findings от трёх ревьюеров — шум.

## Критерий прохождения

| Severity | Требование |
|---|---|
| CRITICAL | ноль. Каждый закрыт правкой или отменён человеком через Tier 2 |
| IMPORTANT | закрыт или обоснован письменно в worklog |
| MINOR | на усмотрение автора; незакрытые попадают в «долг» в agent-log |

## Reroute

Если ревьюер возвращает работу автору — это reroute. Лимиты:

| Счётчик | Лимит |
|---|---|
| На пару автор↔ревьюер | 3 |
| Всего на задачу | 5 |

При достижении лимита — Tier 2 hard stop: дальше решает человек. Бесконечный цикл правок означает, что проблема в спеке или в постановке, а не в макете.

## Формат возврата ревьюера

```
Signal: COMPLETE | FAIL | REROUTE
Checkpoint: <PER_TASK_SPEC_LOCATION>/<task-id>/critique.md
Findings: <N critical, M important, K minor>
SpecsUsed: [...]
SpecsMissing: [...]
```

## Cross-refs

- workflows/critique.spec.md — содержание критики
- workflows/team-dispatch.spec.md — как запускать
- workflows/decision-gates.spec.md — Tier 2
- workflows/handoff-quality.spec.md — гейты после ревью
