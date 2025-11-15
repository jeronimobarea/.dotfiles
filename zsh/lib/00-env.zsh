# Environment and PATH configuration

DISABLE_LS_COLORS="true"
export ZSH="${ZSH:-$HOME/.oh-my-zsh}"

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
