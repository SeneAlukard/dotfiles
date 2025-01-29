#!/bin/bash

# Define variables
DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="git@github.com:SeneAlukard/dotfiles.git" # Replace with your repo URL

# Function to install a package if not already installed
install_if_missing() {
  if ! command -v "$1" &>/dev/null; then
    echo "Installing $1..."
    sudo apt update && sudo apt install -y "$1"
  else
    echo "$1 is already installed."
  fi
}

# Step 1: Install necessary packages
echo "Installing required packages..."
install_if_missing "git"
install_if_missing "stow"

# Step 2: Clone dotfiles repository if it doesn't exist
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles repository..."
  git clone "$REPO_URL" "$DOTFILES_DIR"
else
  echo "Dotfiles repository already exists."
fi

# Step 3: Navigate to dotfiles directory
cd "$DOTFILES_DIR" || exit

# Step 4: Use stow to symlink dotfiles
echo "Creating symlinks with stow..."
stow alacritty nvim ohmyposh xfce4 gtk3 gtk4 tmux zsh icons themes

# Step 5: Verify symlinks
echo "Verifying symlinks..."
stow --simulate alacritty nvim ohmyposh xfce4 gtk3 gtk4 tmux zsh icons themes

echo "Setup complete! Your dotfiles are now symlinked."

