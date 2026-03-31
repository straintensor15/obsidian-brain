---
name: process-inbox
description: Process raw notes from Obsidian vault _inbox/ folder — standardize frontmatter, rename, tag, link, and move to correct folder. Use when user asks to process inbox, handle raw notes, or says /process-inbox.
---

# Process Inbox

Process raw/temporary notes in `_inbox/` with parallel analysis and trust-level-driven apply.

## Setup

1. Read `references/vault-config.md` from this plugin directory for vault path and folder rules.
2. Read `references/frontmatter-spec.md` for frontmatter templates and field rules.
3. Read `references/cli-operations.md` for CLI commands reference.
4. Read `references/interaction-patterns.md` for interaction and safety rules.
5. Read `references/trust-levels.md` for trust level definitions and constraints.
6. Read `references/temp-file-spec.md` for JSON report format.

## Process

### 1. Scan Inbox

```bash
obsidian files path="_inbox/"
```

If empty — report «_inbox/ пуст, нечего обрабатывать» and stop.

Count files. If >40, inform user that first 40 will be processed, rest in next iteration.

### 2. Phase 1: Parallel Analysis (subagents)

Generate timestamp: `ts=$(date +%Y-%m-%dT%H-%M)`

Split inbox files into batches of 10. Dispatch up to 4 subagents with `subagent_type: "vault-worker"`:

> **Scope override:** Process-inbox overrides vault-worker's default excluded areas — `_inbox/` IS the scan target. Subagents also search `notes/`, `literature/`, `projects/` for related notes.

Prompt per batch:

```
Vault path: {vault_path}
Task: Analyze inbox notes for processing. Scope override: scan _inbox/ (not default scan area).

For each file in this batch:
{file_list}

Do the following:

1. Read the file: `obsidian read file="filename"`

2. Determine:
   - type: note (atomic concept), literature (course/book summary), project (project-related)
   - tags: hierarchical, ALWAYS in English (ml/metrics, dev/python, finance/bonds)
   - status: draft (default for new notes)
   - created: from file content, git history, or today's date
   - proposed filename: Russian by default (Обработка пропусков.md), English for untranslatable concepts (One-hot encoding.md). No date prefixes.

3. Search for related notes:
   `obsidian search query="keyword1" limit=10` (use 2-3 key terms from note content)

4. Check name conflicts:
   `obsidian search query="proposed_filename" limit=5`

5. If you are NOT confident about type or tags (ambiguous content, multiple possible categorizations), set unclear=true with explanation.

Report per file using inbox-specific JSON format (see temp-file-spec.md).
Category: inbox_analysis
Confidence: 0.0-1.0 based on how certain you are about type/tags/name.

Write JSON report to: {vault_path}/_temp/inbox-analysis-batch{N}-{ts}.json
```

### 3. Merge Analyses

After all subagents complete:

1. Read all batch JSON files.
2. Separate files into:
  - **Clear:** confidence >= 0.7, unclear=false
  - **Unclear:** unclear=true or confidence < 0.7
3. Group clear files by proposed type (notes/, literature/, projects/).

### 4. Handle Unclear Files

If any unclear files exist, present them to the user first:

```
Не удалось уверенно классифицировать:

1. _inbox/some note.md
   Предположение: type=note, tags=[ml/misc]
   Причина неуверенности: контент затрагивает несколько тем

   Ваш вариант? (тип / теги / пропустить)
```

After user resolves unclear files, merge them into clear list.

### 5. Present Full Plan

```
## План обработки inbox

| # | Файл | → Имя | Папка | Теги | Related |
|---|------|-------|-------|------|---------|
| 1 | ML attention.md | Механизм внимания.md | notes/ | ml/transformers | 2 заметки |
| 2 | ... | ... | ... | ... | ... |

Всего: N файлов (X → notes/, Y → literature/, Z → projects/)
```

### 6. Ask Trust Level

Per `references/trust-levels.md` (default: `balanced`).

### 7. Apply

Per trust level:

**cautious:** For each file, show detailed plan and wait for confirmation.

**balanced:** Group by type:

```
Группа: notes/ (12 файлов)
[Применить все 12] [Показать список] [Пропустить]

Группа: literature/ (5 файлов)
[Применить все 5] [Показать список] [Пропустить]
```

**auto:** Apply all clear files. Show report.

> Constraint: `obsidian move` requires minimum `balanced`. In `auto` mode, moves still execute but show summary before proceeding.

For each approved file:

```bash
# Set frontmatter
obsidian property:set file="filename" name="type" value="note"
obsidian property:set file="filename" name="tags" value="topic/subtopic"
obsidian property:set file="filename" name="status" value="active"
obsidian property:set file="filename" name="created" value="YYYY-MM-DD"

# Add See also
obsidian append file="filename" content="\n## See also\n- [[Related Note 1]]\n- [[Related Note 2]]"

# For inline wikilinks: use Read + Edit

# Move to target folder (LAST — updates wikilinks vault-wide)
obsidian move file="filename" to="notes/"
```

### 8. Cleanup + Report

1. Cleanup temp files.
2. Report per interaction-patterns.
3. Daily log.
4. Commit per interaction-patterns convention.

## Important

- NEVER delete content from user's notes — only add structure
- Always preserve the original text
- If a note is ambiguous, ask the user
- Respond in Russian
