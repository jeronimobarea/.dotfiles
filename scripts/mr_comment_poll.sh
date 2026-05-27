#!/usr/bin/env bash
# Poll GitLab for new unresolved discussions on MRs I authored.
#
# Fires a clickable terminal-notifier banner when any of my open MRs accumulates
# new unresolved threads since the last poll. Debounced per-MR so a single
# review session doesn't spam — we only notify when the unresolved count
# *increases* relative to the last seen state.
#
# Designed to be invoked by launchd; safe to run by hand.

set -euo pipefail

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

HOST="${GITLAB_HOST:-gitlab.thunes.com}"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/mr-comment-poll"
STATE_FILE="$STATE_DIR/${HOST}.state"
mkdir -p "$STATE_DIR"

log() { echo "$(date -Iseconds) $*"; }

if ! command -v glab >/dev/null 2>&1; then
  log "glab not installed; nothing to do"
  exit 0
fi

# If glab is not authed for our host, exit silently — auth surfaces elsewhere.
if ! glab auth status --hostname "$HOST" >/dev/null 2>&1; then
  log "glab not authenticated for $HOST"
  exit 0
fi

# 1. List my open MRs.
mrs_json=$(glab api --hostname "$HOST" \
  'merge_requests?scope=created_by_me&state=opened&per_page=50' 2>/dev/null) || {
  log "failed to list MRs"
  exit 0
}

if [[ -z $mrs_json || $mrs_json == "[]" ]]; then
  log "no open MRs"
  : > "$STATE_FILE"
  exit 0
fi

# 2. Build new state: project_id|iid|unresolved_count for each MR.
# Skip Draft MRs — Drafts aren't ready for review, so reviewer comments there
# are usually self-notes or work-in-progress and shouldn't ping us.
new_state_file=$(mktemp)
trap 'rm -f "$new_state_file"' EXIT

while IFS= read -r mr; do
  pid=$(jq -r '.project_id' <<<"$mr")
  iid=$(jq -r '.iid' <<<"$mr")
  title=$(jq -r '.title' <<<"$mr")
  url=$(jq -r '.web_url' <<<"$mr")

  # Drafts: title starts with "Draft:" or has draft flag set.
  if [[ $title == Draft:* ]]; then
    continue
  fi

  # Count unresolved discussions: a thread is unresolved if any note in it
  # has resolvable=true and resolved=false. Excludes system notes.
  discussions=$(glab api --hostname "$HOST" \
    "projects/${pid}/merge_requests/${iid}/discussions?per_page=100" 2>/dev/null) || continue

  unresolved=$(jq -r '
    [.[] | select(.notes | any(.resolvable == true and .resolved == false))
         | select(.notes | all(.system == true) | not)]
    | length
  ' <<<"$discussions" 2>/dev/null) || unresolved=0
  [[ -z $unresolved ]] && unresolved=0

  printf '%s|%s|%s|%s|%s\n' "$pid" "$iid" "$unresolved" "$url" "$title" >>"$new_state_file"
done < <(jq -c '.[]' <<<"$mrs_json")

# 3. Compare against previous state. Notify on each MR whose unresolved count
# strictly increased.
prev_unresolved_for() {
  local pid="$1" iid="$2"
  [[ -r $STATE_FILE ]] || { echo 0; return; }
  awk -F'|' -v p="$pid" -v i="$iid" \
    '$1 == p && $2 == i { print $3; found=1; exit } END { if (!found) print 0 }' \
    "$STATE_FILE"
}

notify_mr() {
  local title="$1" url="$2" delta="$3" total="$4"
  local subtitle="MR has new feedback"
  local message="+${delta} unresolved (${total} total) — ${title}"
  if command -v terminal-notifier >/dev/null 2>&1; then
    terminal-notifier -title "GitLab MR review" -subtitle "$subtitle" \
      -message "$message" -open "$url" -sound default \
      -group "mr-${url}" >/dev/null 2>&1 || true
  fi
  log "notified: $url (+$delta, total $total)"
}

while IFS='|' read -r pid iid unresolved url title; do
  [[ -z $pid || -z $iid ]] && continue
  prev=$(prev_unresolved_for "$pid" "$iid")
  if (( unresolved > prev )); then
    delta=$(( unresolved - prev ))
    notify_mr "$title" "$url" "$delta" "$unresolved"
  fi
done <"$new_state_file"

# 4. Persist new state.
mv -f "$new_state_file" "$STATE_FILE"
trap - EXIT

exit 0
