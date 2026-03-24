#!/usr/bin/env bash
# install.sh — Symlink sandbox scripts into ~/.local/bin
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/.local/bin"

mkdir -p "$BIN_DIR"

LINKS=(
  "sandbox/cc-sandbox.sh:cc-sandbox"
  "sandbox/cc-manage.sh:cc-manage"
)

for entry in "${LINKS[@]}"; do
  src="$SCRIPT_DIR/${entry%%:*}"
  dest="$BIN_DIR/${entry##*:}"

  if [[ -L "$dest" ]]; then
    rm "$dest"
  elif [[ -e "$dest" ]]; then
    echo "WARNING: $dest exists and is not a symlink, skipping"
    continue
  fi

  ln -s "$src" "$dest"
  echo "Linked $dest -> $src"
done

echo "Done. Make sure ~/.local/bin is on your PATH."
