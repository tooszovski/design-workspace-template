# Design Workspace Template

Шаблон workspace для дизайнера, работающего в Figma в паре с Claude Code.

Даёт агентную обвязку вокруг дизайн-процесса: правила дизайн-системы как исполняемые спеки, аудит макета по этим правилам, генерацию handoff-спек для разработки, экспорт токенов и сверку реализации с макетом.

**iOS-специфики нет.** Шаблон платформо-независим: платформы задаются при первом запуске.

## Что внутри

```
.
├── CLAUDE.md                       — bootstrap, entry point для Claude Code
├── README.md                       — этот файл
├── .gitignore                      — что не коммитить
├── .mcp.json.example               — конфиг Figma MCP
├── scripts/
│   ├── setup-tools.sh              — проверка окружения: Claude Code, node, Figma MCP
│   ├── init.sh                     — shell-wizard настройки (альтернатива /design.init)
│   └── validate-specs.sh           — валидация frontmatter, cross-refs, placeholder'ов
├── .claude/
│   ├── commands/                   — /design.init · audit · handoff · tokens · drift · critique
│   ├── agents/                     — design-lead · figma-analyst · handoff-author + 3 ревьюера
│   ├── hooks/git-push-guard.sh     — запрет пуша в защищённые ветки
│   ├── skills/                     — локальные скиллы (пусто по умолчанию)
│   ├── settings.json               — хуки, коммитится
│   └── settings.local.json.example — allow-list, снимает permission prompts
├── specs/                          — SDD spec-структура (33 спеки + шаблоны)
│   ├── INDEX.md                    — карта спек с триггерами
│   ├── LOADER.md                   — контракт on-demand подгрузки, schema v2
│   ├── core/       (7)             — always loaded
│   ├── domain/     (13)            — on-demand по триггерам
│   ├── workflows/  (13)            — по режиму задачи
│   ├── per-epic/                   — шаблон эпика
│   └── per-task/                   — шаблоны задачи, компонента, DDR
└── bootstrap/
    ├── REQUIREMENTS.md             — матрица зависимостей
    └── examples/                   — сквозной пример заполнения артефактов
```

## Быстрый старт

```bash
cp -r design-workspace ~/git/my-product-design
cd ~/git/my-product-design
git init

./scripts/setup-tools.sh     # окружение: Claude Code, node, Figma MCP
claude                       # затем: /design.init
```

`/design.init` проведёт интервью, проставит значения во все файлы, удалит отключённые модули и вычистит `INDEX.md`. Без Claude Code — `./scripts/init.sh`.

Проверка результата:

```bash
./scripts/validate-specs.sh
```

## Как это работает

### Спеки вместо промптов

Правила дизайна живут в `specs/` как машиночитаемые документы с frontmatter. Агент не получает их все сразу: лоадер собирает bundle под конкретную задачу по триггерам (`specs/LOADER.md`).

- `core/` — грузятся всегда: Constitution, дизайн-система, нейминг, git
- `domain/` — по ключевым словам задачи: цвет, типографика, состояния, доступность…
- `workflows/` — по режиму задачи: Quick / Standard / Full

Это держит контекст агента маленьким и убирает расхождение трактовок между сессиями.

### Три режима задачи

| Mode | Когда | Что происходит |
|---|---|---|
| Quick | 1–2 фрейма, правка без новых состояний | один проход, аудит, сдача |
| Standard | новый экран или поток | clarify → структура → состояния → критика → handoff |
| Full | раздел, изменение ДС, новый паттерн | + эпик, DDR, параллельные ревьюеры, чекпойнты |

### States-контракт

Аналог TDD в дизайне. Состояния экрана собираются **до** полировки: сначала матрица покрытия, потом фреймы, потом сверка. Это единственный найденный способ не терять `empty` и `error` к дедлайну.

### Claude read-only в Figma

Агент читает макеты через MCP, но не пишет в них. Изменения оформляются как инструкция человеку. Причина: молчаливая правка чужого файла необратима и незаметна.

## Команды

| Команда | Что делает |
|---|---|
| `/design.init` | первичная настройка: интервью и проставление значений |
| `/design.audit` | 15 проверок фрейма: detached, хардкод, spacing, состояния, контраст, нейминг |
| `/design.handoff` | из фрейма → самодостаточная спека для разработки |
| `/design.tokens` | Figma variables → DTCG JSON → платформенный экспорт |
| `/design.drift` | сверка реализации с макетом, `DESIGN_DRIFT` findings |
| `/design.critique` | дизайн-критика: задача, иерархия, полнота, реализуемость |

