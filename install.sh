#!/usr/bin/env bash
set -euo pipefail

HOST="${1:-myMachine}"
shift || true
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HW_FILE="$DOTFILES_DIR/modules/hosts/$HOST/hardware.nix"

[ -d "$DOTFILES_DIR/modules/hosts/$HOST" ] || { echo "Error: unknown host '$HOST'"; exit 1; }

if [ -f "$HW_FILE" ]; then
  ROOT_UUID=$(findmnt -n -o UUID / || true)
  BOOT_UUID=$(findmnt -n -o UUID /boot || true)
  if [ -n "$ROOT_UUID" ] && [ -n "$BOOT_UUID" ]; then
    echo "==> Updating UUIDs in $HW_FILE (Root: $ROOT_UUID | Boot: $BOOT_UUID)..."
    sed -i -E "/fileSystems\\.\"\\/\"/,/};/ s|by-uuid/[A-Za-z0-9-]+|by-uuid/$ROOT_UUID|" "$HW_FILE"
    sed -i -E "/fileSystems\\.\"\\/boot\"/,/};/ s|by-uuid/[A-Za-z0-9-]+|by-uuid/$BOOT_UUID|" "$HW_FILE"
    grep -q "by-uuid/$ROOT_UUID" "$HW_FILE" || { echo "Warning: root UUID substitution failed"; exit 1; }
  fi
else
  echo "==> Warning: $HW_FILE not found, skipping UUID sync"
fi

cd "$DOTFILES_DIR"

# Nix flakes require all tracked files to be added to Git
if command -v git &> /dev/null && [ -d .git ]; then
  echo "==> Staging files in Git..."
  git add .
fi

echo "==> Deploying NixOS configuration for host: $HOST"
sudo nixos-rebuild switch --flake ".#$HOST" "$@"

echo "==> System updated successfully!"
