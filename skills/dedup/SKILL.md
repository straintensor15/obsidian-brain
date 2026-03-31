---
name: dedup
description: Find and merge duplicate notes in the Obsidian vault. Use when user asks to deduplicate, merge duplicates, find duplicates, or says /dedup.
---

# Deduplicate Notes

Find duplicate notes using a 3-stage parallel pipeline and merge them interactively.

## Setup

1. Read `references/vault-config.md` from this plugin directory for vault path and folder rules.
2. Read `references/frontmatter-spec.md` for frontmatter templates and field rules.
3. Read `references/cli-operations.md` for CLI commands reference.
4. Read `references/interaction-patterns.md` for interaction and safety rules.
5. Read `references/trust-levels.md` for trust level definitions and constraints.
6. Read `references/temp-file-spec.md` for JSON report format.

## Input

User provides specific files to compare, or nothing. If nothing — run the full 3-stage pipeline.

## Process

Generate timestamp for this run: `ts=$(date +%Y-%m-%dT%H-%M)`

### Stage A: Filename Analysis (parallel by folder)

Dispatch 3 subagents in parallel using `Agent` tool with `subagent_type: "vault-worker"`:

**Subagent A1: notes/**

Prompt:
```

Vault path: {vault_path}
Task: Find potential duplicate notes by filename similarity in notes/.

1. Run `obsidian files path="notes/"` to get file list.
2. Tokenize each filename: split by spaces, hyphens, underscores. Remove tokens <3 chars.
3. Find pairs sharing >= 1 significant token (3+ chars).
4. For each pair, calculate name_similarity (Jaccard index of token sets, 0.0-1.0).
5. Filter: only pairs with name_similarity >= 0.3.

Category: name_duplicate
Severity: high if name_similarity >= 0.7, medium if >= 0.5, low if >= 0.3

Write JSON report to: {vault_path}/_temp/dedup-names-notes-{ts}.json

```

**Subagent A2: literature/** — same prompt, scope `literature/`
**Subagent A3: projects/** — same prompt, scope `projects/`

After all 3 complete: merge candidate pairs from 3 JSON files. Also add cross-folder pairs (if a token appears in files from different folders). Deduplicate pairs.

### Stage B: Tag/Metadata Verification (parallel batches)

Take merged candidates from Stage A. Split into batches of ~50 pairs.

> **CLI concurrency caveat:** Stage B uses `obsidian properties` (CLI). Safe mode: if >50 pairs, use single subagent with internal batching. If <=50, single subagent is sufficient anyway.

Dispatch subagent(s) with `subagent_type: "vault-worker"`:

Prompt per batch:
```

Vault path: {vault_path}
Task: Verify duplicate candidates by comparing tags and metadata.

For each pair in the following list:
{pair_list_json}

1. Run `obsidian properties file="note1"` and `obsidian properties file="note2"`.
2. Compare tags: calculate tag_overlap (Jaccard index of tag sets, 0.0-1.0).
3. Compare type, status, created date.
4. If tags are identical and type matches → high confidence boost.

Update each pair's details with tag_overlap score.
Filter: remove pairs with tag_overlap == 0.0 AND name_similarity < 0.5 (likely false positive).

Write JSON report to: {vault_path}/_temp/dedup-tags-batch{N}-{ts}.json

```

After completion: merge into candidates_AB.

### Stage C: Content Matching (parallel batches)

Take candidates_AB. Split into batches of ~50 pairs.

> Same CLI concurrency caveat as Stage B — uses `obsidian search:context`.

Dispatch subagent(s):

Prompt per batch:
```

Vault path: {vault_path}
Task: Verify duplicate candidates by content similarity.

For each pair in the following list:
{pair_list_json}

1. Read both files: `obsidian read file="note1"`, `obsidian read file="note2"`.
2. Extract 5-10 characteristic phrases (unique multi-word expressions, not generic terms).
3. For each phrase from note1, search in note2's content (direct string matching or `obsidian search:context`).
4. Calculate content_similarity = matched_phrases / total_phrases (0.0-1.0).
5. Calculate final confidence = name_similarity × 0.3 + tag_overlap × 0.2 + content_similarity × 0.5.

Filter: remove pairs with confidence < 0.4.
Rank: High (confidence >= 0.7), Medium (>= 0.5), Low (>= 0.4).

Write JSON report to: {vault_path}/_temp/dedup-content-batch{N}-{ts}.json

```

After completion: merge into final_candidates, sort by confidence descending.

### Present Candidates

Show in Russian with confidence levels:

```

## Найдены потенциальные дубликаты


| #   | Файл 1       | Файл 2                           | Confidence | Сигналы              |
| --- | ------------ | -------------------------------- | ---------- | -------------------- |
| 1   | notes/PCA.md | notes/Метод главных компонент.md | 0.87       | имя + теги + контент |
| 2   | ...          | ...                              | ...        | ...                  |


Всего: N пар (X high, Y medium, Z low)

```

### Ask Trust Level

Per `references/trust-levels.md` (default: `cautious` for dedup).

> Constraint: dedup merge requires minimum `balanced`.

### Interactive Merge

Per trust level:

**cautious (default):** For each pair, show both notes, propose primary, wait for choice.

**balanced:** Group by confidence level. For high-confidence group: show all pairs, confirm as batch. For medium/low: show individually.

**auto:** Not available for dedup merge (constraint). Falls back to `balanced`.

For each approved merge:

1. Show content of both notes:
```bash
obsidian read file="note1"
obsidian read file="note2"
```

1. Propose primary note (more complete or newer)
2. Execute merge:
  - Merge content via `Read` + `Edit`
  - Update frontmatter: `obsidian property:set file="primary" name="tags" value="merged-tags"`
  - Archive secondary:
    ```bash
    obsidian property:set file="secondary" name="merged_into" value="[[Primary Note]]"
    obsidian property:set file="secondary" name="status" value="archive"
    obsidian move file="secondary" to="_archive/merged/"
    ```

### Cleanup + Report

1. Cleanup temp files (ask user or auto-delete).
2. Delete `_temp/dedup-*.json` files.
3. Output report per `references/interaction-patterns.md`.
4. Offer daily log.
5. Commit per interaction-patterns convention.

## Important

- NEVER delete notes — archive to `_archive/merged/`
- Always wait for user approval before merging
- Preserve all original content
- Respond in Russian
