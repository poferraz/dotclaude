#!/bin/sh
# dotclaude install script
# Copies configuration files from this repo into ~/.claude/
#
# Requirements: Claude Code >= 2.1.0, Node.js, git
# Existing configuration files are preserved.

set -e

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"

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
  err "Node.js 18 or newer is required for the local installer."
  err "Install from https://nodejs.org"
  exit 1
fi
if ! node -e 'process.exit(Number(process.versions.node.split(".")[0]) < 18 ? 1 : 0)'; then
  err "Node.js 18 or newer is required for the local installer."
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

node "$REPO_DIR/scripts/manage-config.cjs" install
echo "For upgrades, compare existing managed files and settings with the current source."
echo "Previously configured hooks and permissions remain active until you review and change them."
echo "Settings are optional. Merge only the settings you want."
echo "See README.md for setup instructions. Run claude doctor to check your installation."
