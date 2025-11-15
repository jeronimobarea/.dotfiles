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
