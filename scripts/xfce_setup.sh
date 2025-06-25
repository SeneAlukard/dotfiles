#!/bin/bash

# XFCE Desktop Environment Setup Script for Arch Linux
# This script installs and configures XFCE and related components

# Color definitions for output messages
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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
  exit 1
}

# Function to print warning messages
print_warning() {
  echo -e "${YELLOW}! $1${NC}"
}

# Function to print info messages
print_info() {
  echo -e "${CYAN}i $1${NC}"
}

# Function to install packages
install_packages() {
  print_info "Installing packages: $@"
  sudo pacman -S --needed --noconfirm "$@"
  if [ $? -ne 0 ]; then
    print_error "Failed to install packages"
  else
    print_success "Packages installed successfully"
  fi
}

# Check if running as root
if [ "$(id -u)" = "0" ]; then
  print_error "This script should not be run as root"
fi

# Check if running on Arch Linux
if [ ! -f /etc/arch-release ]; then
  print_warning "This doesn't appear to be Arch Linux. Some features may not work."
  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "Setup aborted."
  fi
fi

# Install X.org packages
print_section "Installing X.org packages"
install_packages xorg-server xorg-apps xorg-xinit

# Install graphics packages
print_section "Installing graphics packages"
install_packages mesa mesa-demos libx11 libxtst

# Install display manager
print_section "Installing display manager"
install_packages lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings

# Install XFCE desktop environment
print_section "Installing XFCE desktop environment"
install_packages xfce4 xfce4-goodies

# Install browser
print_section "Installing browser"
install_packages librewolf

# If librewolf isn't available in the standard repos, provide alternative instructions
if [ $? -ne 0 ]; then
  print_warning "LibreWolf may not be available in the standard repositories"
  print_info "Installing Firefox as a fallback browser..."
  sudo pacman -S --needed --noconfirm firefox
  
  print_info "To install LibreWolf later, you can use the AUR:"
  print_info "1. Install an AUR helper like 'yay' or 'paru'"
  print_info "2. Run: yay -S librewolf"
fi

# Install theme packages
print_section "Installing theme packages"
install_packages adwaita-icon-theme papirus-icon-theme

# Install gruvbox-dark-gtk (may need AUR)
if ! pacman -Qs gruvbox-dark-gtk > /dev/null; then
  print_warning "gruvbox-dark-gtk may not be available in the standard repositories"
  
  # Check if yay is installed (AUR helper)
  if command -v yay >/dev/null 2>&1; then
    print_info "Installing gruvbox-dark-gtk from AUR using yay..."
    yay -S --noconfirm gruvbox-dark-gtk
    if [ $? -eq 0 ]; then
      print_success "Gruvbox Dark GTK theme installed successfully"
    else
      print_warning "Failed to install gruvbox-dark-gtk from AUR"
    fi
  else
    print_info "To install gruvbox-dark-gtk later:"
    print_info "1. Install an AUR helper like 'yay': pacman -S --needed git base-devel && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si"
    print_info "2. Run: yay -S gruvbox-dark-gtk"
    
    # Alternatively, install a similar theme from the official repos
    print_info "Installing Arc GTK theme as an alternative..."
    sudo pacman -S --needed --noconfirm arc-gtk-theme
  fi
fi

# Set up additional XFCE themes
print_section "Setting up additional XFCE themes"

# Create theme directories if they don't exist
mkdir -p "$HOME/.themes" "$HOME/.icons"

# Install Dracula theme if not present
if [ ! -d "$HOME/.themes/Dracula" ]; then
  print_info "Installing Dracula GTK theme..."
  git clone https://github.com/dracula/gtk.git /tmp/dracula-gtk
  mkdir -p "$HOME/.themes/Dracula"
  cp -r /tmp/dracula-gtk/gtk-2.0 /tmp/dracula-gtk/gtk-3.0 /tmp/dracula-gtk/gtk-4.0 "$HOME/.themes/Dracula/" 2>/dev/null
  rm -rf /tmp/dracula-gtk
  print_success "Dracula GTK theme installed"
fi

