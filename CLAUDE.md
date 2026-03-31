# obsidian-brain — CLAUDE.md

> Управление Obsidian vault через CLI. Версия: **2.0.0-alpha.1** (ветка `feat/subagent-architecture`).
> Общие правила разработки плагинов — см. `../CLAUDE.md`.

## Архитектура v2.0: субагентная модель

### Ключевая идея
Vault 2000+ заметок не помещается в контекст. Решение — **параллельные субагенты** (`vault-worker`), которые сканируют vault read-only и пишут JSON-отчёты в `_temp/`.

### Фазы работы субагентных скиллов
```
scan → merge → present → apply → cleanup
  │       │        │         │        └─ удаление _temp/ файлов
  │       │        │         └─ применение изменений (с подтверждением по trust level)
  │       │        └─ показ сводки пользователю
  │       └─ главный контекст читает JSON-отчёты, объединяет результаты
  └─ vault-worker агенты параллельно сканируют vault, пишут в _temp/
```

### Trust levels
Три уровня гранулярности подтверждений — задаются пользователем при запуске скилла:

| Уровень | Поведение | По умолчанию в |
|---------|-----------|----------------|
| `cautious` | Подтверждение каждого действия | dedup, improve |
| `balanced` | Подтверждение группами | audit, cluster, process-inbox, rename-tags |
| `auto` | Применить всё (с ограничениями) | — |

**Ограничения auto:** `obsidian move` требует >= balanced; merge в dedup требует >= balanced; первый запуск скилла никогда auto.

### Какие скиллы используют субагенты
| Скилл | Субагенты | Последовательный |
|-------|-----------|------------------|
| audit | 3 параллельных vault-worker | — |
| dedup | 3 стадии × N батчей | — |
| cluster | 1 + 3-4 шарда (analyze) / 2 (group) | — |
| process-inbox | до 4 батчей по 10 файлов | — |
| decompose | — | да (одна заметка) |
| improve | — | да (одна заметка) |
| rename-tags | — | да (вся таксономия) |

## Навигация по файлам

### `agents/`
| Файл | Назначение |
|------|-----------|
| `vault-worker.md` | Агент для read-only сканирования vault. Пишет JSON в `_temp/`. Инструменты: Read, Grep, Glob, Bash, Write (только `_temp/`). Сканирует `notes/`, `literature/`, `projects/`, `_moc/` по умолчанию. |

### `skills/`
| Папка | Триггер | Назначение |
|-------|---------|-----------|
| `audit/` | `/audit` | Проверка качества vault (frontmatter, размещение, контент). Quick/full режимы. |
| `cluster/` | `/cluster` | Граф-анализ (хабы, орфаны) + группировка (MOC/summary). Два режима: analyze, group. |
| `decompose/` | `/decompose` | Разбиение большой заметки (>10KB) на атомарные + MOC. |
| `dedup/` | `/dedup` | 3-стадийный поиск дубликатов (имя → теги → контент) + мерж. |
| `improve/` | `/improve` | 6 операций над заметкой: Structure, Format, Tabulate, Rewrite, Summarize, Wikify. |
| `process-inbox/` | `/process-inbox` | Пакетная обработка `_inbox/`: тип, теги, имя, связи, перемещение. |
| `rename-tags/` | `/rename-tags` | Рефакторинг таксономии тегов: синглтоны, дубли регистра, bulk rename. |

### `references/`
| Файл | Назначение |
|------|-----------|
| `vault-config.md` | **Локальный, gitignored.** Путь к vault, структура папок, соглашения по именованию. |
| `vault-config.example.md` | Шаблон для `vault-config.md` — скопировать и заполнить. |
| `frontmatter-spec.md` | Схема YAML-frontmatter по типам заметок (note, literature, project, moc, daily). |
| `cli-operations.md` | Справочник команд Obsidian CLI (read-only и write). Windows-специфика. |
| `interaction-patterns.md` | Конвенции взаимодействия: язык, подтверждения, ошибки, формат отчётов. |
| `trust-levels.md` | Спецификация trust levels: уровни, ограничения, дефолты по скиллам. |
| `temp-file-spec.md` | Схема JSON-отчётов субагентов: именование, поля, расширения по скиллам. |

### `docs/`
| Файл | Назначение |
|------|-----------|
| `specs/2026-03-31-subagent-architecture-design.md` | Дизайн-документ архитектуры v2.0. |
| `plans/2026-03-31-subagent-architecture-plan.md` | План реализации v2.0. |

## Конвенции этого плагина

### Obsidian CLI
- Все операции с vault — через `obsidian` CLI, **не** прямое редактирование файлов
- На Windows: может потребоваться wrapper-скрипт `~/bin/obsidian` (см. `cli-operations.md`)
- Read-only команды: `files`, `read`, `properties`, `tags`, `tag`, `links`, `backlinks`, `unresolved`, `orphans`, `eval`, `search`
- Write команды: `create`, `append`, `prepend`, `move`, `delete`, `property:set`, `property:remove`, `tags:rename`

### vault-config
- `references/vault-config.md` — **обязательный** локальный файл, gitignored
- Содержит путь к vault и структуру папок конкретного пользователя
- Перед первым использованием: скопировать из `vault-config.example.md`

### Temp-файлы (`_temp/`)
- Субагенты пишут JSON-отчёты в `{vault_path}/_temp/`
- Именование: `{skill}-{task}-{timestamp}.json`
- Жизненный цикл: запись субагентом → чтение главным контекстом → удаление после apply
- Папка исключена из vault и git

### Язык
- UX / сообщения пользователю: **русский**
- Теги: **английский**, иерархические (`ml/metrics`, `dev/python`)
- Имена файлов заметок: **русский** по умолчанию, английский для непереводимых терминов
- Код и коммиты: **английский**

### Безопасность
- Никогда не удалять заметки — только `obsidian move` в `_archive/`
- vault-worker: строго read-only (запись только в `_temp/`)
- Подтверждение перед любым изменением (уровень зависит от trust level)
