#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="${HOME}/dotfiles"
PACKAGES_FILE="${DOTFILES_DIR}/packages.txt"

STOW_PACKAGES=(
  i3
  picom
  polybar
  rofi
  alacritty
  scripts
  wallpapers
  tmux
  bash
)

if [[ ! -f "$PACKAGES_FILE" ]]; then
  echo "Package file not found: $PACKAGES_FILE"
  exit 1
fi

echo "Updating package lists..."
sudo apt update

echo "Installing packages from $PACKAGES_FILE ..."
sudo xargs -a "$PACKAGES_FILE" apt install -y

echo "Applying dotfiles with stow..."
cd "$DOTFILES_DIR"

for pkg in "${STOW_PACKAGES[@]}"; do
  if [[ -d "$pkg" ]]; then
    stow "$pkg"
  else
    echo "Skipping missing stow package: $pkg"
  fi
done

echo "Done."
echo "Log out and back in to make sure everything is fully applied."
