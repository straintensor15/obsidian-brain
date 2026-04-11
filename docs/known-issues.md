# Known Issues — obsidian-brain

Каталог гоч и платформенных quirks. Формат каждой записи: **Symptom → Cause → Workaround → Status**.

## ID-префиксы

- `WIN-` — Windows-специфика
- `OBS-` — Obsidian CLI (кросс-платформенные проблемы)
- `PLG-` — плагин obsidian-brain (баги в скиллах)
- `SYN-` — YandexDisk / другие sync-сервисы

## Правила

- **Append-only.** Если гоча ушла — меняем статус на `fixed` с версией, но запись не удаляем (история помогает связывать симптом с причиной в будущих похожих случаях).
- **Следующий свободный номер в каждой серии:** см. последнюю запись ниже.
- **Порядок в файле** — хронологический (первый обнаруженный — первый в списке).

---

## WIN-001: obsidian CLI падает с exit 127 на write-командах

- **Symptom:** `obsidian property:set`, `obsidian move`, `obsidian daily:append`, `obsidian append`, `obsidian create`, `obsidian delete`, `obsidian tags:rename` — любая write-команда завершается с `exit 127`. Read-команды (`files`, `read`, `tags`, `search`, `orphans`, `unresolved`, `eval`) при этом работают нормально.
- **Cause:** На Windows в `PATH` по умолчанию резолвится `Obsidian.exe` (GUI launcher) вместо `Obsidian.com` (CLI entry point). GUI-лаунчер не принимает аргументы командной строки, поэтому `obsidian move file=X to=Y` для него — неизвестная команда, он возвращает 127 ("command not found" semantics).
- **Workaround:** Создать wrapper-скрипт `~/bin/obsidian`, который явно вызывает `Obsidian.com`. Детальная инструкция (содержимое wrapper-а, где лежит `Obsidian.com`, как добавить `~/bin` в PATH) — в [`references/cli-operations.md`](../references/cli-operations.md). При настройке на новой Windows-машине это **обязательный первый шаг**.
- **Status:** accepted *(platform quirk — фиксить на стороне Obsidian не в нашей власти)*
- **First seen:** v1.1.0 (2026-03-29)
- **Affected:** только Windows (Git Bash, PowerShell, cmd). Linux/Mac — не затронуты.
- **Escalation hook:** при появлении `exit 127` в любом скилле — первая гипотеза должна быть WIN-001, не баг в скилле.

---

## WIN-002: устаревшая версия Obsidian CLI ломает команды молча

- **Symptom:** Некоторые команды — особенно `obsidian eval`, `obsidian search:context`, `obsidian tags:rename` — падают с непонятными ошибками или возвращают пустой результат / частичный результат, даже когда wrapper настроен правильно и другие команды работают.
- **Cause:** Версия Obsidian CLI устарела. Новые команды и параметры отсутствуют в старых билдах, но вместо понятного error message CLI может вести себя «тихо» — вернуть пустой массив или 0 exit code с пустым stdout. Это маскирует проблему под "нет данных" вместо "неподдерживаемая команда".
- **Workaround:** **Pre-flight check** при первом запуске любого скилла: проверить версию Obsidian CLI против минимальной требуемой (зафиксирована в [`references/cli-operations.md`](../references/cli-operations.md)). Если версия ниже — **остановиться и предупредить** пользователя, предложив обновить Obsidian installer. Это встроено во все скиллы v1.1.0+ как обязательная первая операция.
- **Status:** accepted *(эксплуатационная проверка — встроена в скиллы)*
- **First seen:** v1.1.0 (2026-03-29)
- **Affected:** любая платформа, если CLI не обновлялся после релиза, требующего новых команд
- **Escalation hook:** если `eval` или `search:context` возвращают странные/пустые результаты — сначала проверь версию, потом ищи баг в скилле.

---

<!-- Шаблон для новых записей:

## XXX-NNN: <краткое описание>

- **Symptom:** <что видит пользователь/Claude>
- **Cause:** <почему это происходит>
- **Workaround:** <как обойти>
- **Status:** accepted | fixed in vN.N.N | investigating
- **First seen:** vN.N.N (YYYY-MM-DD)
- **Affected:** <платформы / условия>
- **Escalation hook:** <на что обратить внимание в будущих сессиях, чтобы быстро связать симптом с причиной>

-->
