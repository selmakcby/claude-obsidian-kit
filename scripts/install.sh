#!/usr/bin/env bash
set -euo pipefail

# claude-obsidian-kit installer
# Usage:
#   ./install.sh <project-directory>
#
# Installs:
#   - archivist agent → <project>/.claude/agents/
#   - llm-wiki skill  → <project>/.claude/skills/
#   - vault template  → <project>/vault/

PROJECT_DIR="${1:-}"

if [ -z "$PROJECT_DIR" ]; then
  echo "Usage: ./install.sh <project-directory>"
  echo "Example: ./install.sh ~/my-saas-project"
  exit 1
fi

if [ ! -d "$PROJECT_DIR" ]; then
  echo "Error: $PROJECT_DIR doesn't exist"
  exit 1
fi

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
KIT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

echo "📦 Installing claude-obsidian-kit to $PROJECT_DIR"
echo ""

# 1. Agents (archivist + scribe)
mkdir -p "$PROJECT_DIR/.claude/agents"
cp "$KIT_ROOT/agents/archivist.md" "$PROJECT_DIR/.claude/agents/"
cp "$KIT_ROOT/agents/scribe.md" "$PROJECT_DIR/.claude/agents/"
echo "  ✓ Agents: archivist.md + scribe.md → .claude/agents/"

# 2. Skill
mkdir -p "$PROJECT_DIR/.claude/skills"
cp -r "$KIT_ROOT/skills/llm-wiki" "$PROJECT_DIR/.claude/skills/"
echo "  ✓ Skill: llm-wiki/ → .claude/skills/"

# 3. Vault template (only if vault doesn't exist yet)
if [ ! -d "$PROJECT_DIR/vault" ]; then
  cp -r "$KIT_ROOT/vault-template" "$PROJECT_DIR/vault"
  find "$PROJECT_DIR/vault" -name '.DS_Store' -delete 2>/dev/null || true
  echo "  ✓ Vault: vault/ (new vault created)"
else
  echo "  ⊘ Vault: skipped (vault/ already exists)"
fi

# 4. Obsidian config — graph colours + the [!conflict] callout the skill needs.
#    Only written if absent; never clobbers an existing Obsidian setup.
OBS_DIR="$PROJECT_DIR/vault/.obsidian"
if [ -d "$PROJECT_DIR/vault" ] && [ ! -f "$OBS_DIR/graph.json" ]; then
  mkdir -p "$OBS_DIR/snippets"
  cp "$KIT_ROOT/obsidian/graph.json" "$OBS_DIR/graph.json"
  cp "$KIT_ROOT/obsidian/snippets/vault-layers.css" "$OBS_DIR/snippets/"
  if [ ! -f "$OBS_DIR/appearance.json" ]; then
    cat > "$OBS_DIR/appearance.json" <<'JSON'
{
  "accentColor": "#e07a5f",
  "enabledCssSnippets": ["vault-layers"]
}
JSON
    echo "  ✓ Obsidian: graph colours + vault-layers snippet (enabled)"
  else
    echo "  ✓ Obsidian: graph colours + vault-layers snippet"
    echo "    ↳ enable it: Settings → Appearance → CSS snippets → vault-layers"
  fi
else
  echo "  ⊘ Obsidian: skipped (config already present)"
fi

echo ""
echo "✅ Done. Next steps:"
echo ""
echo "  1. Open Obsidian → 'Open folder as vault' → $PROJECT_DIR/vault"
echo "  2. In your CLAUDE.md, add the vault permissions:"
echo "     permissions.allow: ['Write(vault/**)', 'Edit(vault/**)']"
echo "  3. Test: open Claude Code, ask it to INGEST a decision"
echo "  4. Audit any time: python3 $KIT_ROOT/scripts/vault-lint.py $PROJECT_DIR/vault"
echo ""
echo "  Already have months of material instead of a clean start? → RETROFIT.md"
echo ""
echo "🔗 https://github.com/selmakcby/claude-obsidian-kit"
