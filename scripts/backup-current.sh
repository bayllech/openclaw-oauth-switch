#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_dirs
require_file "$TARGET_FILE" "Target auth file"
STAMP="$(ts)"
BACKUP_FILE="$BACKUP_DIR/auth-profiles.$STAMP.json"

cp "$TARGET_FILE" "$BACKUP_FILE"
echo "[DONE] Backup created: $BACKUP_FILE"
