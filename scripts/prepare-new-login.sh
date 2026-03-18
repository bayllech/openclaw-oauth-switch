#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: bash scripts/prepare-new-login.sh <current-profile-name> [suggested-new-profile-name]" >&2
  exit 1
fi

CURRENT_NAME="$1"
SUGGESTED_NEW_NAME="${2:-<new-profile-name>}"
validate_profile_name "$CURRENT_NAME"
[[ "$SUGGESTED_NEW_NAME" == "<new-profile-name>" ]] || validate_profile_name "$SUGGESTED_NEW_NAME"

ensure_dirs
require_file "$TARGET_FILE" "Target auth file"
require_file "$CONFIG_FILE" "OpenClaw config"
STAMP="$(ts)"

echo "[1/6] Saving current active account as profile: $CURRENT_NAME"
bash "$SCRIPT_DIR/save-current-as.sh" "$CURRENT_NAME"

echo "[2/6] Backing up config/auth/session files"
cp -a "$CONFIG_FILE" "$MANUAL_BACKUP_DIR/openclaw.json.$STAMP.pre-login.bak"
cp -a "$TARGET_FILE" "$MANUAL_BACKUP_DIR/auth-profiles.json.$STAMP.pre-login.bak"
backup_sessions_if_present "$LOGIN_SESSION_BACKUP_DIR/sessions.$STAMP.bak"

echo "[3/6] Stopping gateway"
stop_gateway

echo "[4/6] Clearing main agent sessions"
clear_sessions_if_present

echo "[5/6] Removing current openai-codex:default from auth store"
node_json "$TARGET_FILE" <<'EOF'
const fs = require('fs');
const [path] = process.argv.slice(2);
const obj = JSON.parse(fs.readFileSync(path, 'utf8'));
obj.profiles = obj.profiles || {};
obj.usageStats = obj.usageStats || {};
delete obj.profiles['openai-codex:default'];
delete obj.usageStats['openai-codex:default'];
fs.writeFileSync(path, JSON.stringify(obj, null, 2) + '\n');
console.log('Removed openai-codex:default from auth-profiles.json');
EOF

echo "[6/6] Resetting OpenClaw config auth declaration to a clean openai-codex:default"
node_json "$CONFIG_FILE" <<'EOF'
const fs = require('fs');
const [path] = process.argv.slice(2);
const obj = JSON.parse(fs.readFileSync(path, 'utf8'));
obj.auth = obj.auth || {};
obj.auth.profiles = obj.auth.profiles || {};
for (const key of Object.keys(obj.auth.profiles)) {
  if (key.startsWith('openai-codex:')) delete obj.auth.profiles[key];
}
obj.auth.profiles['openai-codex:default'] = { provider: 'openai-codex', mode: 'oauth' };
if (obj.auth.order && typeof obj.auth.order === 'object') {
  delete obj.auth.order['openai-codex'];
}
fs.writeFileSync(path, JSON.stringify(obj, null, 2) + '\n');
console.log('Reset openclaw.json auth.profiles to openai-codex:default');
EOF

node_json "$WIZARD_STATE_FILE" "$CURRENT_NAME" "$SUGGESTED_NEW_NAME" <<'EOF'
const fs = require('fs');
const [path, currentName, suggestedName] = process.argv.slice(2);
const state = {
  version: 1,
  step: 'awaiting-browser-login',
  currentProfileSavedAs: currentName,
  suggestedNewProfileName: suggestedName,
  updatedAt: new Date().toISOString(),
  nextCommand: `bash scripts/save-logged-in-snapshot.sh ${suggestedName}`
};
fs.writeFileSync(path, JSON.stringify(state, null, 2) + '\n');
console.log(`Saved wizard state: ${path}`);
EOF

echo
print_login_instructions "$SUGGESTED_NEW_NAME"
