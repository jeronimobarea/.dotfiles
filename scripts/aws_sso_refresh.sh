#!/usr/bin/env bash
# Proactive SSO expiry notification.
#
# AWS SSO tokens require interactive OIDC — there is no truly headless refresh.
# Instead of being interrupted mid-conversation when the token expires, this
# script reads the cached token's `expiresAt` field and fires a desktop
# notification when expiry is approaching, so the user can run claude-login at
# a natural break.
#
# Behavior:
#   - If token is missing or already expired -> "Expired" notification
#   - If token expires in < WARN_MINUTES (default 30) -> "Expiring soon"
#   - Otherwise: silent no-op
#
# A small state file under ~/.cache/ debounces repeat notifications so launchd
# can run this every few minutes without spamming.

set -euo pipefail

PROFILE="${1:-aws-claude-code}"
WARN_MINUTES="${AWS_SSO_WARN_MINUTES:-30}"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/aws-sso-refresh"
STATE_FILE="$STATE_DIR/${PROFILE}.last-notified"
mkdir -p "$STATE_DIR"

log() { echo "$(date -Iseconds) [$PROFILE] $*"; }

notify() {
  local title="$1" message="$2"
  if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "AWS SSO" -subtitle "$title" -message "$message" \
      -sound default -group "aws-sso-${PROFILE}" >/dev/null 2>&1 || true
  fi
  log "$title — $message"
}

# Look up the sso_start_url for the requested profile by reading ~/.aws/config.
# The config has [profile X] -> sso_session -> [sso-session X] -> sso_start_url.
read_start_url() {
  local config="$HOME/.aws/config" profile="$1"
  [[ -r $config ]] || return 1

  local session
  session=$(awk -v p="$profile" '
    $0 == "[profile " p "]" { in_profile=1; next }
    /^\[/ { in_profile=0 }
    in_profile && $1 == "sso_session" && $2 == "=" { print $3; exit }
  ' "$config")

  [[ -n $session ]] || return 1

  awk -v s="$session" '
    $0 == "[sso-session " s "]" { in_session=1; next }
    /^\[/ { in_session=0 }
    in_session && $1 == "sso_start_url" && $2 == "=" { print $3; exit }
  ' "$config"
}

# Strip trailing `#/` and trailing slashes for stable comparison against the
# value stored inside the cache JSON.
normalize_url() {
  local url="$1"
  url="${url%#/}"
  url="${url%/}"
  print -r -- "$url" 2>/dev/null || printf '%s' "$url"
}

START_URL=$(read_start_url "$PROFILE" || true)
if [[ -z ${START_URL:-} ]]; then
  log "no sso_start_url found for profile; nothing to do"
  exit 0
fi
START_URL_NORM=$(normalize_url "$START_URL")

# Find the cache file whose startUrl matches our profile's sso session.
TOKEN_FILE=""
for f in "$HOME"/.aws/sso/cache/*.json; do
  [[ -r $f ]] || continue
  cached=$(jq -r '.startUrl // empty' "$f" 2>/dev/null)
  cached_norm="${cached%#/}"
  cached_norm="${cached_norm%/}"
  if [[ $cached_norm == "$START_URL_NORM" ]]; then
    # Prefer the most recently written matching file.
    if [[ -z $TOKEN_FILE || $f -nt $TOKEN_FILE ]]; then
      TOKEN_FILE=$f
    fi
  fi
done

if [[ -z $TOKEN_FILE ]]; then
  notify "Expired" "No cached SSO token. Run claude-login."
  date +%s > "$STATE_FILE"
  exit 0
fi

EXPIRES_AT=$(jq -r '.expiresAt // empty' "$TOKEN_FILE" 2>/dev/null)
if [[ -z $EXPIRES_AT ]]; then
  notify "Unknown" "Cached token has no expiresAt. Run claude-login."
  date +%s > "$STATE_FILE"
  exit 0
fi

# `expiresAt` is RFC3339 with Z. macOS `date -j` can parse it after stripping
# fractional seconds and trailing Z.
clean=${EXPIRES_AT%Z}
clean=${clean%.*}
EXPIRES_EPOCH=$(date -j -f '%Y-%m-%dT%H:%M:%S' "$clean" +%s 2>/dev/null || echo 0)

if (( EXPIRES_EPOCH == 0 )); then
  log "could not parse expiresAt=$EXPIRES_AT"
  exit 0
fi

NOW_EPOCH=$(date +%s)
REMAINING=$(( EXPIRES_EPOCH - NOW_EPOCH ))
REMAINING_MIN=$(( REMAINING / 60 ))

# Debounce: only re-notify once per 4h for the same profile, so launchd can
# run frequently without producing duplicate alerts.
LAST_NOTIFIED=0
[[ -r $STATE_FILE ]] && LAST_NOTIFIED=$(cat "$STATE_FILE" 2>/dev/null || echo 0)
SINCE_LAST=$(( NOW_EPOCH - LAST_NOTIFIED ))
DEBOUNCE_SECONDS=$(( 4 * 3600 ))

if (( REMAINING <= 0 )); then
  if (( SINCE_LAST > 600 )); then  # expired -> nudge every 10 min until acted on
    notify "Expired" "SSO token expired. Run claude-login to refresh."
    date +%s > "$STATE_FILE"
  fi
elif (( REMAINING_MIN < WARN_MINUTES )); then
  if (( SINCE_LAST > DEBOUNCE_SECONDS )); then
    notify "Expiring soon" "SSO token expires in ${REMAINING_MIN}m. Run claude-login at a break."
    date +%s > "$STATE_FILE"
  fi
fi

exit 0
