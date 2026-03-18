#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

require_file "$TARGET_FILE" "Target auth file"

echo "Target file: $TARGET_FILE"
echo
node_json "$TARGET_FILE" <<'EOF'
const fs = require('fs');
const [path] = process.argv.slice(2);
const data = JSON.parse(fs.readFileSync(path, 'utf8'));
const profiles = data.profiles || {};
const usageStats = data.usageStats || {};
const keys = Object.keys(profiles);

const mask = (value) => {
  if (!value) return '';
  const s = String(value);
  if (s.length <= 10) return s;
  return `${s.slice(0, 4)}...${s.slice(-4)}`;
};

console.log('Profile keys:');
if (!keys.length) {
  console.log('  (none)');
} else {
  for (const key of keys) {
    const p = profiles[key] || {};
    const stat = usageStats[key] || {};
    console.log(`- ${key}`);
    console.log(`  type         : ${p.type || ''}`);
    console.log(`  provider     : ${p.provider || ''}`);
    console.log(`  accountId    : ${mask(p.accountId || '')}`);
    console.log(`  hasAccess    : ${p.access ? 'yes' : 'no'}`);
    console.log(`  hasRefresh   : ${p.refresh ? 'yes' : 'no'}`);
    if (p.expires) {
      try {
        console.log(`  expires      : ${new Date(p.expires).toISOString()}`);
      } catch {
        console.log(`  expires      : ${p.expires}`);
      }
    } else {
      console.log('  expires      : ');
    }
    console.log(`  lastUsed     : ${stat.lastUsed ? new Date(stat.lastUsed).toISOString() : ''}`);
    console.log(`  errorCount   : ${stat.errorCount ?? ''}`);
  }
}
EOF

if have_openclaw; then
  echo
  echo "Channel status (best effort):"
  show_channels_status
fi
