#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

RESTART_GATEWAY=0
CLEAR_SESSIONS=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --restart-gateway)
      RESTART_GATEWAY=1
      shift
      ;;
    --clear-sessions)
      CLEAR_SESSIONS=1
      shift
      ;;
    --full)
      RESTART_GATEWAY=1
      CLEAR_SESSIONS=1
      shift
      ;;
    -h|--help)
      echo "Usage: bash scripts/switch-profile.sh [--restart-gateway] [--clear-sessions] [--full] <profile-name>"
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -ne 1 ]]; then
  echo "Usage: bash scripts/switch-profile.sh [--restart-gateway] [--clear-sessions] [--full] <profile-name>" >&2
  exit 1
fi

NAME="$1"
validate_profile_name "$NAME"
ensure_dirs
require_file "$TARGET_FILE" "Target auth file"
SOURCE_FILE="$(profile_path "$NAME")"
require_file "$SOURCE_FILE" "Saved profile"
STAMP="$(ts)"
BACKUP_FILE="$BACKUP_DIR/auth-profiles.before-switch.$STAMP.json"

if (( RESTART_GATEWAY == 1 )); then
  echo "[1/5] Stopping gateway..."
  stop_gateway
fi

cp "$TARGET_FILE" "$BACKUP_FILE"
echo "[2/5] Backup created: $BACKUP_FILE"

echo "[3/5] Applying saved snapshot to openai-codex:default"
node_json "$TARGET_FILE" "$SOURCE_FILE" <<'EOF'
const fs = require('fs');
const [targetPath, sourcePath] = process.argv.slice(2);
const target = JSON.parse(fs.readFileSync(targetPath, 'utf8'));
const source = JSON.parse(fs.readFileSync(sourcePath, 'utf8'));
const profile = source?.profiles?.['openai-codex:default'];
if (!profile) {
  console.error('ERROR: Snapshot file does not contain profiles.openai-codex:default');
  process.exit(1);
}
target.profiles = target.profiles || {};
target.usageStats = target.usageStats || {};
target.profiles['openai-codex:default'] = profile;
if (source?.usageStats?.['openai-codex:default']) {
  target.usageStats['openai-codex:default'] = source.usageStats['openai-codex:default'];
} else {
  delete target.usageStats['openai-codex:default'];
}
fs.writeFileSync(targetPath, JSON.stringify(target, null, 2) + '\n');
console.log('Applied snapshot to active auth store');
EOF

if (( CLEAR_SESSIONS == 1 )); then
  echo "[4/5] Clearing main agent sessions..."
  backup_sessions_if_present "$SESSION_BACKUP_DIR/sessions-$STAMP.bak"
  clear_sessions_if_present
else
  echo "[4/5] Session clearing skipped"
fi

if (( RESTART_GATEWAY == 1 )); then
  echo "[5/5] Starting gateway..."
  start_gateway
else
  echo "[5/5] Gateway restart skipped"
fi

echo
echo "Switched active OpenAI OAuth profile to: $NAME"
echo "Source snapshot: $SOURCE_FILE"
echo "Target auth file: $TARGET_FILE"
if (( RESTART_GATEWAY == 1 )); then
  echo "Verification suggestion: openclaw channels list --json"
fi
echo "Next step: bash scripts/show-current.sh"
if (( CLEAR_SESSIONS == 1 )); then
  echo "Recommended: go back to chat and send /new"
fi
