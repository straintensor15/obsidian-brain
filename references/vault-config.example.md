# Vault Configuration

## Path

`/path/to/your/Obsidian/Vault`

> Copy this file to `vault-config.md` and set your vault path and folder structure.

## Folder Structure

| Folder | Purpose |
|--------|---------|
| `_inbox/` | Raw/temporary notes — entry point for processing |
| `notes/` | Atomic notes on any topic. Topic determined by tags. |
| `literature/` | Course/book/article summaries. Decomposed monoliths become MOCs here. |
| `projects/` | Project notes |
| `daily/` | Daily journal |
| `_moc/` | Map of Content navigation files |
| `_templates/` | Obsidian templates |
| `_assets/` | Attachments (images, PDFs, excalidraw) |
| `_archive/` | Inactive/outdated notes |

## File Naming

- Name by core concept, **in Russian by default**: `Семантическое версионирование (SemVer).md`, `Обработка пропусков.md`
- English abbreviations and acronyms stay as-is in the name: `Git`, `ML`, `SemVer`, `PCA`, `RMSLE`
- Purely English concepts that have no natural Russian equivalent keep English name: `One-hot encoding.md`
- No date prefixes (date in `created` frontmatter field)
- MOC files keep numeric prefixes: `000 Home.md`

## Tag Hierarchy

Hierarchical tags with `/`:
- `topic/subtopic`, `topic/subtopic/detail`

**Tags are always in English** to avoid semantic duplicates across languages (e.g. `ML/metrics` not `МЛ/метрики`). Examples:
- `ML/metrics`, `dev/versioning`, `finance/bonds`, `physics/optics`

## Name Conflicts

If target file already exists when moving/creating — ask user: merge, rename with suffix, or skip.
