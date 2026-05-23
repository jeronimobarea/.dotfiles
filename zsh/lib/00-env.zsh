# Environment and PATH configuration

DISABLE_LS_COLORS="true"
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

# Ensure Homebrew is on PATH (covers tmux servers started before brew was loaded).
for brew_prefix in /opt/homebrew /usr/local; do
  if [[ -x "$brew_prefix/bin/brew" && :$PATH: != *":$brew_prefix/bin:"* ]]; then
    eval "$($brew_prefix/bin/brew shellenv)"
    break
  fi
done
unset brew_prefix

if command -v go >/dev/null 2>&1; then
  export GOPATH="${GOPATH:-$HOME/go}"
  if [[ :$PATH: != *":$GOPATH/bin:"* ]]; then
    export PATH="$PATH:$GOPATH/bin"
  fi
fi

solana_bin="$HOME/.local/share/solana/install/active_release/bin"
if [[ -d $solana_bin && :$PATH: != *":$solana_bin:"* ]]; then
  export PATH="$solana_bin:$PATH"
fi
