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
      sudo apt update && sudo apt install -y "$1"
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

# Step 1: Install Essential Tools
echo "Installing required tools..."
install_if_missing "git"
install_if_missing "stow"
install_if_missing "zsh"
install_if_missing "fzf"
install_if_missing "neovim"
install_if_missing "tmux"
install_if_missing "curl"
install_if_missing "unzip"

# Step 2: Install Oh My Posh
OHMYPOSH_BIN="/usr/local/bin/oh-my-posh"
OHMYPOSH_THEME_DIR="$HOME/.config/ohmyposh"
if [ ! -f "$OHMYPOSH_BIN" ]; then
  perform_action "sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O $OHMYPOSH_BIN"
  perform_action "sudo chmod +x $OHMYPOSH_BIN"
fi
if [ ! -d "$OHMYPOSH_THEME_DIR" ]; then
  perform_action "mkdir -p $OHMYPOSH_THEME_DIR"
  perform_action "wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O /tmp/themes.zip"
  perform_action "unzip /tmp/themes.zip -d $OHMYPOSH_THEME_DIR"
  perform_action "rm /tmp/themes.zip"
fi

# Step 3: Clone Dotfiles Repository
if [ ! -d "$DOTFILES_DIR" ]; then
  perform_action "git clone $REPO_URL $DOTFILES_DIR"
fi

# Step 4: Use GNU Stow to Symlink Dotfiles
if [ -d "$DOTFILES_DIR" ]; then
  echo "Creating symlinks using stow..."
  perform_action "cd $DOTFILES_DIR && stow --simulate alacritty nvim ohmyposh xfce4 gtk3 gtk4 tmux zsh icons themes"
fi

# Step 5: Configure Zsh Plugins
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom/plugins"
if [ ! -d "$ZSH_CUSTOM" ]; then
  perform_action "git clone https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh"
fi
perform_action "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/zsh-syntax-highlighting"
perform_action "git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/zsh-autosuggestions"
perform_action "git clone https://github.com/zsh-users/zsh-completions.git $ZSH_CUSTOM/zsh-completions"
perform_action "git clone https://github.com/ajeetdsouza/zoxide.git ~/.zoxide"
perform_action "zoxide init zsh >> ~/.zshrc"

# Step 6: Install Neovim Plugins
NVIM_CONFIG="$HOME/.config/nvim"
if [ -d "$NVIM_CONFIG" ]; then
  echo "Installing Neovim plugins using Lazy.nvim..."
  perform_action "curl -fsSL https://raw.githubusercontent.com/folke/lazy.nvim/main/lazy.lua > $NVIM_CONFIG/lazy/lazy.nvim"
  perform_action "nvim --headless +Lazy! sync +qa"
fi

# Step 7: Install Tmux Plugin Manager (TPM)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  perform_action "git clone https://github.com/tmux-plugins/tpm $TPM_DIR"
fi

# Final Message
echo "Setup complete! Your environment has been configured."
if [ "$SIMULATE" = true ]; then
  echo "This was a simulation. No changes were made."
fi

