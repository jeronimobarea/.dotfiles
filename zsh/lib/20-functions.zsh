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
