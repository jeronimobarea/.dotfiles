#!/usr/bin/env bash
# Hook script: fires a macOS banner via terminal-notifier and rings the
# originating tmux window so you can find the right pane fast.
#
# Hooks call this with a JSON payload on stdin and the hook event name
# either as $1 or via the $CLAUDE_HOOK_EVENT env var (Claude Code passes both
# in newer versions; we accept either).

set -euo pipefail

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

event="${1:-${CLAUDE_HOOK_EVENT:-Notification}}"
input="$(cat || true)"

# Extract a useful summary from the event payload.
get() { printf '%s' "$input" | jq -r "$1 // empty" 2>/dev/null; }

cwd="$(get '.cwd // .workspace.current_dir')"
project="$(basename "${cwd:-claude}")"
[[ -z $project ]] && project="claude"

# Derive tmux session + window names from the originating pane (set by Claude Code).
session=""
window=""
if [[ -n "${TMUX_PANE:-}" ]] && command -v tmux >/dev/null 2>&1; then
  session="$(tmux display-message -p -t "$TMUX_PANE" '#S' 2>/dev/null || true)"
  window="$(tmux display-message -p -t "$TMUX_PANE" '#W' 2>/dev/null || true)"
fi

# Build a "session:window" location string when available.
location=""
if [[ -n $session && -n $window ]]; then
  location="${session}:${window}"
elif [[ -n $session ]]; then
  location="$session"
elif [[ -n $window ]]; then
  location="$window"
fi

# Title shows the precise tmux address; fall back to project name.
if [[ -n $location ]]; then
  title="Claude · $location"
else
  title="Claude · $project"
fi

case "$event" in
  Notification)
    msg="$(get '.message')"
    [[ -z $msg ]] && msg="Claude needs your input"
    subtitle="needs approval · $project"
    ;;
  Stop)
    msg="Done — awaiting your next message"
    subtitle="idle · $project"
    ;;
  SubagentStop)
    msg="Subagent finished"
    subtitle="subagent done · $project"
    ;;
  *)
    msg="$event"
    subtitle="$project"
    ;;
esac

# Group key uses session+window so a noisy session doesn't smash unrelated ones.
group_key="claude-${location:-$project}"

if command -v terminal-notifier >/dev/null 2>&1; then
  terminal-notifier \
    -title "$title" \
    -subtitle "$subtitle" \
    -message "$msg" \
    -group "$group_key" \
    -sender com.googlecode.iterm2 \
    >/dev/null 2>&1 || true
fi

# Ring the originating tmux window so it lights up in the status bar.
# We only know which pane fired this if the script was launched from inside
# tmux — Claude Code preserves $TMUX_PANE in the hook environment.
if [[ -n "${TMUX_PANE:-}" ]] && command -v tmux >/dev/null 2>&1; then
  # Bell the pane (window-monitor-bell will highlight it in the status bar).
  printf '\a' > "/dev/$(tmux display-message -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null | sed 's|^/dev/||')" 2>/dev/null || true
fi

exit 0
