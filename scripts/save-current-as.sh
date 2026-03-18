#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [[ $# -ne 1 ]]; then
  echo "Usage: bash scripts/save-current-as.sh <profile-name>" >&2
  exit 1
fi

NAME="$1"
validate_profile_name "$NAME"
ensure_dirs
require_file "$TARGET_FILE" "Target auth file"
DEST_FILE="$(profile_path "$NAME")"

node_json "$TARGET_FILE" "$DEST_FILE" <<'EOF'
const fs = require('fs');
const [src, dst] = process.argv.slice(2);
const obj = JSON.parse(fs.readFileSync(src, 'utf8'));
const profile = obj?.profiles?.['openai-codex:default'];
const usage = obj?.usageStats?.['openai-codex:default'];
if (!profile) {
  console.error('ERROR: openai-codex:default not found in current auth store');
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
console.log(`Saved current active OpenAI OAuth profile as: ${dst}`);
EOF
