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
             ANTHROPIC_BETAS CLAUDE_CODE_MAX_OUTPUT_TOKENS MAX_THINKING_TOKENS \
             AWS_PROFILE; do
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
  local tmux_bin="$1" session="$2" project_path="$3"
  local shell_cmd="${SHELL:-/bin/zsh}"
  local lazygit_bin
  lazygit_bin="$(_resolve_bin lazygit)"

  "$tmux_bin" new-session -d -s "$session" -c "$project_path" -n "claude" \
    "$(_workspace_persistent_cmd claude)"
  "$tmux_bin" new-window  -t "$session" -c "$project_path" -n "edit" \
    "$(_workspace_persistent_cmd 'hx .')"
  "$tmux_bin" new-window  -t "$session" -c "$project_path" -n "shell" "$shell_cmd"
  if [[ -n $lazygit_bin ]]; then
    "$tmux_bin" new-window -t "$session" -c "$project_path" -n "git" \
      "$(_workspace_persistent_cmd "$lazygit_bin")"
  fi
  "$tmux_bin" select-window -t "${session}:claude"
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

  local p i session first_session
  i=1
  for p in "${project_paths[@]}"; do
    session="${i}-$(_workspace_session_name "${p:t}")"
    if ! "$tmux_bin" has-session -t "=$session" 2>/dev/null; then
      _workspace_build_session "$tmux_bin" "$session" "$p"
    fi
    [[ -z $first_session ]] && first_session="$session"
    (( i++ ))
  done

  if [[ -n ${TMUX:-} ]]; then
    local origin_session
    origin_session="$("$tmux_bin" display-message -p '#S')"
    "$tmux_bin" switch-client -t "$first_session"
    if [[ -n $origin_session && $origin_session != $first_session ]]; then
      local -a project_sessions
      project_sessions=()
      i=1
      for p in "${project_paths[@]}"; do
        project_sessions+=("${i}-$(_workspace_session_name "${p:t}")")
        (( i++ ))
      done
      if [[ ${project_sessions[(ie)$origin_session]} -gt ${#project_sessions} ]]; then
        "$tmux_bin" kill-session -t "$origin_session" 2>/dev/null
      fi
    fi
  else
    "$tmux_bin" attach-session -t "$first_session"
  fi
}

# Repos that should lead the boot order; the rest follow alphabetically.
typeset -ga WORKSPACE_PRIORITY=(payments api-gateway)

# One-click boot: open a session per git repo under PROJECTS_ROOT.
boot() {
  local root="${PROJECTS_ROOT:-$HOME/code}"
  if [[ ! -d $root ]]; then
    echo "Project root '$root' not found" >&2
    return 1
  fi

  local -a repos
  local d
  for d in "$root"/*(N/); do
    [[ -d "$d/.git" || -f "$d/.git" ]] && repos+=("${d:t}")
  done

  if (( ${#repos} == 0 )); then
    echo "No git repos found under $root" >&2
    return 1
  fi

  local -a ordered rest
  local pinned name
  for pinned in "${WORKSPACE_PRIORITY[@]}"; do
    if (( ${repos[(Ie)$pinned]} )); then
      ordered+=("$pinned")
    fi
  done
  for name in "${repos[@]}"; do
    if (( ! ${ordered[(Ie)$name]} )); then
      rest+=("$name")
    fi
  done

  workspace "${ordered[@]}" "${rest[@]}"
}

# ---------------------------------------------------------------------------
# Fleet: a single tmux session for in-flight MR reviews and staging verifications.
# Each task gets its own window inside the `fleet` session.
# ---------------------------------------------------------------------------

_FLEET_SESSION="0-fleet"

# Sanitize an arbitrary string into a tmux-safe window name fragment.
_fleet_slug() {
  local raw="$1"
  # Strip protocol and query string from URLs, keep meaningful tail.
  raw="${raw#http://}"
  raw="${raw#https://}"
  raw="${raw%%\?*}"
  raw="${raw%/}"
  # Replace path-ish chars with dashes; cap length.
  print -r -- "${raw//[^A-Za-z0-9_-]/-}" | cut -c1-40
}

# Ensure the fleet session exists. Creates a `home` window if not.
_fleet_ensure_session() {
  local tmux_bin="$1" repos_root="$2"
  if ! "$tmux_bin" has-session -t "=$_FLEET_SESSION" 2>/dev/null; then
    "$tmux_bin" new-session -d -s "$_FLEET_SESSION" -c "$repos_root" -n "home" \
      "${SHELL:-/bin/zsh}"
    _workspace_propagate_env "$tmux_bin"
  fi
}

# Spawn a claude window in the fleet that pre-types a slash command.
_fleet_spawn() {
  local tmux_bin="$1" win_name="$2" cwd="$3" prompt="$4"
  "$tmux_bin" new-window -t "$_FLEET_SESSION" -c "$cwd" -n "$win_name" \
    "$(_workspace_persistent_cmd claude)"
  # Give claude a moment to finish startup before injecting the prompt.
  ( sleep 2 && "$tmux_bin" send-keys -t "${_FLEET_SESSION}:${win_name}" \
      "$prompt" Enter ) &!
}

fleet() {
  local tmux_bin
  tmux_bin="$(_resolve_bin tmux)"
  [[ -z $tmux_bin ]] && { echo "tmux not installed" >&2; return 1; }
  local root="${PROJECTS_ROOT:-$HOME}"

  claude-login || return $?
  _fleet_ensure_session "$tmux_bin" "$root"

  if [[ -n ${TMUX:-} ]]; then
    "$tmux_bin" switch-client -t "$_FLEET_SESSION"
  else
    "$tmux_bin" attach-session -t "$_FLEET_SESSION"
  fi
}

review() {
  if (( $# == 0 )); then
    echo "Usage: review <mr-url-or-id> [project]" >&2
    return 1
  fi
  local target="$1" project="${2:-}"
  local tmux_bin
  tmux_bin="$(_resolve_bin tmux)"
  [[ -z $tmux_bin ]] && { echo "tmux not installed" >&2; return 1; }
  local root="${PROJECTS_ROOT:-$HOME}"
  local cwd="$root"
  if [[ -n $project ]]; then
    if [[ -d "$root/$project" ]]; then
      cwd="$root/$project"
    elif [[ -d $project ]]; then
      cwd="$project"
    fi
  fi

  claude-login || return $?
  _fleet_ensure_session "$tmux_bin" "$root"

  local slug win_name
  slug="$(_fleet_slug "$target")"
  win_name="mr-${slug}"
  _fleet_spawn "$tmux_bin" "$win_name" "$cwd" "/mr-review $target"

  if [[ -n ${TMUX:-} ]]; then
    "$tmux_bin" switch-client -t "${_FLEET_SESSION}"
    "$tmux_bin" select-window -t "${_FLEET_SESSION}:${win_name}"
  else
    "$tmux_bin" attach-session -t "${_FLEET_SESSION}" \;\
      select-window -t "${_FLEET_SESSION}:${win_name}"
  fi
}

verify() {
  if (( $# == 0 )); then
    echo "Usage: verify <ticket-or-mr> [project]" >&2
    return 1
  fi
  local target="$1" project="${2:-}"
  local tmux_bin
  tmux_bin="$(_resolve_bin tmux)"
  [[ -z $tmux_bin ]] && { echo "tmux not installed" >&2; return 1; }
  local root="${PROJECTS_ROOT:-$HOME}"
  local cwd="$root"
  if [[ -n $project ]]; then
    if [[ -d "$root/$project" ]]; then
      cwd="$root/$project"
    elif [[ -d $project ]]; then
      cwd="$project"
    fi
  fi

  claude-login || return $?
  _fleet_ensure_session "$tmux_bin" "$root"

  local slug win_name
  slug="$(_fleet_slug "$target")"
  win_name="verify-${slug}"
  _fleet_spawn "$tmux_bin" "$win_name" "$cwd" "/staging-verify $target"

  if [[ -n ${TMUX:-} ]]; then
    "$tmux_bin" switch-client -t "${_FLEET_SESSION}"
    "$tmux_bin" select-window -t "${_FLEET_SESSION}:${win_name}"
  else
    "$tmux_bin" attach-session -t "${_FLEET_SESSION}" \;\
      select-window -t "${_FLEET_SESSION}:${win_name}"
  fi
}

# wt: create a sibling worktree for parallel work and cd into it.
#
# Usage:
#   wt <branch>            create new branch off origin/HEAD in ../<repo>-<branch-tail>
#   wt <branch> <base>     same, but branch off <base> instead of origin/HEAD
#
# The branch tail (everything after the last `/`) is used as the directory
# suffix to keep paths short: `wt CO-1234/fix-foo` lands in `../<repo>-fix-foo`.
wt() {
  if (( $# == 0 )); then
    echo "Usage: wt <branch> [base-ref]" >&2
    return 1
  fi

  if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    echo "wt: not in a git repository" >&2
    return 1
  fi

  local branch="$1" base="${2:-}" repo branch_tail target
  repo="$(basename "$(git rev-parse --show-toplevel)")"
  branch_tail="${branch##*/}"
  target="../${repo}-${branch_tail}"

  if [[ -z $base ]]; then
    base="$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')"
    [[ -z $base ]] && base="$(git rev-parse --abbrev-ref HEAD)"
  fi

  if [[ -d $target ]]; then
    echo "wt: $target already exists; cd-ing into it" >&2
    builtin cd -- "$target" || return $?
    return 0
  fi

  git worktree add -b "$branch" "$target" "$base" || return $?
  builtin cd -- "$target"
}
