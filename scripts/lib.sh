#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
OPENCLAW_ROOT="${OPENCLAW_ROOT:-$HOME/.openclaw}"
OPENCLAW_AGENT_DIR="${OPENCLAW_AGENT_DIR:-$OPENCLAW_ROOT/agents/main/agent}"
TARGET_FILE="$OPENCLAW_AGENT_DIR/auth-profiles.json"
CONFIG_FILE="$OPENCLAW_ROOT/openclaw.json"
SESSIONS_DIR="$OPENCLAW_ROOT/agents/main/sessions"
PROFILE_DIR="$PROJECT_DIR/profiles"
BACKUP_DIR="$PROJECT_DIR/backups"
STATE_DIR="$PROJECT_DIR/state"
MANUAL_BACKUP_DIR="$BACKUP_DIR/manual-snapshots"
SESSION_BACKUP_DIR="$BACKUP_DIR/session-clears"
LOGIN_SESSION_BACKUP_DIR="$BACKUP_DIR/session-prep"
WIZARD_STATE_FILE="$STATE_DIR/login-wizard.json"
SETTINGS_FILE="$STATE_DIR/settings.json"

ensure_dirs() {
  mkdir -p "$PROFILE_DIR" "$BACKUP_DIR" "$STATE_DIR" "$MANUAL_BACKUP_DIR" "$SESSION_BACKUP_DIR" "$LOGIN_SESSION_BACKUP_DIR"
}

ts() {
  date +%Y%m%d-%H%M%S
}

require_file() {
  local file="$1"
  local label="${2:-File}"
  if [[ ! -f "$file" ]]; then
    echo "[ERROR] $label not found: $file" >&2
    exit 1
  fi
}

validate_profile_name() {
  local name="$1"
  if [[ ! "$name" =~ ^[a-zA-Z0-9._-]+$ ]]; then
    echo "[ERROR] Invalid profile name: $name" >&2
    echo "        Allowed: letters, numbers, dot, underscore, hyphen" >&2
    exit 1
  fi
}

profile_path() {
  local name="$1"
  echo "$PROFILE_DIR/$name.auth-profiles.json"
}

node_json() {
  node - "$@"
}

have_openclaw() {
  command -v openclaw >/dev/null 2>&1
}

stop_gateway() {
  if have_openclaw; then
    openclaw gateway stop || true
  else
    echo "[WARN] openclaw command not found; skip stopping gateway"
  fi
}

start_gateway() {
  if have_openclaw; then
    openclaw gateway start || true
  else
    echo "[WARN] openclaw command not found; skip starting gateway"
  fi
}

show_channels_status() {
  if have_openclaw; then
    openclaw channels list --json || true
  else
    echo "[WARN] openclaw command not found; skip status check"
  fi
}

backup_sessions_if_present() {
  local dest="$1"
  if [[ -d "$SESSIONS_DIR" ]]; then
    cp -a "$SESSIONS_DIR" "$dest" 2>/dev/null || true
  fi
}

clear_sessions_if_present() {
  if [[ -d "$SESSIONS_DIR" ]]; then
    rm -f "$SESSIONS_DIR"/*.jsonl
    rm -f "$SESSIONS_DIR"/sessions.json
  fi
}

print_login_instructions() {
  local new_name="${1:-<new-profile-name>}"
  cat <<EOF
Next steps (manual OAuth step required):
  1) openclaw gateway start
  2) openclaw models auth login --provider openai-codex
  3) Use an incognito/private window or a fresh browser profile
  4) Log in to the NEW OpenAI account you want to save
  5) After login succeeds, run:
     bash scripts/save-logged-in-snapshot.sh $new_name

If you want guided mode, come back and run:
  bash scripts/menu.sh
Then choose: “Resume after browser login”.
EOF
}
