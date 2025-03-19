#!/bin/bash

# Enhanced setup script for Arch Linux with Nix integration
# This script sets up a development environment using both pacman and Nix
# Dotfiles are managed with GNU Stow
# Author: SeneAlukard (enhanced version)

# Color definitions for output messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Variables
DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="git@github.com:SeneAlukard/dotfiles.git"
SIMULATE=${SIMULATE:-false} # Set to true to simulate the setup without making changes
NIX_ENABLE=${NIX_ENABLE:-true} # Enable Nix setup by default

# Function to print section headers
print_section() {
  echo -e "\n${BLUE}=== $1 ===${NC}"
}

# Function to print success messages
print_success() {
  echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error messages
print_error() {
  echo -e "${RED}✗ $1${NC}"
}

# Function to print warning messages
print_warning() {
  echo -e "${YELLOW}! $1${NC}"
}

# Function to print info messages
print_info() {
  echo -e "${CYAN}i $1${NC}"
}

# Function to install a package if not already installed (via pacman)
install_if_missing() {
  if ! command -v "$1" &>/dev/null; then
    if [ "$SIMULATE" = false ]; then
      print_info "Installing $1..."
      sudo pacman -S --noconfirm --needed "$1"
      if [ $? -eq 0 ]; then
        print_success "$1 installed successfully."
      else
        print_error "Failed to install $1."
        return 1
      fi
    else
      print_info "Would install: $1"
    fi
  else
    print_info "$1 is already installed."
  fi
  return 0
}

# Function to simulate or perform an action
perform_action() {
  if [ "$SIMULATE" = false ]; then
    print_info "Executing: $1"
    eval "$1"
    local exit_code=$?
    if [ $exit_code -eq 0 ]; then
      return 0
    else
      print_error "Command failed with exit code $exit_code: $1"
      return $exit_code
    fi
  else
    print_info "Would run: $1"
    return 0
  fi
}

# Function to check if we're on Arch Linux
check_arch_linux() {
  if [ -f /etc/arch-release ]; then
    print_success "Arch Linux detected."
    return 0
  else
    print_warning "This doesn't appear to be Arch Linux. Some features may not work."
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
      print_error "Setup aborted."
      exit 1
    fi
  fi
}

# Function to install essential tools via pacman
install_essential_tools() {
  print_section "Installing Essential Tools via pacman"
  
  local essential_tools=(
    "git"
    "stow"
    "zsh"
    "fzf"
    "neovim"
    "tmux"
    "curl"
    "unzip"
    "base-devel"  # Required for AUR packages
    "ripgrep"     # For Neovim telescope
    "fd"          # For Neovim telescope
    "exa"         # Better ls
    "bat"         # Better cat
  )
  
  for tool in "${essential_tools[@]}"; do
    install_if_missing "$tool"
  done
}

# Function to install and set up Oh My Posh
setup_oh_my_posh() {
  print_section "Setting up Oh My Posh"
  
  OHMYPOSH_BIN="/usr/local/bin/oh-my-posh"
  OHMYPOSH_THEME_DIR="$HOME/.config/ohmyposh"
  
  if [ ! -f "$OHMYPOSH_BIN" ]; then
    perform_action "sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O $OHMYPOSH_BIN"
    perform_action "sudo chmod +x $OHMYPOSH_BIN"
  else
    print_info "Oh My Posh already installed."
  fi
  
  if [ ! -d "$OHMYPOSH_THEME_DIR" ]; then
    perform_action "mkdir -p $OHMYPOSH_THEME_DIR"
    perform_action "wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O /tmp/themes.zip"
    perform_action "unzip /tmp/themes.zip -d $OHMYPOSH_THEME_DIR"
    perform_action "rm /tmp/themes.zip"
  else
    print_info "Oh My Posh themes directory already exists."
  fi
  
  # Copy custom themes if available
  if [ -f "$DOTFILES_DIR/ohmyposh/.config/ohmyposh/zen.json" ]; then
    perform_action "cp $DOTFILES_DIR/ohmyposh/.config/ohmyposh/zen.json $OHMYPOSH_THEME_DIR/"
    print_success "Custom Oh My Posh theme 'zen' installed."
  fi
}

# Function to clone or update dotfiles repository
setup_dotfiles_repo() {
  print_section "Setting up Dotfiles Repository"
  
  if [ ! -d "$DOTFILES_DIR" ]; then
    perform_action "git clone $REPO_URL $DOTFILES_DIR"
    print_success "Dotfiles repository cloned."
  else
    print_info "Dotfiles repository already exists."
    if [ "$SIMULATE" = false ]; then
      read -p "Do you want to update the dotfiles repository? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        perform_action "cd $DOTFILES_DIR && git pull"
        print_success "Dotfiles repository updated."
      fi
    else
      print_info "Would update dotfiles repository."
    fi
  fi
}

# Function to use GNU Stow to symlink dotfiles
stow_dotfiles() {
  print_section "Creating symlinks with GNU Stow"
  
  if [ -d "$DOTFILES_DIR" ]; then
    # Create backup of existing configs
    print_info "Creating backup of existing configurations..."
    BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d-%H%M%S)"
    perform_action "mkdir -p $BACKUP_DIR"
    
    for config in "$HOME/.zshrc" "$HOME/.tmux.conf" "$HOME/.config/nvim" "$HOME/.config/alacritty"; do
      if [ -e "$config" ]; then
        perform_action "cp -r $config $BACKUP_DIR/"
      fi
    done
    
    print_success "Backup created at $BACKUP_DIR."
    
    # Use stow to create symlinks
    local stow_dirs=(
      "alacritty"
      "nvim"
      "ohmyposh"
      "tmux"
      "zsh"
      "gtk3"
      "gtk4"
      "xfce4"
    )
    
    cd "$DOTFILES_DIR" || { print_error "Failed to change to dotfiles directory."; return 1; }
    
    # First simulate stow to check for conflicts
    print_info "Checking for potential stow conflicts..."
    for dir in "${stow_dirs[@]}"; do
      if [ -d "$dir" ]; then
        stow --simulate "$dir" 2>/tmp/stow_conflict_$dir
        if [ $? -ne 0 ]; then
          print_warning "Potential conflict detected for $dir. See /tmp/stow_conflict_$dir for details."
          print_warning "You may need to manually remove conflicting files before proceeding."
          
          if [ "$SIMULATE" = false ]; then
            read -p "Do you want to force stow for $dir? (This will overwrite conflicts) (y/n) " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
              perform_action "stow --adopt -v $dir"
              # Immediately restow to ensure we're using the repository's version
              perform_action "stow -v $dir"
              print_success "$dir forcefully stowed."
            else
              print_warning "Skipping $dir stow."
            fi
          else
            print_info "Would ask to force stow for $dir."
          fi
        else
          # No conflicts, proceed with stow
          if [ "$SIMULATE" = false ]; then
            perform_action "stow -v $dir"
            print_success "$dir stowed successfully."
          else
            print_info "Would stow $dir."
          fi
        fi
      else
        print_warning "Directory $dir not found in dotfiles."
      fi
    done
  else
    print_error "Dotfiles directory not found. Cannot stow."
    return 1
  fi
}

