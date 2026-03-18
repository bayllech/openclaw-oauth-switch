#!/usr/bin/env bash
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

if [[ ! -d "$PROFILE_DIR" ]]; then
  echo "[INFO] Profiles directory not found: $PROFILE_DIR"
  exit 0
fi

found=0
while IFS= read -r -d '' file; do
  found=1
  base="$(basename "$file")"
  echo "${base%.auth-profiles.json}"
done < <(find "$PROFILE_DIR" -maxdepth 1 -type f -name '*.auth-profiles.json' -print0 | sort -z)

if [[ $found -eq 0 ]]; then
  echo "[INFO] No saved profiles yet."
fi
