#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [[ $# -ne 1 ]]; then
  echo "Usage: bash scripts/save-logged-in-snapshot.sh <new-profile-name>" >&2
  exit 1
fi

NAME="$1"
validate_profile_name "$NAME"
ensure_dirs
require_file "$TARGET_FILE" "Target auth file"

DEST_FILE="$(profile_path "$NAME")"

echo "[1/3] Checking current auth status..."
show_channels_status

echo "[2/3] Saving current logged-in openai-codex:default as: $NAME"
node_json "$TARGET_FILE" "$DEST_FILE" <<'EOF'
const fs = require('fs');
const [src, dst] = process.argv.slice(2);
const obj = JSON.parse(fs.readFileSync(src, 'utf8'));
const profile = obj?.profiles?.['openai-codex:default'];
const usage = obj?.usageStats?.['openai-codex:default'];
if (!profile) {
  console.error('ERROR: openai-codex:default not found after login');
  process.exit(1);
}
const snapshot = {
  version: 1,
  savedAt: new Date().toISOString(),
  source: {
    kind: 'openclaw-openai-oauth-switch',
    profileKey: 'openai-codex:default'
  },
  profiles: {
    'openai-codex:default': profile
  },
  usageStats: usage ? { 'openai-codex:default': usage } : {}
};
fs.writeFileSync(dst, JSON.stringify(snapshot, null, 2) + '\n');
console.log(`Saved: ${dst}`);
EOF

if [[ -f "$WIZARD_STATE_FILE" ]]; then
  rm -f "$WIZARD_STATE_FILE"
  echo "[3/3] Login wizard state cleared."
else
  echo "[3/3] Done."
fi

echo "You can now switch to it with:"
echo "  bash scripts/switch-profile.sh --full $NAME"
