#!/usr/bin/env bash
# Stop-hook: предупреждает в stdout если skills/agents/references новее docs/specs/current.md.
# Молчит при отсутствии drift — минимум шума в "тихие" сессии.

set -e
cd "${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || echo .)}"

SPEC="docs/specs/current.md"
if [[ ! -f "$SPEC" ]]; then
  echo "⚠️  docs/specs/current.md отсутствует — создать при первой правке архитектуры."
  exit 0
fi

NEWER=$(find skills agents references \
  -type f \( -name "*.md" -o -name "SKILL.md" \) \
  -newer "$SPEC" 2>/dev/null | head -5)

if [[ -n "$NEWER" ]]; then
  echo "⚠️  Изменены новее docs/specs/current.md:"
  echo "$NEWER" | sed 's/^/   /'
  echo "   → обнови docs/specs/current.md, заведи ADR в docs/decisions/ если было архитектурное решение,"
  echo "     добавь в docs/known-issues.md если всплыла новая гоча."
fi