## Placeholders

Проставляются при `/design.init` или `./scripts/init.sh`.

| Токен | Что это | Пример |
|---|---|---|
| `<PROJECT_NAME>` | название проекта, CamelCase | `AcmeShop` |
| `<ORG_NAME>` | организация или продукт | `Acme` |
| `<PROJECT_PREFIX>` | префикс задач в трекере | `ACM` |
| `<DEV_LANGUAGE>` | язык интерфейса продукта | `ru` |
| `<FIGMA_DS_FILE_KEY>` | file key файла дизайн-системы | `aBc123XyZ` |
| `<FIGMA_PRODUCT_FILE_KEY>` | file key продуктового файла | `dEf456UvW` |
| `<DS_LIBRARY_NAME>` | название библиотеки | `Acme DS` |
| `<PLATFORMS>` | платформы продукта | `Web, iOS, Android` |
| `<SPACING_BASE>` | база spacing-шкалы | `4` |
| `<SPACING_SCALE>` | сама шкала | `4, 8, 12, 16, 24, 32, 48, 64` |
| `<WCAG_LEVEL>` | уровень доступности | `AA` |
| `<CODE_REPO_PATH>` | репозиторий реализации, опционально | `~/git/acme-web` |
| `<TOKENS_EXPORT_PATH>` | куда класть токены | `~/git/acme-web/tokens` |
| `<TASK_SPEC_SOURCE_PATH>` | где живут ТЗ | vault `Projects/Acme/ТЗ` |
| `<PER_TASK_SPEC_LOCATION>` | спеки задач, worklog | vault `Projects/Acme/Tasks` |
| `<AGENT_LOGS_LOCATION>` | кросс-задачный журнал | vault `Projects/Acme/Agent Logs` |
| `<TRACKER_NAME>` | трекер задач | `Jira` |
| `<TRACKER_TESTING_STATUS>` | статус «на проверке» | `Testing` |
| `<TRACKER_BLOCKED_STATUS>` | статус «заблокировано» | `Blocked` |
| `<GIT_USER_NAME>` / `<GIT_USER_EMAIL>` | автор коммитов | — |
| `<COMMIT_LANGUAGE>` | язык сообщений коммитов | `Russian` |
| `<INTEGRATION_BRANCH>` / `<RELEASE_BRANCH>` | ветки | `develop` / `main` |
| `<REFERENCE_PLATFORM>` | референс-платформа, опционально | `Android` |

## Хранилище артефактов

Два варианта, выбираются при init:

**Obsidian vault + symlink** (по умолчанию, если vault найден). `specs/` переезжает в `Projects/<PROJECT_NAME>/Specs/`, в репозитории остаётся symlink. Спеки доступны из Obsidian и попадают в дистилляцию знаний; в git не дублируются. Задачи живут в `Projects/<PROJECT_NAME>/Tasks/<task-id>/`.

**Только репозиторий.** `specs/` и `tasks/` лежат в workspace, Obsidian не используется. Раздел про onto-агента в `core/vault-contract.spec.md` при этом неактуален.

## Что заполнить руками после init

Эти места требуют проектного знания, wizard их не угадает:

| Файл | Что |
|---|---|
| `specs/domain/layout.spec.md` | таблица брейкпоинтов под выбранные платформы |
| `specs/domain/ux-writing.spec.md` | словарь терминов продукта |
| `specs/domain/color.spec.md` | реальные семантические роли, если они отличаются от базовых |
| `specs/core/project.spec.md §1` | сверить Constitution D-01..D-14 под проект |
| `specs/core/project.spec.md §1.1` | зафиксировать исключения, если они есть |
| `.mcp.json` | токен Figma |

## Зависимости

Обязательные: Claude Code, node 18+, git. Опциональные: `npx style-dictionary` для трансформации токенов, `npx svgo` для оптимизации SVG.

Подробности и fallback'и — `bootstrap/REQUIREMENTS.md`.

## Развитие шаблона

Раздел «Что стоит поправить в спеках» в `agent-log.md` каждой задачи — источник изменений. Ошибка, повторившаяся дважды, идёт в `specs/workflows/anti-patterns.spec.md`. Правило, которого не хватило, — в соответствующую domain-спеку.

После любой правки frontmatter:

```bash
./scripts/validate-specs.sh
```
