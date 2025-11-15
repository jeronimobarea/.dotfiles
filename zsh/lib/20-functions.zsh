# Interactive helpers

fzf() {
  local selection selected_dir selected_name
  selection=$(command fzf --style full \
    --preview 'fzf-preview.sh {}' --bind 'focus:transform-header:file --brief {}') || return $?

  [[ -z $selection ]] && return 0

  if [[ -d $selection ]]; then
    builtin cd -- "$selection" && hx .
    return $?
  fi

  selected_dir=${selection:h}
  selected_name=${selection:t}

  [[ -n $selected_dir && $selected_dir != "$selection" ]] && builtin cd -- "$selected_dir"
  hx "$selected_name"
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
