# External integrations

[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

opam_init="$HOME/.opam/opam-init/init.zsh"
[[ -r $opam_init ]] && source "$opam_init" > /dev/null 2> /dev/null

thunes_rc="$DOTFILES_ROOT/thunes/.zshrc"
[[ -r $thunes_rc ]] && source "$thunes_rc"

[[ -f "$HOME/.local/bin/env" ]] && source "$HOME/.local/bin/env"

if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi
