#!/bin/sh
# Create an instruction file in the current project without replacing its files.
set -eu
repo_dir=$(CDPATH='' cd "$(dirname "$0")/.." && pwd)
source_file="$repo_dir/config/CLAUDE.md"
case "${1:-}" in
  codex) target=AGENTS.md ;;
  gemini) target=GEMINI.md ;;
  cursor) target=.cursor/rules/dotclaude.mdc ;;
  aider) target=dotclaude-conventions.md ;;
  *) echo 'Usage: convert.sh {codex|gemini|cursor|aider}' >&2; exit 1 ;;
esac
[ "$#" -eq 1 ] || { echo 'Expected one target.' >&2; exit 1; }

# Stage complete files on the same filesystem. Hard links create the final
# names without replacing an existing file, including one created concurrently.
if [ "$1" = cursor ]; then
  for dir in .cursor .cursor/rules; do
    if [ -L "$dir" ]; then echo "Refusing linked directory: $dir" >&2; exit 1; fi
    mkdir -p "$dir"
  done
fi
parent=$(dirname "$target")
stage=$(mktemp -d "$parent/.dotclaude-export.XXXXXXXX")
base=$(basename "$target")
rollback() {
  if [ "${publishing_pair:-false}" = true ] && [ "$target" -ef "$stage/$base" ] && ! [ .aider.conf.yml -ef "$stage/.aider.conf.yml" ]; then
    rm -f "$target"
  fi
  rm -rf "$stage"
}
trap rollback EXIT
trap 'exit 1' HUP INT TERM
if [ -e "$target" ] || [ -L "$target" ]; then
  echo "Already exists: $target. Generate in an empty directory to compare." >&2
  exit 1
fi

if [ "$1" = cursor ]; then
  printf '%s\n' '---' 'description: dotclaude project working preferences' 'alwaysApply: true' '---' '' > "$stage/$base"
else
  : > "$stage/$base"
fi
awk '/^<!-- Claude Code only -->$/ {exit} {print}' "$source_file" >> "$stage/$base"

if [ "$1" = aider ]; then
  cfg=.aider.conf.yml
  if [ -e "$cfg" ] || [ -L "$cfg" ]; then
    echo "Already exists: $cfg. Generate in an empty directory to compare." >&2
    exit 1
  fi
  printf '%s\n' 'read:' '  - dotclaude-conventions.md' > "$stage/.aider.conf.yml"
fi

if [ "$1" = aider ]; then publishing_pair=true; fi
ln "$stage/$base" "$parent/"
if [ "$1" = aider ]; then
  ln "$stage/.aider.conf.yml" ./
  echo "Created $cfg and $target"
else
  echo "Created $target"
fi