# Function to set up Zsh plugins and configurations
setup_zsh() {
  print_section "Setting up Zsh"
  
  # Set Zsh as default shell if it's not already
  if [[ "$SHELL" != *"zsh"* ]]; then
    print_info "Changing default shell to Zsh..."
    if [ "$SIMULATE" = false ]; then
      chsh -s "$(which zsh)"
      print_success "Default shell changed to Zsh."
    else
      print_info "Would change default shell to Zsh."
    fi
  else
    print_info "Zsh is already the default shell."
  fi
  
  # Set up Zinit (modern Zsh plugin manager)
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  if [ ! -d "$ZINIT_HOME" ]; then
    print_info "Installing Zinit..."
    perform_action "mkdir -p \"$(dirname $ZINIT_HOME)\""
    perform_action "git clone https://github.com/zdharma-continuum/zinit.git \"$ZINIT_HOME\""
    print_success "Zinit installed."
  else
    print_info "Zinit is already installed."
  fi
  
  # Install Zsh plugins (these are handled by Zinit in .zshrc, but we'll ensure repos are available)
  local zsh_plugin_repos=(
    "https://github.com/zsh-users/zsh-syntax-highlighting.git"
    "https://github.com/zsh-users/zsh-autosuggestions.git"
    "https://github.com/zsh-users/zsh-completions.git"
  )
  
  for repo in "${zsh_plugin_repos[@]}"; do
    repo_name=$(basename "$repo" .git)
    if [ ! -d "${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/plugins/_local---$repo_name" ]; then
      print_info "Ensuring Zsh plugin $repo_name is available..."
    fi
  done
  
  # Install Starship prompt if used in .zshrc
  if grep -q "starship init" "$DOTFILES_DIR/zsh/.zshrc"; then
    if ! command -v starship &>/dev/null; then
      print_info "Installing Starship prompt..."
      if [ "$SIMULATE" = false ]; then
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Starship prompt installed."
      else
        print_info "Would install Starship prompt."
      fi
    else
      print_info "Starship prompt is already installed."
    fi
  fi
  
  # Install zoxide if used in .zshrc
  if grep -q "zoxide init" "$DOTFILES_DIR/zsh/.zshrc"; then
    if ! command -v zoxide &>/dev/null; then
      print_info "Installing zoxide..."
      perform_action "curl -sS https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash"
      print_success "zoxide installed."
    else
      print_info "zoxide is already installed."
    fi
  fi
}

