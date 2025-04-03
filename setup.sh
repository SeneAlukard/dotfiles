#!/bin/bash

# Streamlined setup script for Arch Linux dotfiles
# This script sets up essential tools and configurations
# Dotfiles are managed with GNU Stow
# Author: SeneAlukard (optimized version)

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
  
  # Only include truly essential tools - removed desktop environment packages
  local essential_tools=(
    "git"         # Required for dotfiles and version control
    "stow"        # Required for dotfiles management
    "zsh"         # Shell of choice
    "curl"        # Required for downloading files and installers
    "base-devel"  # Required for building packages
    "unzip"       # Required for extracting packages
    "wget"        # Required for downloading files
    "neovim"
    #"alacritty"
    "kitty"
    "tmux"
    "fzf"
    "ripgrep"
    "bat"
    "starship"
    "qbittorrent"
    "aria2"
    "ncdu"
    "eza"
    "nodejs"
    "zoxide"
  )
  
  for tool in "${essential_tools[@]}"; do
    install_if_missing "$tool"
  done
  
  print_success "Essential tools installation complete."
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
    
    for config in "$HOME/.zshrc" "$HOME/.tmux.conf" "$HOME/.config/nvim" "$HOME/.config/kitty"; do
      if [ -e "$config" ]; then
        perform_action "cp -r $config $BACKUP_DIR/"
      fi
    done
    
    print_success "Backup created at $BACKUP_DIR."
    
    # Use stow to create symlinks - removed xfce4 and gtk
    local stow_dirs=(
      #"alacritty"
      "kitty"
      "nvim"
      "tmux"
      "zsh"
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

# Function to set up fonts
setup_fonts() {
  print_section "Setting up Fonts"
  
  FONT_DIR="$HOME/.local/share/fonts"
  perform_action "mkdir -p $FONT_DIR"
  
  # Install Nerd Fonts
  if [ ! -d "$FONT_DIR/NerdFonts" ]; then
    print_info "Installing Nerd Fonts..."
    
    # We'll install Hack Nerd Font which is commonly used
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

# Function to set up zsh
setup_zsh() {
  print_section "Setting up Zsh"

  # Install zsh if not already installed
  install_if_missing "zsh"

  # Set up Zinit
  ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
  if [ ! -d "$ZINIT_HOME" ]; then
    print_info "Installing Zinit..."
    perform_action "mkdir -p $(dirname $ZINIT_HOME)"
    perform_action "git clone https://github.com/zdharma-continuum/zinit.git $ZINIT_HOME"
    print_success "Zinit installed."
  else
    print_info "Zinit already installed."
  fi

  # Install Starship prompt if not already installed
  if ! command -v starship &>/dev/null; then
    print_info "Installing Starship prompt..."
    if [ "$SIMULATE" = false ]; then
      perform_action "curl -sS https://starship.rs/install.sh | sh"
    else
      print_info "Would install Starship prompt."
    fi
  else
    print_info "Starship prompt already installed."
  fi

  # Change default shell to zsh if not already
  if [ "$(getent passwd $USER | cut -d: -f7)" != "$(which zsh)" ]; then
    print_info "Changing default shell to Zsh..."
    if [ "$SIMULATE" = false ]; then
      perform_action "chsh -s $(which zsh)"
    else
      print_info "Would change default shell to Zsh."
    fi
  else
    print_info "Zsh is already the default shell."
  fi
}

# Final setup verification
verify_setup() {
  print_section "Verifying Setup"
  
  local all_good=true
  
  # Check essential tools
  for cmd in git stow zsh curl; do
    if ! command -v "$cmd" &>/dev/null; then
      print_error "$cmd is not installed or not in PATH."
      all_good=false
    else
      print_success "$cmd is installed."
    fi
  done
  
  # Check if dotfiles are stowed
  if [ ! -L "$HOME/.zshrc" ]; then
    print_warning "Dotfiles may not be properly stowed."
    all_good=false
  else
    print_success "Dotfiles appear to be properly stowed."
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
    print_info "Use your arch-setup.sh script to install desktop environment/window manager components."
    print_info "You may need to log out and log back in for all changes to take effect."
  else
    print_section "Setup Completed with Warnings"
    print_warning "Some components may not have been installed correctly."
    print_info "Check the messages above for details and try resolving the issues manually."
    print_info "After fixing issues, use your arch-setup.sh script to install the desktop environment."
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
  
  # Step 3: Set up Zsh
  setup_zsh
  
  # Step 4: Now use GNU Stow to symlink dotfiles
  stow_dotfiles
  
  # Step 5: Set up fonts
  setup_fonts
  
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
    --help)
      echo "Usage: $0 [OPTIONS]"
      echo "Options:"
      echo "  --simulate, --dry-run   Run in simulation mode without making changes"
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
