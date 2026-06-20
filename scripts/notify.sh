#!/usr/bin/env bash
# Notification wrapper. Posts to a Discord or Slack incoming webhook.
# Usage: bash scripts/notify.sh "<message>"
# If NOTIFY_WEBHOOK_URL is unset, appends to a local NOTIFICATIONS.md file.
# Never crashes on missing credentials (always exits 0 on the fallback path).

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ENV_FILE="$ROOT/.env"
FALLBACK="$ROOT/NOTIFICATIONS.md"

if [[ -f "$ENV_FILE" ]]; then
  set -a
  # shellcheck disable=SC1090
  source "$ENV_FILE"
  set +a
fi

if [[ $# -gt 0 ]]; then
  msg="$*"
else
  msg="$(cat)"
fi

if [[ -z "${msg// /}" ]]; then
  echo "usage: bash scripts/notify.sh \"<message>\"" >&2
  exit 1
fi

stamp="$(date '+%Y-%m-%d %H:%M %Z')"

# No webhook configured -> append to local file and exit cleanly.
if [[ -z "${NOTIFY_WEBHOOK_URL:-}" ]]; then
  printf '\n---\n## %s\n%s\n' "$stamp" "$msg" >> "$FALLBACK"
  echo "[notify fallback] appended to NOTIFICATIONS.md"
  echo "$msg"
  exit 0
fi

# discord (default) or slack
TYPE="${NOTIFY_WEBHOOK_TYPE:-discord}"
if [[ "$TYPE" == "slack" ]]; then
  field="text"
else
  field="content"
fi

payload="$(python3 -c "
import json, sys
print(json.dumps({sys.argv[1]: sys.argv[2]}))
" "$field" "$msg")"

curl -fsS -X POST "$NOTIFY_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d "$payload"
echo