# Function to set up Neovim
setup_neovim() {
  print_section "Setting up Neovim"
  
  # Install Lazy.nvim (plugin manager for Neovim)
  LAZY_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy/lazy.nvim"
  if [ ! -d "$LAZY_DIR" ]; then
    print_info "Installing Lazy.nvim..."
    perform_action "git clone --filter=blob:none https://github.com/folke/lazy.nvim.git --branch=stable \"$LAZY_DIR\""
    print_success "Lazy.nvim installed."
  else
    print_info "Lazy.nvim is already installed."
  fi
  
  # Install language servers for Neovim LSP
  if command -v npm &>/dev/null; then
    print_info "Installing global npm packages for Neovim..."
    local npm_packages=(
      "typescript-language-server"
      "vscode-langservers-extracted"
      "bash-language-server"
      "pyright"
    )
    
    for package in "${npm_packages[@]}"; do
      if ! npm list -g "$package" &>/dev/null; then
        perform_action "npm install -g $package"
      else
        print_info "$package is already installed."
      fi
    done
  else
    print_warning "npm not found. Skipping LSP installations."
  fi
  
  # Install formatters and linters
  print_info "Installing formatters and linters..."
  local formatters=(
    "stylua"      # Lua formatter
    "prettier"    # JavaScript/TypeScript formatter
    "black"       # Python formatter
    "isort"       # Python import formatter
  )
  
  for formatter in "${formatters[@]}"; do
    case "$formatter" in
      stylua)
        if ! command -v stylua &>/dev/null; then
          if command -v cargo &>/dev/null; then
            perform_action "cargo install stylua"
          else
            print_warning "cargo not found. Skipping stylua installation."
          fi
        else
          print_info "stylua is already installed."
        fi
        ;;
      prettier)
        if ! command -v prettier &>/dev/null && command -v npm &>/dev/null; then
          perform_action "npm install -g prettier"
        else
          print_info "prettier is already installed or npm not found."
        fi
        ;;
      black|isort)
        if command -v pip &>/dev/null; then
          if ! pip show "$formatter" &>/dev/null; then
            perform_action "pip install --user $formatter"
          else
            print_info "$formatter is already installed."
          fi
        else
          print_warning "pip not found. Skipping $formatter installation."
        fi
        ;;
    esac
  done
  
  # Install tree-sitter CLI for syntax highlighting
  if ! command -v tree-sitter &>/dev/null; then
    if command -v npm &>/dev/null; then
      perform_action "npm install -g tree-sitter-cli"
    else
      print_warning "npm not found. Skipping tree-sitter-cli installation."
    fi
  else
    print_info "tree-sitter-cli is already installed."
  fi
  
  # Set up neovim initialization
  print_info "Initializing Neovim plugins (this may take a moment)..."
  if [ "$SIMULATE" = false ]; then
    # Use a temporary script to install plugins non-interactively
    cat > /tmp/nvim_init.lua << 'EOL'
