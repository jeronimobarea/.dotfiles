# Interactive helpers

fzf() {
  local selection target_dir target_entry

  selection=$(command fzf --style full \
    --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}') || return $?

  [[ -z $selection ]] && return 0

  if [[ -d $selection ]]; then
    target_dir=$selection
    target_entry='.'
  else
    target_dir=${selection:h}
    target_entry=${selection:t}
  fi

  [[ -n $target_dir ]] && builtin cd -- "$target_dir"
  _fzf_spawn_tmux_helpers "$PWD"

  if [[ $target_entry == '.' ]]; then
    hx .
  else
    hx "$target_entry"
  fi
}

_fzf_spawn_tmux_helpers() {
  local dir="$1" ai_cmd shell_cmd
  [[ -n ${TMUX:-} ]] || return
  command -v tmux >/dev/null 2>&1 || return

  if command -v codex >/dev/null 2>&1; then
    ai_cmd=codex
  elif command -v gemini >/dev/null 2>&1; then
    ai_cmd=gemini
  fi

  if [[ -n $ai_cmd ]]; then
    tmux new-window -c "$dir" -n "ai" "$ai_cmd"
  fi

  shell_cmd="${SHELL:-/bin/zsh}"
  tmux new-window -c "$dir" -n "dev" "$shell_cmd"

  if command -v lazygit >/dev/null 2>&1; then
    tmux new-window -c "$dir" -n "git" lazygit
  fi
}

project() {
  local root selection
  root="${PROJECTS_ROOT:-$HOME/code}"
  if [[ ! -d $root ]]; then
    echo "Project root '$root' not found" >&2
    return 1
  fi
  selection=$(command find "$root" -mindepth 1 -maxdepth 1 -type d -print | sort | command fzf --prompt 'project> ' --height=40%) || return $?
  [[ -z $selection ]] && return 0
  builtin cd -- "$selection" && hx .
}

if [[ -o interactive ]]; then
  bindkey -s '^P' 'fzf\n'
fi

# Resolve a binary by absolute path, bypassing zsh's stale command hash.
_resolve_bin() {
  local name="$1" prefix
  for prefix in /opt/homebrew /usr/local "$HOME/.local"; do
    if [[ -x "$prefix/bin/$name" ]]; then
      print -r -- "$prefix/bin/$name"
      return 0
    fi
  done
  rehash
  command -v "$name" 2>/dev/null
}

claude-login() {
  local profile="${1:-${AWS_PROFILE:-aws-claude-code}}"
  local aws_bin
  aws_bin="$(_resolve_bin aws)"
  if [[ -z $aws_bin ]]; then
    echo "aws CLI not found. Install with: brew install awscli" >&2
    return 127
  fi
  "$aws_bin" sso login --profile "$profile"
}

# tmux session naming is strict: replace dots/colons with dashes.
_workspace_session_name() {
  print -r -- "${1//[.:]/-}"
}

# Push Claude/AWS env vars into tmux's global environment so every new window inherits them.
_workspace_propagate_env() {
  local tmux_bin="$1"
  local var
  for var in CLAUDE_CODE_USE_BEDROCK ANTHROPIC_MODEL ANTHROPIC_SMALL_FAST_MODEL \
             CLAUDE_CODE_MAX_OUTPUT_TOKENS MAX_THINKING_TOKENS AWS_PROFILE; do
    if [[ -n ${(P)var-} ]]; then
      "$tmux_bin" set-environment -g "$var" "${(P)var}"
    fi
  done
}

# Wrap a command so the window survives the command exiting (drop to shell).
_workspace_persistent_cmd() {
  local cmd="$1"
  printf '%s; exec %s -l\n' "$cmd" "${SHELL:-/bin/zsh}"
}

# Build the standard window set for a single project inside an existing session.
_workspace_build_session() {
  local tmux_bin="$1" session="$2" project_path="$3" repos_root="$4"
  local shell_cmd="${SHELL:-/bin/zsh}"
  local lazygit_bin
  lazygit_bin="$(_resolve_bin lazygit)"

  "$tmux_bin" new-session -d -s "$session" -c "$repos_root"   -n "claude-root" \
    "$(_workspace_persistent_cmd claude)"
  "$tmux_bin" new-window  -t "$session" -c "$project_path" -n "claude" \
    "$(_workspace_persistent_cmd claude)"
  "$tmux_bin" new-window  -t "$session" -c "$project_path" -n "edit" \
    "$(_workspace_persistent_cmd 'hx .')"
  "$tmux_bin" new-window  -t "$session" -c "$project_path" -n "shell" "$shell_cmd"
  if [[ -n $lazygit_bin ]]; then
    "$tmux_bin" new-window -t "$session" -c "$project_path" -n "git" \
      "$(_workspace_persistent_cmd "$lazygit_bin")"
  fi
  "$tmux_bin" select-window -t "${session}:claude-root"
}

workspace() {
  if (( $# == 0 )); then
    echo "Usage: workspace <project> [project...]" >&2
    return 1
  fi

  local root="${PROJECTS_ROOT:-$HOME/code}"
  if [[ ! -d $root ]]; then
    echo "Project root '$root' not found" >&2
    return 1
  fi

  local tmux_bin
  tmux_bin="$(_resolve_bin tmux)"
  if [[ -z $tmux_bin ]]; then
    echo "tmux not installed" >&2
    return 1
  fi

  local -a project_paths
  local arg path
  for arg in "$@"; do
    if [[ $arg == /* || $arg == ~* ]]; then
      path="${arg/#\~/$HOME}"
    else
      path="$root/$arg"
    fi
    if [[ ! -d $path ]]; then
      echo "Project '$arg' not found at $path" >&2
      return 1
    fi
    project_paths+=("$path")
  done

  claude-login || return $?

  _workspace_propagate_env "$tmux_bin"

  local p session first_session
  for p in "${project_paths[@]}"; do
    session="$(_workspace_session_name "${p:t}")"
    if ! "$tmux_bin" has-session -t "=$session" 2>/dev/null; then
      _workspace_build_session "$tmux_bin" "$session" "$p" "$root"
    fi
    [[ -z $first_session ]] && first_session="$session"
  done

  if [[ -n ${TMUX:-} ]]; then
    local origin_session
    origin_session="$("$tmux_bin" display-message -p '#S')"
    "$tmux_bin" switch-client -t "$first_session"
    if [[ -n $origin_session && $origin_session != $first_session ]]; then
      local -a project_sessions
      project_sessions=()
      for p in "${project_paths[@]}"; do
        project_sessions+=("$(_workspace_session_name "${p:t}")")
      done
      if [[ ${project_sessions[(ie)$origin_session]} -gt ${#project_sessions} ]]; then
        "$tmux_bin" kill-session -t "$origin_session" 2>/dev/null
      fi
    fi
  else
    "$tmux_bin" attach-session -t "$first_session"
  fi
}

# One-click boot for the standard Thunes project set.
boot() {
  workspace payments api-gateway emulator admin-interface-ui admin-interface
}
