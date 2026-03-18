#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

ensure_dirs

if [[ ! -d "$OPENCLAW_AGENT_DIR" ]]; then
  echo "[WARN] OpenClaw agent directory not found: $OPENCLAW_AGENT_DIR"
else
  echo "[OK] OpenClaw agent directory: $OPENCLAW_AGENT_DIR"
fi

if [[ -f "$TARGET_FILE" ]]; then
  echo "[OK] Found target auth file: $TARGET_FILE"
else
  echo "[WARN] Target auth file not found yet: $TARGET_FILE"
  echo "       You may need to log in first, then run this script again."
fi

cat > "$PROFILE_DIR/.gitignore" <<'EOF'
*.auth-profiles.json
!*.example
!README.md
EOF

cat > "$PROJECT_DIR/.gitignore" <<'EOF'
profiles/*.auth-profiles.json
backups/
state/
EOF

echo "[DONE] Project initialized."
echo "       Profiles dir: $PROFILE_DIR"
echo "       Backups dir : $BACKUP_DIR"
echo "       State dir   : $STATE_DIR"
