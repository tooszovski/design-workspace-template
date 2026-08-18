---
name: loader
purpose: Контракт on-demand подгрузки спек оркестратором и агентами + schema frontmatter
schema_version: 2
---

# Loader Contract

**Цель:** уменьшить контекст-бюджет агентов и убрать расхождение трактовок одного и того же ТЗ.

## Bootstrap

Все агенты этого workspace читают:

1. `CLAUDE.md` — slim bootstrap, указывает на INDEX и LOADER.
2. `specs/INDEX.md` — карта триггеров.
3. Все `specs/core/*.spec.md` — **always loaded**.
4. Все `specs/**/*.spec.md` с `always_loaded: true` — независимо от слоя.

## Frontmatter schema (schema_version: 2)

### Required (`core/`, `domain/`, `workflows/`)

Шаблоны в `per-task/` и `per-epic/` следуют отдельной схеме — у них вместо `layer` есть `kind: template`.

| Поле | Тип | Значения |
|---|---|---|
| `name` | string | уникальный kebab-case slug |
| `layer` | string | `core` / `domain` / `workflow` |
| `purpose` | string | одна строка: что и зачем |
| `owner` | string | `design-lead` / `figma-analyst` / `handoff-author` / `reviewer-designsystem` / `reviewer-a11y` / `reviewer-ux-copy` |

### Conditional

| Поле | Когда обязательно | Значения |
|---|---|---|
| `always_loaded` | `core/*` и любая спека, что грузится всегда | `true` |
| `applies_to` | `domain/*` и `workflows/*` | object — см. ниже |

### `applies_to` sub-fields

| Sub-field | Тип | Назначение | Правило матчинга |
|---|---|---|---|
| `task_keywords` | `[string]` | слова из ТЗ, названия задачи, описания | case-insensitive substring в `task.title + task.description` |
| `paths` | `[string]` (glob) | пути в scope — для спек, работающих с файлами (`code/`, `exports/`) | любой `scope.paths[i]` матчит любой `applies_to.paths[j]` |
| `loaded_for_modes` | `[string]` | только для `layer: workflow` — автозагрузка по режиму | режим в списке |
| `task_attachments` | `[string]` | `figma_link` / `screenshot` / `reference` / `recording` | любое вложение совпало |
| `triggers` | `[string]` | free-form описание для LLM-оркестратора, fallback | суждение оркестратора, с логированием причины |

### Правила схемы

- `task_keywords` — **нижний регистр**, естественный язык. Русский и английский смешиваются: ТЗ приходит на `<DEV_LANGUAGE>`, термины дизайна — на английском.
- `paths` — глобы. В дизайн-workspace они применимы только к `code/**`, `exports/**` и `<TOKENS_EXPORT_PATH>`; для макетов путей нет, их роль играют `task_keywords` и `task_attachments`.
- **Неизвестные поля игнорируются** лоадером, но являются smell — фиксить при ревью.

### Forbidden fields

| Поле | Почему | Заменить на |
|---|---|---|
| `symbols` | наследие кодового шаблона, в дизайне нет символов | `task_keywords` |
| `always_for_orchestrator` | дублирует `always_loaded` | `always_loaded: true` |
| `triggers_on_task_attachments` | переименовано | `task_attachments` |

## Per-task bundle

> **SDD три уровня** (`core/project.spec.md §4`):
> - **PROJECT** — `core/*` (always loaded)
> - **EPIC** — `<PER_TASK_SPEC_LOCATION>/<epic-id>/epic.md`, прикладывается при `task.epic_ref`
> - **TASK** — `<PER_TASK_SPEC_LOCATION>/<task-id>/spec.md`
>
> DDR прикладывается, если pre-spec ссылается на конкретные DDR-ID.

Вход: `spec.md` задачи (задача, scope, `task_keywords`, `mode`, `attachments`).

Алгоритм:

1. **Always-loaded:** все `**/*.spec.md` с `always_loaded: true`.
2. **Mode-based workflows:** все `workflows/*.spec.md`, где `applies_to.loaded_for_modes` содержит текущий режим.
3. **Trigger-based workflows:**
   - `versioning` — если задача трогает `<DS_LIBRARY_NAME>`
   - `checkpoint` — если `mode: full` или оценка >2ч
   - `drift-check` — если задача про приёмку реализации
   - `clarify` — Standard/Full до старта работы
4. **Domain по keyword:** `domain/*.spec.md`, у которых `applies_to.task_keywords` пересекается с ключевыми словами задачи.
5. **Domain по attachment:** спеки с `applies_to.task_attachments`, совпавшим с `task.attachments`.
6. **Domain по path:** только для задач, затрагивающих `code/**` или `exports/**`.
7. **Domain по умолчанию для любой экранной задачи:** `states`, `accessibility`, `layout` — они применимы почти всегда; не грузятся только для задач чисто по токенам или ассетам.
8. **Free-form fallback:** если ничего не сработало, но оркестратор считает `applies_to.triggers` релевантным — включить и залогировать причину.
9. Дедуплицировать, передать агенту.

## Subagent input contract

```
<spec-bundle>
core: [project, workspace, vault-contract, design-system, naming, git-policy, commits]
workflows: [task-modes, design-workflow, review-pipeline, ...]
domain: [states, accessibility, layout, ...]
task: <PER_TASK_SPEC_LOCATION>/<task-id>/spec.md
figma: <file-key> · <node-id> · <путь к кэшу>
scope: <фреймы задачи>
</spec-bundle>
```

Агент **не** получает спеки вне bundle. Если по ходу нужна ещё одна — сигнализирует `REROUTE` с `SpecsMissing`; решение принимает оркестратор.

## Subagent output contract (lean return) — canonical

Единый формат для всех агентов этого workspace:

```
Signal: COMPLETE | FAIL | REROUTE
Checkpoint: <путь к файлу с деталями>
SpecsUsed: [список загруженных спек]
SpecsMissing: [спеки, которые потребовались, но не были загружены]
```

`SpecsUsed` — для аудита. `SpecsMissing` — обратная связь лоадеру: по ней правятся триггеры в `INDEX.md` и в самих спеках.

## Convention: ссылки между спеками

Ссылка на другую спеку — относительный путь от `specs/`:

- ✅ `см. core/naming.spec.md`
- ❌ `см. раздел «Нейминг»` — без пути не грепается

Проверка целостности: `grep -rE '\.spec\.md' specs/`.

## Validation

```bash
./scripts/validate-specs.sh
```

Проверяет:

- у каждой `.spec.md` есть обязательные поля, `layer` соответствует директории
- нет forbidden fields
- `loaded_for_modes` содержит только `quick` / `standard` / `full`
- шаблоны в `per-task/` и `per-epic/` имеют `kind: template`
- все cross-refs резолвятся в существующие файлы
- в спеках не осталось placeholder'ов `<UPPER_CASE>` (после init)

Запускать после любого изменения frontmatter или добавления/переименования спек.
