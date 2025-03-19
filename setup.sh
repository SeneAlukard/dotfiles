#!/bin/bash

# Streamlined setup script for Arch Linux with Nix integration
# This script sets up only essential tools with pacman and delegates the rest to Nix
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
  
  # Only include truly essential tools that shouldn't be managed by Nix
  local essential_tools=(
    "git"         # Required for dotfiles and version control
    "stow"        # Required for dotfiles management
    "zsh"         # Shell of choice
    "curl"        # Required for downloading files and installers
    "base-devel"  # Required for building packages
    "unzip"       # Required for extracting packages
    "wget"        # Required for downloading files
  )
  
  for tool in "${essential_tools[@]}"; do
    install_if_missing "$tool"
  done
  
  print_success "Essential tools installation complete."
  print_info "All other development tools will be managed by Nix."
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
    
    for config in "$HOME/.zshrc" "$HOME/.tmux.conf" "$HOME/.config/nvim" "$HOME/.config/alacritty" "$HOME/.config/home-manager" "$HOME/.config/nix"; do
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
      "gtk"
      "xfce4"
      "nix"  # Make sure to stow nix configs if they exist
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
    
    # Now apply Nix configuration if Nix is enabled and installed
    if [ "$NIX_ENABLE" = true ] && command -v nix &>/dev/null; then
      print_section "Applying Nix Configuration"
      
      # Apply flake configuration if it exists
      if [ -f "$DOTFILES_DIR/nix/flake.nix" ]; then
        print_info "Applying Nix flake configuration..."
        if [ "$SIMULATE" = false ]; then
          # Move to dotfiles and apply the flake
          perform_action "cd $DOTFILES_DIR/nix && nix flake update"
          perform_action "cd $DOTFILES_DIR/nix && nix build .#homeConfigurations.$USER.activationPackage --impure"
          perform_action "cd $DOTFILES_DIR/nix && ./result/activate"
          print_success "Nix flake configuration applied."
        else
          print_info "Would apply Nix flake configuration."
        fi
      elif [ -f "$DOTFILES_DIR/nix/.config/home-manager/home.nix" ] || [ -f "$HOME/.config/home-manager/home.nix" ]; then
        # If there's no flake but there is a home.nix, use home-manager
        print_info "Setting up Home Manager for Nix..."
        if ! command -v home-manager &>/dev/null; then
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
        fi
        
        # Apply Home Manager configuration
        if [ "$SIMULATE" = false ]; then
          print_info "Building Home Manager environment..."
          perform_action "home-manager switch"
          print_success "Home Manager environment built and activated."
        else
          print_info "Would build and activate Home Manager environment."
        fi
      else
        print_warning "No Nix configuration (flake.nix or home.nix) found in dotfiles."
      fi
    fi
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
      
      # Give the user a chance to restart their shell if needed
      print_warning "For Nix to work properly in this session, you may need to source the Nix environment."
      read -p "Would you like to source the Nix environment now? (y/n) " -n 1 -r
      echo
      if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
          print_success "Nix environment sourced."
        else
          print_warning "Nix environment file not found. You may need to restart your shell."
        fi
      fi
    else
      print_info "Would install Nix package manager."
    fi
  else
    print_info "Nix is already installed."
  fi
  
  # Enable flakes if needed
  if ! grep -q "experimental-features" "$HOME/.config/nix/nix.conf" 2>/dev/null; then
    print_info "Enabling Nix flakes..."
    perform_action "mkdir -p $HOME/.config/nix"
    perform_action "echo 'experimental-features = nix-command flakes' >> $HOME/.config/nix/nix.conf"
    print_success "Nix flakes enabled."
  fi
  
  # Note: We're NOT applying flake configuration here yet
  # We'll wait until after we've stowed the dotfiles
  print_info "Nix setup complete. Configuration will be applied after dotfiles are stowed."
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
  
  # Check Nix installation if enabled
  if [ "$NIX_ENABLE" = true ]; then
    if ! command -v nix &>/dev/null; then
      print_warning "Nix is not installed or not in PATH."
      all_good=false
    else
      print_success "Nix is installed."
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
    print_info "The remaining development tools and configurations will be managed by Nix."
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
  
  # Step 3: Set up Nix if enabled (before stowing dotfiles)
  if [ "$NIX_ENABLE" = true ]; then
    setup_nix
  else
    print_info "Nix setup is disabled. Skipping."
  fi
  
  # Step 4: Now use GNU Stow to symlink dotfiles (after Nix is set up)
  stow_dotfiles
  
  # Step 5: Set up fonts
  setup_fonts
  
  # Step 6: Set up XFCE
  setup_xfce
  
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