# Install Gruvbox-Plus icons if not present
if [ ! -d "$HOME/.icons/Gruvbox-Plus-Dark" ]; then
  print_info "Installing Gruvbox-Plus icon theme..."
  git clone https://github.com/SylEleuth/gruvbox-plus-icon-pack.git /tmp/gruvbox-plus
  cp -r /tmp/gruvbox-plus/Gruvbox-Plus-Dark "$HOME/.icons/"
  rm -rf /tmp/gruvbox-plus
  print_success "Gruvbox-Plus icon theme installed"
fi

# Enable the display manager
print_section "Enabling LightDM display manager"
sudo systemctl enable lightdm.service
print_success "LightDM enabled and will start at boot"

# Configure XFCE settings if XFCE is running
if pgrep xfce4-session &>/dev/null || [ "$XDG_CURRENT_DESKTOP" = "XFCE" ]; then
  print_section "Configuring XFCE settings"
  
  if command -v xfconf-query &>/dev/null; then
    # Set GTK theme
    xfconf-query -c xsettings -p /Net/ThemeName -s "Dracula"
    
    # Set icon theme
    xfconf-query -c xsettings -p /Net/IconThemeName -s "Gruvbox-Plus-Dark"
    
    # Set window manager theme
    xfconf-query -c xfwm4 -p /general/theme -s "Dracula"
    
    # Set decorations layout
    xfconf-query -c xsettings -p /Gtk/DecorationLayout -s "menu:minimize,maximize,close"
    
    # Enable compositing
    xfconf-query -c xfwm4 -p /general/use_compositing -s true
    
    # Set default terminal to Alacritty if installed
    if command -v alacritty &>/dev/null; then
      xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/Super_t" -s "alacritty" -n
    fi
    
    print_success "XFCE settings configured"
  else
    print_warning "xfconf-query not found, skipping XFCE settings configuration"
    print_info "XFCE settings can be configured manually through the XFCE Settings Manager"
  fi
else
  print_info "XFCE is not currently running"
  print_info "Settings will be applied on first login or can be manually configured through the XFCE Settings Manager"
fi

# Create or update .xinitrc
print_section "Configuring .xinitrc"
if [ ! -f "$HOME/.xinitrc" ] || ! grep -q "exec startxfce4" "$HOME/.xinitrc"; then
  # Backup existing .xinitrc if it exists
  if [ -f "$HOME/.xinitrc" ]; then
    cp "$HOME/.xinitrc" "$HOME/.xinitrc.backup"
    print_info "Existing .xinitrc backed up to .xinitrc.backup"
  fi
  
  # Create new .xinitrc or append to existing one
  echo '#!/bin/sh

# Start XFCE
exec startxfce4' > "$HOME/.xinitrc"
  
  chmod +x "$HOME/.xinitrc"
  print_success ".xinitrc configured to start XFCE"
else
  print_info ".xinitrc already configured for XFCE"
fi

# Stow XFCE and GTK configs if dotfiles repo exists
print_section "Checking for dotfiles to stow"
if [ -d "$HOME/dotfiles" ]; then
  print_info "Dotfiles repository found"
  
  cd "$HOME/dotfiles"
  
  # Check for XFCE and GTK configs in the dotfiles repo
  if [ -d "xfce4" ]; then
    print_info "Stowing XFCE config files..."
    stow -v xfce4
    print_success "XFCE config files stowed"
  else
    print_info "No XFCE config files found in dotfiles"
  fi
  
  if [ -d "gtk" ]; then
    print_info "Stowing GTK config files..."
    stow -v gtk
    print_success "GTK config files stowed"
  else
    print_info "No GTK config files found in dotfiles"
  fi
else
  print_info "No dotfiles repository found at ~/dotfiles"
  print_info "XFCE will use default settings"
fi

# Final message
print_section "XFCE Setup Complete!"
print_success "XFCE desktop environment has been installed and configured"
print_info "To start XFCE:"
print_info "1. Reboot your system to start the LightDM display manager"
print_info "   - Run: sudo reboot"
print_info "2. Or manually start X with the 'startx' command"
print_info "   - Run: startx"
print_info ""
print_info "You can customize XFCE further using the XFCE Settings Manager"
