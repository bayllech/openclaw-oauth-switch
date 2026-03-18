#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

DRY_RUN=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    -h|--help)
      echo "Usage: bash scripts/add-account.sh [--dry-run] <new-profile-name> [current-profile-name-to-save]"
      echo "Example: bash scripts/add-account.sh personal work"
      exit 0
      ;;
    *)
      break
      ;;
  esac
done

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Usage: bash scripts/add-account.sh <new-profile-name> [current-profile-name-to-save]" >&2
  echo "Example: bash scripts/add-account.sh personal work" >&2
  exit 1
fi

NEW_NAME="$1"
CURRENT_NAME="${2:-}"
validate_profile_name "$NEW_NAME"
[[ -z "$CURRENT_NAME" ]] || validate_profile_name "$CURRENT_NAME"

ensure_dirs
require_file "$TARGET_FILE" "Target auth file"
require_file "$CONFIG_FILE" "OpenClaw config"
STAMP="$(ts)"

if (( DRY_RUN == 1 )); then
  echo "[DRY-RUN] Would add new account profile: $NEW_NAME"
  if [[ -n "$CURRENT_NAME" ]]; then
    echo "[DRY-RUN] Would first save current active account as: $CURRENT_NAME"
  fi
  cat <<EOF
[DRY-RUN] Planned steps:
  1) Back up config/auth/session files
  2) Stop gateway
  3) Clear main agent sessions
  4) Remove current openai-codex:default from auth store
  5) Reset openclaw.json to a clean openai-codex:default OAuth declaration
  6) Start gateway
  7) Run: openclaw models auth login --provider openai-codex
  8) Wait for browser login + pasted localhost redirect URL
  9) Save the newly logged-in account as: $NEW_NAME
EOF
  exit 0
fi

if [[ -n "$CURRENT_NAME" ]]; then
  echo "[0/8] Saving current active account as profile: $CURRENT_NAME"
  bash "$SCRIPT_DIR/save-current-as.sh" "$CURRENT_NAME"
fi

echo "[1/8] Backing up config/auth/session files"
cp -a "$CONFIG_FILE" "$MANUAL_BACKUP_DIR/openclaw.json.$STAMP.pre-add-account.bak"
cp -a "$TARGET_FILE" "$MANUAL_BACKUP_DIR/auth-profiles.json.$STAMP.pre-add-account.bak"
backup_sessions_if_present "$LOGIN_SESSION_BACKUP_DIR/sessions.$STAMP.bak"

echo "[2/8] Stopping gateway"
stop_gateway

echo "[3/8] Clearing main agent sessions"
clear_sessions_if_present

echo "[4/8] Removing current openai-codex:default from auth store"
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

echo "[5/8] Resetting OpenClaw config auth declaration to a clean openai-codex:default"
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

echo "[6/8] Starting gateway"
start_gateway

echo "[7/8] Starting interactive OpenClaw OAuth login"
python3 - <<'PY'
import subprocess, threading, sys, re, time

cmd = ['openclaw', 'models', 'auth', 'login', '--provider', 'openai-codex']
proc = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)

state = {
    'saw_prompt': False,
    'auth_url': None,
}

url_re = re.compile(r'https?://\S+')
prompt_markers = [
    'Paste the redirect URL',
    'paste the redirect url',
    'redirect URL',
    'redirect url',
]

def reader():
    for line in proc.stdout:
        sys.stdout.write(line)
        sys.stdout.flush()
        m = url_re.search(line)
        if m and ('auth' in line.lower() or 'openai' in line.lower() or 'http' in line.lower()):
            state['auth_url'] = m.group(0)
        low = line.lower()
        if any(marker.lower() in low for marker in prompt_markers):
            state['saw_prompt'] = True

thread = threading.Thread(target=reader, daemon=True)
thread.start()

for _ in range(180):
    if state['saw_prompt']:
        break
    if proc.poll() is not None:
        break
    time.sleep(0.25)

if proc.poll() is None:
    print('\n===== OAuth browser step =====')
    if state['auth_url']:
        print(f'If needed, open this URL in your browser:\n{state["auth_url"]}')
    print('Log in with the NEW account you want to save.')
    print('Important: use an incognito/private window or a fresh browser profile.')
    print('After the browser redirects to localhost, paste the FULL localhost URL below.')
    try:
        redirect_url = input('Redirect URL> ').strip()
    except EOFError:
        redirect_url = ''
    if not redirect_url:
        print('ERROR: No redirect URL provided.', file=sys.stderr)
        proc.kill()
        sys.exit(1)
    proc.stdin.write(redirect_url + '\n')
    proc.stdin.flush()

code = proc.wait()
thread.join(timeout=1)
if code != 0:
    sys.exit(code)
PY

echo "[8/8] Saving the newly logged-in account as: $NEW_NAME"
bash "$SCRIPT_DIR/save-logged-in-snapshot.sh" "$NEW_NAME"

echo
echo "Done. Added new saved account profile: $NEW_NAME"
echo "Recommended next step: bash scripts/show-current.sh"
echo "If you will continue chatting in OpenClaw, sending /new is recommended."
