# Changelog

All notable changes to this project will be documented in this file.

Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0] - 2026-03-29

### Added
- Timezone confirmation before first daily log write — detects system timezone and asks user to confirm
- English-only tag convention enforced across all skills to prevent cross-language duplicates
- Russian-default filename convention with English abbreviation exceptions (Git, ML, SemVer, etc.)
- Non-English tag detection added to `/audit` checks

### Changed
- Updated `vault-config.example.md`, `frontmatter-spec.md`, `interaction-patterns.md`
- Updated skills: `process-inbox`, `decompose`, `audit`

## [1.1.1] - 2026-03-29

### Added
- `README.ru.md` — full Russian translation of README
- Language switch links between English and Russian READMEs

### Removed
- `docs/plans/` and `docs/specs/` removed from git tracking (added to `.gitignore`)

## [1.1.0] - 2026-03-29

### Added
- Pre-flight check in `cli-operations.md`: stop and warn if Obsidian installer is outdated
- Windows troubleshooting: `Obsidian.exe` vs `Obsidian.com` issue documented with wrapper script fix

### Fixed
- CLI write commands (`property:set`, `daily:append`, etc.) failing with exit 127 on Windows due to GUI exe resolution

## [1.0.0] - 2026-03-28

### Added
- Initial release
- Skills: `/process-inbox`, `/decompose`, `/dedup`, `/cluster`, `/audit`, `/rename-tags`, `/improve`
- Reference files: `vault-config`, `frontmatter-spec`, `cli-operations`, `interaction-patterns`

[1.2.0]: https://github.com/YaroslavDrozdovskiy/obsidian-brain/compare/v1.1.1...v1.2.0
[1.1.1]: https://github.com/YaroslavDrozdovskiy/obsidian-brain/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/YaroslavDrozdovskiy/obsidian-brain/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/YaroslavDrozdovskiy/obsidian-brain/releases/tag/v1.0.0
