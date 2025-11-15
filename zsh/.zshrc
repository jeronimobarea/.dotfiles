# shellcheck shell=zsh
typeset -g DOTFILES_ROOT="${DOTFILES_ROOT:-$HOME/.dotfiles}"
typeset -g ZSH_DOTFILES_DIR="${ZSH_DOTFILES_DIR:-$DOTFILES_ROOT/zsh}"

typeset -a ZSH_DOTFILES_MODULES=(
  "00-env"
  "10-aliases"
  "20-functions"
  "30-ohmyzsh"
  "40-extras"
)

for module in "${ZSH_DOTFILES_MODULES[@]}"; do
  module_file="$ZSH_DOTFILES_DIR/lib/${module}.zsh"
  [[ -r "$module_file" ]] && source "$module_file"
done

unset module module_file
