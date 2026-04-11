# obsidian-brain — Project Memory Index

> **Cold-start entry point.** Читай этот файл первым после `CLAUDE.md` в любой новой сессии.
> Дальше — лениво по ссылкам из таблицы ниже. Не подгружай всё подряд.

## Состояние проекта

- **Версия:** 2.0.0-alpha.1 (pre-release)
- **Активный план:** *none* (нет текущей крупной работы)
- **Последнее обновление спеки:** 2026-04-11
- **Последний ADR:** ADR-0006 — language-split

## Quick Links

| Артефакт | Файл | Когда читать |
|---|---|---|
| 🏛 Архитектура (live) | [`specs/current.md`](specs/current.md) | При первом вопросе о коде/дизайне/скиллах |
| 📋 Текущий план | `plans/current.md` *(отсутствует)* | Если ведётся крупная работа |
| 📜 Decisions (индекс) | [`decisions/README.md`](decisions/README.md) | Перед тем как менять обоснованный выбор |
| 🐛 Known issues | [`known-issues.md`](known-issues.md) | При странных ошибках, **всегда** на Windows |
| 🗄 Архивные специ | `specs/archive/` *(local)* | Только по явной просьбе пользователя |
| 🗄 Архивные планы | `plans/archive/` *(local)* | Только по явной просьбе пользователя |

## Карта ADR

| ID | Title | Status |
|---|---|---|
| [ADR-0001](decisions/0001-trust-levels-three-tiers.md) | Trust levels: три уровня (cautious/balanced/auto) | accepted |
| [ADR-0002](decisions/0002-subagents-readonly-on-vault.md) | Субагенты read-only на vault | accepted |
| [ADR-0003](decisions/0003-temp-files-inside-vault.md) | `_temp/` внутри vault, не в OS temp | accepted |
| [ADR-0004](decisions/0004-skill-file-format.md) | Скиллы как `skills/<name>/SKILL.md` | accepted |
| [ADR-0005](decisions/0005-claude-md-gitignored.md) | `CLAUDE.md` — локальная шпаргалка (gitignored) | accepted |
| [ADR-0006](decisions/0006-language-split.md) | Русский UX, английские теги/код/коммиты | accepted |

Полная таблица со статусами и ссылками — в [`decisions/README.md`](decisions/README.md).

## Known issues (тизер)

- **WIN-001** — obsidian CLI exit 127 на write-командах (нужен wrapper на Windows)
- **WIN-002** — pre-flight check версии Obsidian CLI

Полный каталог — в [`known-issues.md`](known-issues.md).

## Структурные правила

- **Константные имена:** `current.md` — всегда актуальная версия. При смене архитектуры старое уезжает в `archive/<YYYY-MM-DD>-<topic>.md`. Claude никогда не разбирает даты, чтобы найти «текущее».
- **ADR append-only:** новые решения добавляются как `NNNN+1-slug.md`. Старые не удаляются — при отмене проставляется `Status: superseded by ADR-NNNN`.
- **Git-статус:** `_INDEX.md`, `decisions/`, `known-issues.md` — коммитятся (долговременные активы). `specs/`, `plans/` — локальные (рабочие заметки).
- **Stop-hook:** `.claude/hooks/check-docs-drift.sh` проверяет mtime `specs/current.md` против `skills/|agents/|references/`. Если что-то новее — печатает напоминание. Молчит при отсутствии drift.

## Cold-start protocol

Рекомендуемый порядок чтения при запуске новой сессии:

1. `CLAUDE.md` — загружается автоматически Claude Code
2. **`docs/_INDEX.md`** (этот файл) — прочитать вручную, один файл
3. Дальше — только то, что нужно для текущего запроса:
   - Вопрос про архитектуру? → `specs/current.md`
   - Вопрос «почему именно так?» → соответствующий ADR из `decisions/`
   - Странная ошибка? → `known-issues.md`
   - Конкретный скилл? → `skills/<name>/SKILL.md`

**Не читай** `archive/*` без явной просьбы — это исторический контекст, не помогает текущей работе.
