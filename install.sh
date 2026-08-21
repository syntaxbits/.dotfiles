#!/usr/bin/env bash
set -e

HOST="${1:-myMachine}"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HW_FILE="$DOTFILES_DIR/modules/hosts/$HOST/hardware.nix"

echo "==> Checking partition UUIDs..."
if [ -f "$HW_FILE" ]; then
  ROOT_UUID=$(findmnt -n -o UUID /)
  BOOT_UUID=$(findmnt -n -o UUID /boot)

  if [ -n "$ROOT_UUID" ] && [ -n "$BOOT_UUID" ]; then
    echo "==> Updating UUIDs in $HW_FILE (Root: $ROOT_UUID | Boot: $BOOT_UUID)..."
    sed -i -E '/fileSystems\."\/"/,/};/ s/by-uuid\/[A-Za-z0-9-]+/by-uuid\/'"$ROOT_UUID"'/' "$HW_FILE"
    sed -i -E '/fileSystems\."\/boot"/,/};/ s/by-uuid\/[A-Za-z0-9-]+/by-uuid\/'"$BOOT_UUID"'/' "$HW_FILE"
  fi
fi

cd "$DOTFILES_DIR"

# Nix flakes require all tracked files to be added to Git
if command -v git &> /dev/null && [ -d .git ]; then
  echo "==> Staging files in Git..."
  git add .
fi

echo "==> Deploying NixOS configuration for host: $HOST"
sudo nixos-rebuild switch --flake ".#$HOST"

echo "==> System updated successfully!"