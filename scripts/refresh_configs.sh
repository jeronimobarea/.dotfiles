#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)
TARGET_DIR=${TARGET_DIR:-$HOME}

# Refresh dotfiles by restowing modules or falling back to manual linking.

declare -a default_modules=()

discover_default_modules() {
  default_modules=()
  local module_path module_name has_dotfiles
  while IFS= read -r module_path; do
    module_name=${module_path##*/}
    has_dotfiles=0
    while IFS= read -r -d '' _; do
      has_dotfiles=1
      break
    done < <(find "$module_path" -mindepth 1 -maxdepth 1 -name ".*" ! -name "." ! -name ".." -print0)
    if (( has_dotfiles )); then
      default_modules+=("$module_name")
    fi
  done < <(find "$ROOT_DIR" -mindepth 1 -maxdepth 1 -type d ! -name ".*" | sort)
}

manual_link_module() {
  local module="$1"
  local module_path="$ROOT_DIR/$module"
  local rel dest first_component existing

  while IFS= read -r -d '' src; do
    rel=${src#"$module_path/"}
    [[ -n "$rel" ]] || continue
    first_component=${rel%%/*}
    [[ $first_component == .* ]] || continue
    case "$first_component" in
      .git|.gitignore|.gitmodules|.gitattributes)
        continue
        ;;
    esac
    dest="$TARGET_DIR/$rel"
    mkdir -p "$(dirname "$dest")"
    if [[ -L "$dest" ]]; then
      existing=$(readlink "$dest")
      if [[ "$existing" == "$src" ]]; then
        continue
      fi
      rm "$dest"
    elif [[ -e "$dest" ]]; then
      echo "Skipping $dest (exists and is not a symlink)" >&2
      continue
    fi
    ln -s "$src" "$dest"
    echo "Linked $dest -> $src"
  done < <(find "$module_path" -mindepth 1 \( -type f -o -type l \) -print0)
}

main() {
  local -a modules=()

  if (( $# > 0 )); then
    modules=("$@")
  elif [[ -n "${DOTFILES_MODULES:-}" ]]; then
    read -r -a modules <<<"$DOTFILES_MODULES"
  else
    discover_default_modules
    modules=("${default_modules[@]}")
  fi

  if (( ${#modules[@]} == 0 )); then
    echo "No modules to refresh" >&2
    exit 0
  fi

  for module in "${modules[@]}"; do
    if [[ ! -d "$ROOT_DIR/$module" ]]; then
      echo "Module '$module' not found under $ROOT_DIR" >&2
      exit 1
    fi
  done

  if command -v stow >/dev/null 2>&1; then
    echo "Refreshing configs with GNU stow into $TARGET_DIR"
    for module in "${modules[@]}"; do
      echo "  • $module"
      stow --dir "$ROOT_DIR" --target "$TARGET_DIR" --restow "$module"
    done
  else
    echo "GNU stow not found; linking files manually." >&2
    for module in "${modules[@]}"; do
      echo "Linking module $module"
      manual_link_module "$module"
    done
  fi
}

main "$@"
