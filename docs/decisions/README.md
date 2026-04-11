# Architecture Decision Records (ADR)

Реестр архитектурных и проектных решений obsidian-brain. Каждый ADR фиксирует **почему** сделан выбор — код покажет *что*, а этот реестр покажет *зачем*.

## Правила

1. **Append-only.** Старые ADR не удаляются. Если решение отменено — создаётся новый ADR, а у старого проставляется `Status: superseded by ADR-NNNN`.
2. **Один ADR = одно решение.** Не группировать несвязанные выборы в один файл.
3. **Нумерация сквозная:** `NNNN-slug.md`. Следующий свободный номер: **0007**.
4. **Формат файла:** см. [`0001-trust-levels-three-tiers.md`](0001-trust-levels-three-tiers.md) как эталон.

## Шаблон

```markdown
# ADR-NNNN: <title>

- **Status:** proposed | accepted | superseded by ADR-NNNN | deprecated
- **Date:** YYYY-MM-DD
- **Scope:** <где применяется>

## Context
<2–5 предложений: какая проблема, какие ограничения>

## Decision
<что решили>

## Alternatives considered
<2–3 варианта с trade-off, почему отвергнуты>

## Consequences
**Плюсы:** ...
**Минусы:** ...

## Links
<ссылки на код/скиллы/другие ADR>
```

## Когда писать новый ADR

- Необратимый архитектурный выбор (формат данных, границы модуля, модель прав доступа)
- Выбор между несколькими альтернативами с явными trade-off
- Любое решение, которое потом захочется оспорить в чистой сессии без контекста

**Не-ADR:** баги → [`../known-issues.md`](../known-issues.md). Рабочие заметки → [`../specs/current.md`](../specs/current.md) или активный план.

## Индекс

| ID | Date | Title | Status | File |
|---|---|---|---|---|
| 0001 | 2026-04-11 | Trust levels: три уровня (cautious/balanced/auto) | accepted | [0001-trust-levels-three-tiers.md](0001-trust-levels-three-tiers.md) |
| 0002 | 2026-04-11 | Субагенты read-only на vault | accepted | [0002-subagents-readonly-on-vault.md](0002-subagents-readonly-on-vault.md) |
| 0003 | 2026-04-11 | `_temp/` внутри vault, не в OS temp | accepted | [0003-temp-files-inside-vault.md](0003-temp-files-inside-vault.md) |
| 0004 | 2026-04-11 | Скиллы как `skills/<name>/SKILL.md` | accepted | [0004-skill-file-format.md](0004-skill-file-format.md) |
| 0005 | 2026-04-11 | `CLAUDE.md` — gitignored локальная шпаргалка | accepted | [0005-claude-md-gitignored.md](0005-claude-md-gitignored.md) |
| 0006 | 2026-04-11 | Русский UX, английские теги/код/коммиты | accepted | [0006-language-split.md](0006-language-split.md) |

> Даты `2026-04-11` — это дата **внесения** ADR в реестр. Фактические решения были приняты в v1.x–v2.0.0-alpha.1 (см. поле *Date* в каждом ADR для оригинальной даты ratification).
