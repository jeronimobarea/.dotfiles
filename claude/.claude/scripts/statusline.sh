#!/usr/bin/env bash
# Claude Code status line: project · model · branch · cwd · cost · session-time
# Reads JSON context from stdin (Claude Code passes session info there).

set -euo pipefail

PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

input="$(cat || true)"

extract() {
  local key="$1"
  printf '%s' "$input" | jq -r --arg k "$key" '.[$k] // empty' 2>/dev/null
}
extract_nested() {
  local path="$1"
  printf '%s' "$input" | jq -r "$path // empty" 2>/dev/null
}

cwd="$(extract_nested '.workspace.current_dir // .cwd')"
[[ -z $cwd ]] && cwd="$PWD"

project="$(basename "$cwd")"

model="$(extract_nested '.model.display_name // .model.id')"
[[ -z $model ]] && model="?"
model="${model#global.anthropic.}"
model="${model#claude-}"

if branch="$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)"; then
  :
elif branch="$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)"; then
  branch="@${branch}"
else
  branch="-"
fi

cost_raw="$(extract_nested '.cost.total_cost_usd // .cost')"
if [[ -n $cost_raw && $cost_raw != null ]]; then
  cost="\$$(printf '%.2f' "$cost_raw" 2>/dev/null || echo "$cost_raw")"
else
  cost="-"
fi

duration_ms="$(extract_nested '.cost.total_duration_ms // .session.duration_ms')"
if [[ -n $duration_ms && $duration_ms != null ]]; then
  total_s=$(( duration_ms / 1000 ))
  hours=$(( total_s / 3600 ))
  mins=$(( (total_s % 3600) / 60 ))
  if (( hours > 0 )); then
    elapsed="${hours}h${mins}m"
  else
    elapsed="${mins}m"
  fi
else
  elapsed="-"
fi

short_cwd="${cwd/#$HOME/~}"

printf '%s · %s · %s · %s · %s · %s' \
  "$project" "$model" "$branch" "$short_cwd" "$cost" "$elapsed"