vim.cmd('autocmd User PackerComplete quitall')
vim.cmd('autocmd User LazyInstall quitall')
require('lazy').sync()
EOL
    perform_action "nvim --headless -u /tmp/nvim_init.lua"
    rm /tmp/nvim_init.lua
    print_success "Neovim plugins initialized."
  else
    print_info "Would initialize Neovim plugins."
  fi
}

# Function to set up Tmux Plugin Manager
setup_tmux() {
  print_section "Setting up Tmux"
  
  TPM_DIR="$HOME/.tmux/plugins/tpm"
  if [ ! -d "$TPM_DIR" ]; then
    print_info "Installing Tmux Plugin Manager..."
    perform_action "git clone https://github.com/tmux-plugins/tpm $TPM_DIR"
    print_success "Tmux Plugin Manager installed."
  else
    print_info "Tmux Plugin Manager is already installed."
  fi
  
  # Install plugins
  print_info "Installing Tmux plugins..."
  if [ "$SIMULATE" = false ] && [ -f "$HOME/.tmux.conf" ]; then
    # Run TPM install script non-interactively
    perform_action "$TPM_DIR/bin/install_plugins"
    print_success "Tmux plugins installed."
  else
    print_info "Would install Tmux plugins."
  fi
  
  # Set up terminal integration
  if grep -q "tmux-256color" "/usr/share/terminfo/t/" 2>/dev/null; then
    print_info "tmux-256color terminfo entry already exists."
  else
    print_info "Setting up tmux-256color terminfo entry..."
    perform_action "curl -LO https://invisible-island.net/datafiles/current/terminfo.src.gz"
    perform_action "gunzip terminfo.src.gz"
    perform_action "tic -xe tmux-256color terminfo.src"
    perform_action "rm terminfo.src"
    print_success "tmux-256color terminfo entry installed."
  fi
}

# Function to set up Nix
setup_nix() {
  print_section "Setting up Nix"
  
  if ! command -v nix &>/dev/null; then
    print_info "Installing Nix package manager..."
    if [ "$SIMULATE" = false ]; then
      # Use the recommended multi-user installation
      perform_action "sh <(curl -L https://nixos.org/nix/install) --daemon"
      
      # Source nix in current shell
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
      print_success "Nix installed. You may need to restart your shell or source Nix environment."
    else
      print_info "Would install Nix package manager."
    fi
  else
    print_info "Nix is already installed."
  fi
  
  # Set up Home Manager for Nix
  if ! command -v home-manager &>/dev/null; then
    print_info "Setting up Home Manager for Nix..."
    if [ "$SIMULATE" = false ]; then
      # Add the Home Manager channel
      perform_action "nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager"
      perform_action "nix-channel --update"
      
      # Install Home Manager
      perform_action "nix-shell '<home-manager>' -A install"
      print_success "Home Manager installed."
    else
      print_info "Would set up Home Manager for Nix."
    fi
  else
    print_info "Home Manager is already installed."
  fi
  
  # Copy and set up home-manager configuration if it exists
  HM_CONFIG_DIR="$HOME/.config/home-manager"
  if [ -d "$DOTFILES_DIR/nix/.config/home-manager" ]; then
    print_info "Setting up Home Manager configuration..."
    
    if [ ! -d "$HM_CONFIG_DIR" ]; then
      perform_action "mkdir -p $HM_CONFIG_DIR"
    fi
    
    if [ -f "$DOTFILES_DIR/nix/.config/home-manager/home.nix" ]; then
      # We'll use the stowed configuration if it exists
      if [ ! -f "$HM_CONFIG_DIR/home.nix" ] || ! diff -q "$HM_CONFIG_DIR/home.nix" "$DOTFILES_DIR/nix/.config/home-manager/home.nix" >/dev/null; then
        print_info "Home Manager configuration differs or doesn't exist."
        if [ "$SIMULATE" = false ]; then
          print_info "Building Home Manager environment..."
          perform_action "home-manager switch"
          print_success "Home Manager environment built and activated."
        else
          print_info "Would build and activate Home Manager environment."
        fi
      else
        print_info "Home Manager configuration is already up to date."
      fi
    fi
  else
    print_warning "No Home Manager configuration found in dotfiles."
  fi
  
  # Set up flake support if flake.nix exists
  if [ -f "$DOTFILES_DIR/nix/flake.nix" ]; then
    print_info "Setting up Nix flakes..."
    if [ "$SIMULATE" = false ]; then
      # Enable flakes
      if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
        perform_action "mkdir -p $HOME/.config/nix"
        perform_action "echo 'experimental-features = nix-command flakes' >> $HOME/.config/nix/nix.conf"
        print_success "Flakes enabled in Nix configuration."
      fi
      
      # Set up the flake
      perform_action "cd $DOTFILES_DIR && nix flake update"
      print_success "Nix flake updated."
    else
      print_info "Would set up Nix flakes."
    fi
  fi
}

