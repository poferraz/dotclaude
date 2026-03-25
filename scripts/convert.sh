#!/bin/sh
# dotclaude convert script
# Converts config/CLAUDE.md for use with other coding agents
#
# Usage:
#   ./scripts/convert.sh codex      → AGENTS.md (OpenAI Codex / ChatGPT)
#   ./scripts/convert.sh gemini     → GEMINI.md (Gemini CLI)
#   ./scripts/convert.sh cursor     → .cursorrules (Cursor editor)
#   ./scripts/convert.sh aider      → .aider.conf.yml (Aider)
#
# Output files are written to the current directory.
# Converts Claude-specific terminology to agent-agnostic language.

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SOURCE="$REPO_DIR/config/CLAUDE.md"
TARGET_AGENT="${1:-}"

# ── Colors ────────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

ok()   { printf "${GREEN}  ✓${NC} %s\n" "$1"; }
info() { printf "${BLUE}  →${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}  ⚠${NC} %s\n" "$1"; }
err()  { printf "${RED}  ✗${NC} %s\n" "$1"; }

# ── Strip Claude-specific references ─────────────────────────────────────────
# Removes or genericizes lines that only make sense for Claude Code:
# - Shift+Tab cycles, /config, /output-style references
# - claude update, claude doctor commands
# - Esc Esc rewind instruction

sanitize_for_agent() {
  sed \
    -e 's/Shift+Tab cycles: normal \/ auto-accept \/ plan mode/Toggle auto-accept mode via your agent'\''s settings/g' \
    -e 's|/config for per-session toggles, /output-style to switch output style|Check your agent'\''s settings for per-session toggles|g' \
    -e 's/Use Esc Esc to rewind to any previous prompt (restores files too)/Use your agent'\''s history or undo to rewind to a previous state/g' \
    -e 's/Update Claude Code regularly: claude update/Keep your coding agent up to date/g' \
    -e 's/Use claude doctor if anything feels broken/Run your agent'\''s diagnostics if anything feels broken/g' \
    -e 's/Use plan mode (Shift+Tab)/Use your agent'\''s plan\/architect mode/g' \
    -e 's/CLAUDE\.md/AGENTS.md/g'
}

# ── Usage ─────────────────────────────────────────────────────────────────────
usage() {
  echo ""
  echo "Usage: $0 <agent>"
  echo ""
  echo "Supported agents:"
  echo "  codex      → AGENTS.md       (OpenAI Codex, ChatGPT, o3)"
  echo "  gemini     → GEMINI.md       (Gemini CLI)"
  echo "  cursor     → .cursorrules    (Cursor editor)"
  echo "  aider      → .aider.conf.yml (Aider)"
  echo ""
  echo "Output is written to the current directory."
  echo ""
}

if [ -z "$TARGET_AGENT" ]; then
  usage
  exit 1
fi

if [ ! -f "$SOURCE" ]; then
  err "Source file not found: $SOURCE"
  exit 1
fi

echo ""
echo "dotclaude converter"
echo "==================="
echo ""

# ── Convert ───────────────────────────────────────────────────────────────────

case "$TARGET_AGENT" in

  codex)
    TARGET="$(pwd)/AGENTS.md"
    info "Converting for OpenAI Codex / ChatGPT..."
    {
      echo "# AGENTS.md"
      echo "# Converted from dotclaude CLAUDE.md (github.com/yourusername/dotclaude)"
      echo "# Adjust the 'About Me' section to match your profile."
      echo ""
      sanitize_for_agent < "$SOURCE" | grep -v "^# Global CLAUDE.md"
    } > "$TARGET"
    ok "Written: $TARGET"
    warn "Review and remove any Claude-specific tool references (Skill tool, Agent tool)"
    ;;

  gemini)
    TARGET="$(pwd)/GEMINI.md"
    info "Converting for Gemini CLI..."
    {
      echo "# GEMINI.md"
      echo "# Converted from dotclaude CLAUDE.md (github.com/yourusername/dotclaude)"
      echo "# Adjust the 'About Me' section to match your profile."
      echo ""
      sanitize_for_agent < "$SOURCE" | grep -v "^# Global CLAUDE.md"
    } > "$TARGET"
    ok "Written: $TARGET"
    warn "Review Gemini CLI docs for supported frontmatter fields"
    ;;

  cursor)
    TARGET="$(pwd)/.cursorrules"
    info "Converting for Cursor..."
    # Cursor uses a flat text format — strip markdown headings
    {
      printf "# Coding agent rules (converted from dotclaude)\n"
      printf "# Source: github.com/yourusername/dotclaude\n\n"
      sanitize_for_agent < "$SOURCE" \
        | grep -v "^# Global CLAUDE.md" \
        | sed 's/^## /\n/; s/^### /\n/; s/^#### //'
    } > "$TARGET"
    ok "Written: $TARGET"
    warn "Cursor rules are plain text — review for any markdown that renders oddly"
    ;;

  aider)
    TARGET="$(pwd)/.aider.conf.yml"
    info "Converting for Aider..."
    {
      printf "# .aider.conf.yml\n"
      printf "# Converted from dotclaude CLAUDE.md\n"
      printf "# Source: github.com/yourusername/dotclaude\n\n"
      printf "system-prompt: |\n"
      sanitize_for_agent < "$SOURCE" \
        | grep -v "^# Global CLAUDE.md" \
        | sed 's/^/  /'
    } > "$TARGET"
    ok "Written: $TARGET"
    warn "Verify aider --system-prompt flag syntax for your aider version"
    ;;

  *)
    err "Unknown agent: $TARGET_AGENT"
    usage
    exit 1
    ;;

esac

echo ""
echo "  The converted file keeps the core behavioral principles."
echo "  Agent-specific mechanics (Shift+Tab, /commands, Esc Esc) have been"
echo "  replaced with generic equivalents."
echo ""
echo "  Always review before using — some Claude Code concepts have no"
echo "  direct equivalent in other agents."
echo ""
