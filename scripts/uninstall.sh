#!/bin/sh
# Restore a selected snapshot, retaining the displaced configuration.
set -eu

script_dir="$(cd "$(dirname "$0")" && pwd)"
exec node "$script_dir/manage-config.cjs" uninstall
