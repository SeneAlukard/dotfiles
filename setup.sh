#!/bin/bash

# Variables
DOTFILES_DIR="$HOME/dotfiles"
REPO_URL="git@github.com:SeneAlukard/dotfiles.git"
SIMULATE=false # Set to true to simulate the setup without making changes
WIFI_INTERFACE="wlp0s20f3"
SSID="merkur"
WIFI_PASSWORD="yozgat1322"
NETWORKD_CONFIG="/etc/systemd/network/merkur.network"

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

# Step 1: Install Essential Tools
echo "Installing required tools..."
install_if_missing "git"
install_if_missing "curl"
install_if_missing "unzip"
install_if_missing "wpa_supplicant"
install_if_missing "systemd-networkd"
install_if_missing "systemd-resolved"
install_if_missing "stow"
install_if_missing "nano"
install_if_missing "lightdm"
install_if_missing "lightdm-gtk-greeter"

# Step 2: Configure Wi-Fi and systemd-networkd
echo "Configuring Wi-Fi with wpa_supplicant..."
wpa_passphrase "$SSID" "$WIFI_PASSWORD" | sudo tee /etc/wpa_supplicant/wpa_supplicant-${WIFI_INTERFACE}.conf > /dev/null
sudo chmod 600 /etc/wpa_supplicant/wpa_supplicant-${WIFI_INTERFACE}.conf

# Create systemd-networkd configuration if not exists
echo "Configuring systemd-networkd..."
if [ ! -f "$NETWORKD_CONFIG" ]; then
  sudo bash -c "cat > $NETWORKD_CONFIG" <<EOL
[Match]
Name=$WIFI_INTERFACE

[Network]
DHCP=yes

[DHCP]
UseDNS=yes
EOL
fi

# Enable systemd-networkd and resolved
sudo systemctl enable --now systemd-networkd
sudo systemctl enable --now systemd-resolved

# Enable wpa_supplicant
sudo systemctl enable --now wpa_supplicant@${WIFI_INTERFACE}.service

# Enable LightDM
echo "Enabling LightDM for GUI login..."
sudo systemctl enable --now lightdm

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

# Step 5: Stow Nix Configuration
echo "Symlinking Nix configuration..."
perform_action "cd $DOTFILES_DIR && stow nix"

# Step 6: Apply Nix Configuration
echo "Applying Nix configuration..."
home-manager switch

# Step 7: Stow All Dotfiles
echo "Creating symlinks for all configurations..."
perform_action "cd $DOTFILES_DIR && stow xfce4 gtk3 gtk4 icons themes nvim alacritty zsh tmux"

# Final Message
echo "Setup complete! Your environment has been configured. Reboot to start XFCE4 with LightDM."
if [ "$SIMULATE" = true ]; then
  echo "This was a simulation. No changes were made."
fi

