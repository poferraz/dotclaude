#!/bin/sh
# dotclaude uninstall script
# Restores the backup created by install.sh
#
# NEVER deletes ~/.claude/ without a backup to restore from.
# If no backup exists, prints a warning and exits.

set -e

CLAUDE_DIR="$HOME/.claude"

# ── Colors ────────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ok()   { printf "${GREEN}  ✓${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}  ⚠${NC} %s\n" "$1"; }
info() { printf "${BLUE}  →${NC} %s\n" "$1"; }
err()  { printf "${RED}  ✗${NC} %s\n" "$1"; }

echo ""
echo "dotclaude uninstaller"
echo "====================="
echo ""

# ── Find backups ──────────────────────────────────────────────────────────────

BACKUPS=$(ls -d "$HOME/.claude.backup."* 2>/dev/null | sort -r || true)

if [ -z "$BACKUPS" ]; then
  warn "No backup found at $HOME/.claude.backup.*"
  echo ""
  echo "  The install script creates a backup at ~/.claude.backup.YYYYMMDDHHMMSS"
  echo "  before modifying your config. No backup means the install script was"
  echo "  not run, or the backup was manually deleted."
  echo ""
  echo "  To manually remove dotclaude files without a backup, delete:"
  echo "    ~/.claude/CLAUDE.md"
  echo "    ~/.claude/agents/"
  echo "    ~/.claude/skills/"
  echo "    ~/.claude/commands/"
  echo ""
  echo "  Or restore your own backup from a different source."
  exit 1
fi

# ── Select backup ─────────────────────────────────────────────────────────────

BACKUP_COUNT=$(echo "$BACKUPS" | wc -l | tr -d ' ')

if [ "$BACKUP_COUNT" -eq 1 ]; then
  SELECTED_BACKUP="$BACKUPS"
  info "Found 1 backup: $SELECTED_BACKUP"
else
  echo "Multiple backups found:"
  echo ""
  i=1
  for b in $BACKUPS; do
    echo "  $i) $b"
    i=$((i + 1))
  done
  echo ""
  printf "Restore which backup? [1]: "
  read -r CHOICE
  CHOICE="${CHOICE:-1}"

  i=1
  for b in $BACKUPS; do
    if [ "$i" -eq "$CHOICE" ]; then
      SELECTED_BACKUP="$b"
      break
    fi
    i=$((i + 1))
  done

  if [ -z "$SELECTED_BACKUP" ]; then
    err "Invalid choice."
    exit 1
  fi
fi

echo ""

# ── Confirm ───────────────────────────────────────────────────────────────────

warn "This will replace $CLAUDE_DIR with $SELECTED_BACKUP"
printf "Continue? [y/N]: "
read -r CONFIRM

case "$CONFIRM" in
  y|Y|yes|YES) ;;
  *)
    info "Aborted."
    exit 0
    ;;
esac

echo ""

# ── Restore ───────────────────────────────────────────────────────────────────

info "Removing current $CLAUDE_DIR..."
rm -rf "$CLAUDE_DIR"

info "Restoring $SELECTED_BACKUP..."
cp -r "$SELECTED_BACKUP" "$CLAUDE_DIR"

ok "Restored $SELECTED_BACKUP → $CLAUDE_DIR"
echo ""
echo "  Run 'claude doctor' to verify the restored configuration."
echo ""
