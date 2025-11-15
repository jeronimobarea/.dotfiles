#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "$0")/.." && pwd -P)
FRAGMENTS_DIR="$ROOT_DIR/helix/config.d"
OUTPUT_FILE="$ROOT_DIR/helix/.config/helix/config.toml"

if [[ ! -d $FRAGMENTS_DIR ]]; then
  echo "Fragments directory $FRAGMENTS_DIR not found" >&2
  exit 1
fi

{
  echo "# FILE GENERATED FROM helix/config.d -- DO NOT EDIT"
  echo
  for fragment in "$FRAGMENTS_DIR"/*.toml; do
    cat "$fragment"
    echo
  done
} > "$OUTPUT_FILE"
