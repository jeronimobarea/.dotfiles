#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd -P)
BREWFILE="$ROOT_DIR/Brewfile"
BREW_INSTALL_URL="https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh"

ensure_brew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  echo "Homebrew not found. Installing..."
  NONINTERACTIVE=1 CI=1 /bin/bash -c "$(curl -fsSL $BREW_INSTALL_URL)"

  # shellcheck disable=SC1091
  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

main() {
  if [[ ! -f $BREWFILE ]]; then
    echo "Brewfile not found at $BREWFILE" >&2
    exit 1
  fi

  ensure_brew

  if ! command -v brew >/dev/null 2>&1; then
    echo "brew command still missing after attempted install" >&2
    exit 1
  fi

  echo "Installing dependencies from Brewfile..."
  brew update
  brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
  brew bundle --file "$BREWFILE" --no-lock
  echo "All dependencies installed."
}

main "$@"