# Function to set up fonts
setup_fonts() {
  print_section "Setting up Fonts"
  
  FONT_DIR="$HOME/.local/share/fonts"
  perform_action "mkdir -p $FONT_DIR"
  
  # Install Nerd Fonts
  if [ ! -d "$FONT_DIR/NerdFonts" ]; then
    print_info "Installing Nerd Fonts..."
    
    # We'll install Hack Nerd Font which is used in your Alacritty config
    HACK_NERD_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip"
    
    perform_action "wget -O /tmp/Hack.zip $HACK_NERD_FONT_URL"
    perform_action "mkdir -p $FONT_DIR/NerdFonts"
    perform_action "unzip -o /tmp/Hack.zip -d $FONT_DIR/NerdFonts"
    perform_action "rm /tmp/Hack.zip"
    
    # Update font cache
    print_info "Updating font cache..."
    perform_action "fc-cache -f"
    
    print_success "Nerd Fonts installed."
  else
    print_info "Nerd Fonts directory already exists."
  fi
}

# Function to set up XFCE
setup_xfce() {
  print_section "Setting up XFCE"
  
  # Only proceed if we're running in XFCE
  if ! pgrep xfce4-session &>/dev/null && ! [ -n "$XDG_CURRENT_DESKTOP" ] && [ "$XDG_CURRENT_DESKTOP" != "XFCE" ]; then
    print_warning "XFCE session not detected. Skipping XFCE setup."
    return 0
  fi
  
  print_info "Setting up XFCE themes and configurations..."
  
  # Create necessary directories
  perform_action "mkdir -p $HOME/.themes"
  perform_action "mkdir -p $HOME/.icons"
  
  # Install Dracula theme if not present
  if [ ! -d "$HOME/.themes/Dracula" ]; then
    print_info "Installing Dracula GTK theme..."
    perform_action "git clone https://github.com/dracula/gtk.git /tmp/dracula-gtk"
    perform_action "cp -r /tmp/dracula-gtk/gtk-2.0 /tmp/dracula-gtk/gtk-3.0 /tmp/dracula-gtk/gtk-4.0 $HOME/.themes/Dracula/"
    perform_action "rm -rf /tmp/dracula-gtk"
    print_success "Dracula GTK theme installed."
  fi
  
  # Install Gruvbox-Plus icons if not present
  if [ ! -d "$HOME/.icons/Gruvbox-Plus-Dark" ]; then
    print_info "Installing Gruvbox-Plus icon theme..."
    perform_action "git clone https://github.com/SylEleuth/gruvbox-plus-icon-pack.git /tmp/gruvbox-plus"
    perform_action "cp -r /tmp/gruvbox-plus/Gruvbox-Plus-Dark $HOME/.icons/"
    perform_action "rm -rf /tmp/gruvbox-plus"
    print_success "Gruvbox-Plus icon theme installed."
  fi
  
  # Apply XFCE settings
  if command -v xfconf-query &>/dev/null; then
    print_info "Applying XFCE settings..."
    
    # Set GTK theme
    perform_action "xfconf-query -c xsettings -p /Net/ThemeName -s 'Dracula'"
    
    # Set icon theme
    perform_action "xfconf-query -c xsettings -p /Net/IconThemeName -s 'Gruvbox-Plus-Dark'"
    
    # Set window manager theme
    perform_action "xfconf-query -c xfwm4 -p /general/theme -s 'Default'"
    
    # Set decorations layout
    perform_action "xfconf-query -c xsettings -p /Gtk/DecorationLayout -s 'icon,menu:minimize,maximize,close'"
    
    # Set font
    perform_action "xfconf-query -c xsettings -p /Gtk/FontName -s 'Sans 10'"
    
    print_success "XFCE settings applied."
  else
    print_warning "xfconf-query not found. Skipping XFCE settings application."
  fi
}

