# ADR-0004: Скиллы как `skills/<name>/SKILL.md`

- **Status:** accepted
- **Date:** 2026-04-11 *(ratified; формат использовался с v1.0.0)*
- **Scope:** все 7 скиллов плагина

## Context

Claude Code плагины поддерживают несколько способов упаковки скиллов. При создании obsidian-brain v1.0.0 нужно было выбрать формат для 7 скиллов (`audit`, `cluster`, `decompose`, `dedup`, `improve`, `process-inbox`, `rename-tags`).

Требования:
- Скилл должен быть автоматически дискаверабл плагин-системой Claude Code
- YAML frontmatter с `name` и `description` для автоматического триггера по ключевым фразам
- Возможность в будущем добавить дополнительные файлы к скиллу (промпты, шаблоны, examples) без миграции структуры
- Совместимость с конвенциями других плагинов из `claude-plugins-official`

## Decision

**Каждый скилл — директория `skills/<name>/SKILL.md`** с YAML-frontmatter.

Структура:
```
skills/
├── audit/SKILL.md
├── cluster/SKILL.md
├── decompose/SKILL.md
├── dedup/SKILL.md
├── improve/SKILL.md
├── process-inbox/SKILL.md
└── rename-tags/SKILL.md
```

YAML-frontmatter каждого `SKILL.md`:
```yaml
---
name: <skill-name>
description: <триггерное описание с ключевыми фразами "use when user asks to...">
---
```

Это стандартный формат Claude Code плагинов — плагин-система автоматически подхватывает все `skills/*/SKILL.md` при загрузке плагина. Имя файла должно быть именно `SKILL.md` (не `index.md`, не `skill.md`).

## Alternatives considered

1. **Плоский `skills/<name>.md`.** Отвергнуто: не оставляет места для будущих сопутствующих файлов (example inputs, шаблоны, доп. промпты, скриншоты). При масштабировании пришлось бы мигрировать все ссылки в проекте.
2. **Монолитный `skills.md` с секциями.** Отвергнуто: плагин-система Claude Code не поддерживает такой формат — каждый скилл должен быть отдельной дискаверабл единицей с собственным frontmatter для триггера по description.
3. **`skills/<name>/index.md`.** Отвергнуто: `SKILL.md` — соглашение Claude Code. Изменение имени ломает автоматический discovery и делает плагин несовместимым с другими tools экосистемы.
4. **Имя файла совпадает с именем папки: `skills/audit/audit.md`.** Отвергнуто: избыточно, не соответствует конвенции.

## Consequences

**Плюсы:**
- **Zero config** — плагин-система подхватывает всё автоматически при установке
- **Место для роста:** в `skills/audit/` можно положить `examples/`, `templates/`, вспомогательные промпты, не трогая `SKILL.md`
- **Единообразие** с другими плагинами из `claude-plugins-official` — пользователи, знакомые с одним плагином, не удивляются структуре
- Git-diff читаемый: при правке скилла видно только изменения в `SKILL.md`, без шума от других файлов

**Минусы:**
- Один файл в директории = **7 лишних директорий** на диске вместо 7 файлов. Мелкое неудобство при `ls skills`.
- `find skills -name "*.md"` находит всё (хорошо для поиска), но `ls skills/` показывает только папки (нужно помнить, что внутри каждой — `SKILL.md`).

## Links

- Примеры: [`skills/audit/SKILL.md`](../../skills/audit/SKILL.md), [`skills/dedup/SKILL.md`](../../skills/dedup/SKILL.md)
- Родительский плагинный `CLAUDE.md`: `../CLAUDE.md` (локальный) — описание структуры плагина в `my_plugins/`
