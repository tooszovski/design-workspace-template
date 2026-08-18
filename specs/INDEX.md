---
name: index
purpose: Карта всех spec-файлов с триггерами подгрузки для лоадера
schema_version: 2
---

# Specs Index

**Структура:**

- `core/*` — всегда загружены (7 файлов) + любая спека с `always_loaded: true`
- `domain/*` — on-demand по триггерам (`task_keywords` / `task_attachments` / `paths` / free-form `triggers`)
- `workflows/*` — по `loaded_for_modes` (Quick / Standard / Full); часть всегда

**Контракт лоадера и схема frontmatter (v2):** `LOADER.md`.

## Core (always loaded — 7 файлов)

| Name | Path | Purpose |
|---|---|---|
| project | core/project.spec.md | Constitution D-01..D-14, DoD, источники правды, три уровня SDD |
| workspace | core/workspace.spec.md | Layout, границы зон, Figma как внешний source of truth |
| vault-contract | core/vault-contract.spec.md | Obsidian: symlink specs, Tasks/, запретные зоны, worklog как сигнал |
| design-system | core/design-system.spec.md | Иерархия ДС, канон, потребление и изменение библиотеки |
| naming | core/naming.spec.md | Нейминг страниц, фреймов, слоёв, компонентов, variables, экспорта |
| git-policy | core/git-policy.spec.md | Что не коммитить, ветки, rebase, пуш |
| commits | core/commits.spec.md | Conventional Commits, scopes, автор, язык |

## Domain (on-demand — 13 файлов)

| Name | Path | Триггеры |
|---|---|---|
| figma-structure | domain/figma-structure.spec.md | keywords: figma, файл, структура, страница, секция, cover |
| components | domain/components.spec.md | keywords: компонент, variant, инстанс, библиотека, detach, слот |
| variables | domain/variables.spec.md | keywords: variable, переменная, токен, тема, dark mode, режим, алиас |
| color | domain/color.spec.md | keywords: цвет, палитра, контраст, тёмная тема, градиент, прозрачность |
| typography | domain/typography.spec.md | keywords: шрифт, типографика, текст, text style, заголовок, кегль |
| layout | domain/layout.spec.md | keywords: layout, раскладка, auto-layout, сетка, отступ, брейкпоинт, адаптив |
| states | domain/states.spec.md | keywords: состояние, empty, loading, error, скелетон · **по умолчанию для экранных задач** |
| accessibility | domain/accessibility.spec.md | keywords: доступность, a11y, wcag, контраст, фокус, screen reader · **по умолчанию для экранных задач** |
| prototyping | domain/prototyping.spec.md | keywords: прототип, анимация, переход, моушен, интерактив |
| ux-writing | domain/ux-writing.spec.md | keywords: текст, копирайт, microcopy, формулировка, tone of voice, терминология |
| tokens-export | domain/tokens-export.spec.md | paths: exports/tokens/**, `<TOKENS_EXPORT_PATH>` · keywords: токены, экспорт, style dictionary |
| handoff | domain/handoff.spec.md | keywords: handoff, передача, спека для разработки, реализация, аннотация |
| assets | domain/assets.spec.md | paths: exports/assets/** · keywords: иконка, иллюстрация, изображение, svg, лого |

**Проектные domain-спеки** (добавлять по необходимости): специфика отрасли, регуляторные требования к интерфейсу, брендбук, e-mail-шаблоны, печатные материалы, дата-виз.

## Workflows (по режиму — 13 файлов)

| Name | Path | Загружается для |
|---|---|---|
| task-modes | workflows/task-modes.spec.md | **always_loaded** — нужен для классификации |
| design-workflow | workflows/design-workflow.spec.md | quick, standard, full — шаги 0-10 |
| review-pipeline | workflows/review-pipeline.spec.md | quick, standard, full — кто ревьюит и когда |
| decision-gates | workflows/decision-gates.spec.md | quick, standard, full — Tier 1 / Tier 2 |
| anti-patterns | workflows/anti-patterns.spec.md | quick, standard, full |
| clarify | workflows/clarify.spec.md | standard, full — пакет вопросов, drift-guard |
| critique | workflows/critique.spec.md | standard, full — дизайн-критика |
| handoff-quality | workflows/handoff-quality.spec.md | standard, full — гейты G1-G6 |
| drift-check | workflows/drift-check.spec.md | standard, full (+ trigger: приёмка реализации) |
| team-dispatch | workflows/team-dispatch.spec.md | standard, full — состав команды, lean return |
| agent-log | workflows/agent-log.spec.md | standard, full — worklog и финальный отчёт |
| checkpoint | workflows/checkpoint.spec.md | full (+ trigger: оценка >2ч) |
| versioning | workflows/versioning.spec.md | full (+ trigger: задача трогает ДС) |

## Per-epic (SDD level 2)

| Path | Purpose |
|---|---|
| per-epic/EPIC-TEMPLATE.md | Чартер раздела: карта потока, декомпозиция, общие решения и компоненты, сквозные требования |
| per-epic/README.md | Когда заводить эпик, где живут реальные |

## Per-task (SDD level 3 + Quick + компонент + DDR)

| Path | Purpose |
|---|---|
| per-task/DESIGN-TASK-TEMPLATE.spec.md | Pre-spec: задача, требования, AC, матрица состояний, guardrails, DoR |
| per-task/QUICK-TEMPLATE.spec.md | Тонкая спека для Quick |
| per-task/COMPONENT-TEMPLATE.md | Спецификация компонента ДС: API, анатомия, состояния, чеклист промоушена |
| per-task/DDR-TEMPLATE.md | Design Decision Record |
| per-task/README.md | Какой шаблон когда брать |

## Examples

Сквозной пример заполнения на мок-задаче — `bootstrap/examples/`.

| Path | Уровень |
|---|---|
| bootstrap/examples/README.md | карта примера |
| bootstrap/examples/epic-example.md | эпик |
| bootstrap/examples/design-task-example.md | pre-spec задачи |
| bootstrap/examples/ddr-example.md | DDR |
| bootstrap/examples/critique-example.md | findings ревью |
| bootstrap/examples/handoff-example.md | спека для разработки |
| bootstrap/examples/worklog-example.md | append-only лог |
| bootstrap/examples/agent-log-example.md | финальный отчёт |

## Коды findings (сводка)

| Код | Источник |
|---|---|
| `DS_VIOLATION` | domain/components, variables, color, design-system |
| `A11Y`, `A11Y_CONTRAST` | domain/accessibility, color |
| `STATE_MISSING`, `STATE` | domain/states |
| `LAYOUT` | domain/layout |
| `TYPO` | domain/typography |
| `COPY` | domain/ux-writing |
| `MOTION` | domain/prototyping |
| `ASSET` | domain/assets |
| `NAMING` | core/naming |
| `STRUCTURE` | domain/figma-structure |
| `HANDOFF` | domain/handoff |
| `DESIGN_DRIFT`, `TOKEN_DRIFT` | workflows/drift-check, domain/tokens-export |
| `CRITIQUE` | workflows/critique |
