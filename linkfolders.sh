#! /bin/sh
if [[ -z $STOW_FOLDERS ]]; then
    STOW_FOLDERS="yabai,nvim,alacritty,spacebar,skhd,tmux,zsh"
fi

if [[ -z $DOTFILES ]]; then
    DOTFILES=~/.dotfiles
fi

STOW_FOLDERS=$STOW_FOLDERS DOTFILES=$DOTFILES $DOTFILES/linkfolders.shlinkfolders.shlinkfolders.shlinkfolders.sh