# Final setup verification
verify_setup() {
  print_section "Verifying Setup"
  
  local all_good=true
  
  # Check essential tools
  for cmd in git stow zsh neovim tmux; do
    if ! command -v "$cmd" &>/dev/null; then
      print_error "$cmd is not installed or not in PATH."
      all_good=false
    else
      print_success "$cmd is installed."
    fi
  done
  
  # Check if dotfiles are stowed
  if [ ! -L "$HOME/.zshrc" ] || [ ! -L "$HOME/.tmux.conf" ]; then
    print_warning "Dotfiles may not be properly stowed."
    all_good=false
  else
    print_success "Dotfiles appear to be properly stowed."
  fi
  
  # Check Nix installation if enabled
  if [ "$NIX_ENABLE" = true ]; then
    if ! command -v nix &>/dev/null; then
      print_warning "Nix is not installed or not in PATH."
      all_good=false
    else
      print_success "Nix is installed."
      
      if ! command -v home-manager &>/dev/null; then
        print_warning "Home Manager is not installed or not in PATH."
        all_good=false
      else
        print_success "Home Manager is installed."
      fi
    fi
  fi
  
  # Check font installation
  if [ ! -d "$HOME/.local/share/fonts/NerdFonts" ]; then
    print_warning "Nerd Fonts may not be properly installed."
    all_good=false
  else
    print_success "Nerd Fonts appear to be installed."
  fi
  
  if [ "$all_good" = true ]; then
    print_section "Setup Complete!"
    print_success "Your environment has been successfully configured."
    print_info "You may need to log out and log back in for all changes to take effect."
  else
    print_section "Setup Completed with Warnings"
    print_warning "Some components may not have been installed correctly."
    print_info "Check the messages above for details and try resolving the issues manually."
  fi
}

# Main function to run the setup
main() {
  print_section "Starting Environment Setup"
  
  if [ "$SIMULATE" = true ]; then
    print_warning "Running in SIMULATION mode. No changes will be made."
  fi
  
  # Check if we're on Arch Linux
  check_arch_linux
  
  # Step 1: Install Essential Tools
  install_essential_tools
  
  # Step 2: Clone or update dotfiles repository
  setup_dotfiles_repo
  
  # Step 3: Use GNU Stow to symlink dotfiles
  stow_dotfiles
  
  # Step 4: Install and set up Oh My Posh
  setup_oh_my_posh
  
  # Step 5: Set up Zsh
  setup_zsh
  
  # Step 6: Set up Neovim
  setup_neovim
  
  # Step 7: Set up Tmux
  setup_tmux
  
  # Step 8: Set up fonts
  setup_fonts
  
  # Step 9: Set up XFCE
  setup_xfce
  
  # Step 10: Set up Nix if enabled
  if [ "$NIX_ENABLE" = true ]; then
    setup_nix
  else
    print_info "Nix setup is disabled. Skipping."
  fi
  
  # Final verification
  verify_setup
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --simulate|--dry-run)
      SIMULATE=true
      shift
      ;;
    --no-nix)
      NIX_ENABLE=false
      shift
      ;;
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --simulate, --dry-run   Run in simulation mode without making changes"
      echo "  --no-nix                Skip Nix package manager setup"
      echo "  --help                  Display this help message"
      exit 0
      ;;
    *)
      print_error "Unknown option: $1"
      echo "Use --help for usage information."
      exit 1
      ;;
  esac
done

# Run the main function
main
