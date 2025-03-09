#!/bin/bash

# Variables
DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="git@github.com:SeneAlukard/dotfiles.git"
SIMULATE=false # Set to true to simulate the setup without making changes

# Function to install a package if not already installed
install_if_missing() {
  if ! command -v "$1" &>/dev/null; then
    if [ "$SIMULATE" = false ]; then
      echo "Installing $1..."
      sudo pacman -S --needed --noconfirm "$1"
    else
      echo "Would install: $1"
    fi
  else
    echo "$1 is already installed."
  fi
}

# Function to simulate or perform an action
perform_action() {
  if [ "$SIMULATE" = false ]; then
    eval "$1"
  else
    echo "Would run: $1"
  fi
}

# Step 1: Install Essential System Tools
echo "Installing required system packages..."
install_if_missing "git"
install_if_missing "curl"
install_if_missing "unzip"
install_if_missing "xfce4"
install_if_missing "xfce4-goodies"
install_if_missing "xorg-server"
install_if_missing "xorg-xinit"
install_if_missing "pulseaudio"
install_if_missing "pavucontrol"
install_if_missing "alsa-utils"
install_if_missing "blueman"
install_if_missing "systemd-networkd"
install_if_missing "systemd-resolved"

# Step 2: Enable systemd-networkd and systemd-resolved
echo "Enabling systemd-networkd and systemd-resolved..."
sudo systemctl enable --now systemd-networkd
sudo systemctl enable --now systemd-resolved

# Set systemd-resolved as DNS resolver
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Step 3: Install Nix and Home-Manager
echo "Installing Nix package manager..."
if ! command -v nix &>/dev/null; then
  perform_action "curl -L https://nixos.org/nix/install | sh"
  . ~/.nix-profile/etc/profile.d/nix.sh
fi

# Step 4: Setting up Home-Manager
echo "Setting up Home-Manager..."
if [ ! -d "$HOME/.config/home-manager" ]; then
  mkdir -p ~/.config
  ln -s ~/dotfiles/nix/.config/home-manager ~/.config/home-manager
fi

# Step 5: Apply Nix Configuration
echo "Applying Nix configuration..."
home-manager switch

# Step 6: Clone Dotfiles Repository
if [ ! -d "$DOTFILES_DIR" ]; then
  perform_action "git clone $REPO_URL $DOTFILES_DIR"
fi

# Step 7: Use GNU Stow to Symlink Dotfiles
if [ -d "$DOTFILES_DIR" ]; then
  echo "Creating symlinks using stow..."
  perform_action "cd $DOTFILES_DIR && stow --simulate xfce4 gtk3 gtk4 icons themes"
fi

# Final Message
echo "Setup complete! Your environment has been configured."
if [ "$SIMULATE" = true ]; then
  echo "This was a simulation. No changes were made."
fi

