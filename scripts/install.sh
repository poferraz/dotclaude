#!/bin/sh
# dotclaude install script
# Copies configuration files from this repo into ~/.claude/
#
# Requirements: Claude Code >= 2.1.0, Node.js, git
# Safe to run multiple times (idempotent, non-destructive)

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
CLAUDE_DIR="$HOME/.claude"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ok()   { printf "${GREEN}  ✓${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}  ⚠${NC} %s\n" "$1"; }
info() { printf "${BLUE}  →${NC} %s\n" "$1"; }
err()  { printf "${RED}  ✗${NC} %s\n" "$1"; }

echo ""
echo "dotclaude installer"
echo "==================="
echo ""

# ── Step 1: Prerequisites ─────────────────────────────────────────────────────

info "Checking prerequisites..."

# Check Claude Code
if ! command -v claude >/dev/null 2>&1; then
  err "Claude Code not found. Install from https://claude.ai/code"
  exit 1
fi

# Check Claude Code version >= 2.1.0
CLAUDE_VERSION=$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
if [ -z "$CLAUDE_VERSION" ]; then
  warn "Could not determine Claude Code version. Proceeding anyway."
else
  MAJOR=$(echo "$CLAUDE_VERSION" | cut -d. -f1)
  MINOR=$(echo "$CLAUDE_VERSION" | cut -d. -f2)
  if [ "$MAJOR" -lt 2 ] || { [ "$MAJOR" -eq 2 ] && [ "$MINOR" -lt 1 ]; }; then
    err "Claude Code $CLAUDE_VERSION found. Version >= 2.1.0 required."
    err "Run: claude update"
    exit 1
  fi
  ok "Claude Code $CLAUDE_VERSION"
fi

# Check Node.js
if ! command -v node >/dev/null 2>&1; then
  err "Node.js not found. Required for Claude Code plugins."
  err "Install from https://nodejs.org"
  exit 1
fi
ok "Node.js $(node --version)"

# Check git
if ! command -v git >/dev/null 2>&1; then
  err "git not found."
  exit 1
fi
ok "git $(git --version | cut -d' ' -f3)"

echo ""

# ── Step 2: Back up existing ~/.claude/ ──────────────────────────────────────

if [ -d "$CLAUDE_DIR" ]; then
  BACKUP="$HOME/.claude.backup.$(date +%Y%m%d%H%M%S)"
  info "Backing up $CLAUDE_DIR to $BACKUP..."
  cp -r "$CLAUDE_DIR" "$BACKUP"
  ok "Backup created: $BACKUP"
else
  info "No existing ~/.claude/ found. Starting fresh."
fi

echo ""

# ── Step 3: Create directory structure ───────────────────────────────────────

info "Creating directory structure..."
mkdir -p "$CLAUDE_DIR/agents"
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/commands"
mkdir -p "$CLAUDE_DIR/rules"
mkdir -p "$CLAUDE_DIR/plans"
mkdir -p "$CLAUDE_DIR/sessions"
ok "Directory structure ready"

echo ""

# ── Step 4: Copy config files ─────────────────────────────────────────────────

info "Copying CLAUDE.md..."
cp "$REPO_DIR/config/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
ok "CLAUDE.md → ~/.claude/CLAUDE.md"

info "Copying agents..."
if [ -d "$REPO_DIR/config/agents" ]; then
  cp -r "$REPO_DIR/config/agents/." "$CLAUDE_DIR/agents/"
  AGENT_COUNT=$(find "$REPO_DIR/config/agents" -name "*.md" | wc -l | tr -d ' ')
  ok "$AGENT_COUNT agents → ~/.claude/agents/"
fi

info "Copying skills..."
if [ -d "$REPO_DIR/config/skills" ]; then
  cp -r "$REPO_DIR/config/skills/." "$CLAUDE_DIR/skills/"
  SKILL_COUNT=$(find "$REPO_DIR/config/skills" -name "SKILL.md" | wc -l | tr -d ' ')
  ok "$SKILL_COUNT skills → ~/.claude/skills/"
fi

info "Copying commands..."
if [ -d "$REPO_DIR/config/commands" ]; then
  cp -r "$REPO_DIR/config/commands/." "$CLAUDE_DIR/commands/"
  CMD_COUNT=$(find "$REPO_DIR/config/commands" -name "*.md" | wc -l | tr -d ' ')
  ok "$CMD_COUNT commands → ~/.claude/commands/"
fi

info "Copying rules..."
if [ -d "$REPO_DIR/config/rules" ] && [ "$(ls -A "$REPO_DIR/config/rules" 2>/dev/null)" ]; then
  cp -r "$REPO_DIR/config/rules/." "$CLAUDE_DIR/rules/"
  ok "Rules → ~/.claude/rules/"
else
  info "No rules directory in this config (rules live in CLAUDE.md and per-project)"
fi

echo ""

# ── Step 5: Settings (manual only) ───────────────────────────────────────────

warn "Settings NOT copied automatically."
echo ""
echo "  config/settings.json contains hook configurations that depend on"
echo "  your specific plugin installation paths. Review it and merge manually:"
echo ""
echo "  1. Install plugins first (Step 6 below)"
echo "  2. Run: claude plugins list  — to find your plugin root paths"
echo "  3. Open config/settings.json and update \$HOME paths to match"
echo "  4. Merge the permissions and hook blocks into your ~/.claude/settings.json"
echo ""

# ── Step 6: Next steps ────────────────────────────────────────────────────────

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Installation complete. Recommended next steps:"
echo ""
echo "  1. Install plugin marketplaces in Claude Code:"
echo ""
echo "     Open ~/.claude/settings.json and add to extraKnownMarketplaces:"
echo "     - everything-claude-code  (affaan-m/everything-claude-code)"
echo "     - context-mode            (mksglu/context-mode)"
echo "     - prompt-improver         (severity1/severity1-marketplace)"
echo "     - ui-ux-pro-max           (nextlevelbuilder/ui-ux-pro-max-skill)"
echo ""
echo "     See config/settings.json for the exact JSON to add."
echo ""
echo "  2. Customize CLAUDE.md for your profile:"
echo ""
echo "     The 'About Me' section uses generic language. Adjust it to match"
echo "     your actual experience level and working style."
echo ""
echo "  3. Verify the install:"
echo ""
echo "     claude --version         # should be >= 2.1.0"
echo "     claude doctor            # health check"
echo "     claude -p 'say hello'    # quick test session"
echo ""
echo "  4. Optional — install beads for structured task tracking:"
echo ""
echo "     https://github.com/steveyegge/beads"
echo "     Pairs well with context-mode: beads for task state, context-mode"
echo "     for session history."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
