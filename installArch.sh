#!/bin/bash
# Arch Linux Post-Chroot Setup Script
# This script automates the configuration steps after arch-chroot

# Exit on any error
set -e

# Text formatting
BOLD='\033[1m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Function to print status messages
print_status() {
    echo -e "\n${BLUE}${BOLD}>> $1${NC}"
}

# Function to print success messages
print_success() {
    echo -e "\n${GREEN}${BOLD}✓ $1${NC}"
}

# Function to print error messages
print_error() {
    echo -e "\n${RED}${BOLD}✗ $1${NC}"
    exit 1
}

# Display welcome message
echo -e "${BOLD}===============================================${NC}"
echo -e "${BOLD}  Arch Linux Post-Chroot Setup Script${NC}"
echo -e "${BOLD}===============================================${NC}"
echo -e "This script will configure your new Arch Linux system."
echo -e "You will be prompted for necessary information."
echo ""

# Get hostname
read -p "Enter hostname: " HOSTNAME
if [ -z "$HOSTNAME" ]; then
    print_error "Hostname cannot be empty"
fi

# Get username
read -p "Enter username: " USERNAME
if [ -z "$USERNAME" ]; then
    print_error "Username cannot be empty"
fi

# Get timezone
print_status "Setting up timezone"
echo "Common timezones: America/New_York, Europe/London, Asia/Tokyo, etc."
read -p "Enter your timezone (e.g., Europe/Istanbul): " TIMEZONE
if [ -z "$TIMEZONE" ]; then
    print_error "Timezone cannot be empty"
fi

# Get locale
print_status "Setting up locale"
read -p "Enter your locale (default: en_US.UTF-8): " LOCALE
LOCALE=${LOCALE:-en_US.UTF-8}

# Get keymap
print_status "Setting up keymap"
read -p "Enter your keymap (default: us): " KEYMAP
KEYMAP=${KEYMAP:-us}

# Set timezone
print_status "Setting timezone to $TIMEZONE"
if ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime; then
    print_success "Timezone set successfully"
else
    print_error "Failed to set timezone. Make sure it's a valid timezone."
fi

# Set hardware clock
print_status "Setting hardware clock to UTC"
hwclock --systohc
print_success "Hardware clock set successfully"

# Set locale
print_status "Configuring locale"
sed -i "s/^#$LOCALE/$LOCALE/" /etc/locale.gen
locale-gen
echo "LANG=$LOCALE" > /etc/locale.conf
print_success "Locale configured successfully"

# Set keymap
print_status "Setting keymap to $KEYMAP"
echo "KEYMAP=$KEYMAP" > /etc/vconsole.conf
print_success "Keymap set successfully"

# Set hostname
print_status "Setting hostname to $HOSTNAME"
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts << EOF
127.0.0.1     localhost
::1           localhost
127.0.1.1     $HOSTNAME.localdomain    $HOSTNAME
EOF
print_success "Hostname set successfully"

# Set root password
print_status "Setting root password"
echo "Setting password for root user"
until passwd; do
    echo "Please try again"
done
print_success "Root password set successfully"

# Create user account
print_status "Creating user $USERNAME"
useradd -m -G wheel -s /bin/bash "$USERNAME"
echo "Setting password for $USERNAME"
until passwd "$USERNAME"; do
    echo "Please try again"
done
print_success "User account created successfully"

# Configure sudo
print_status "Configuring sudo"
sed -i '/%wheel ALL=(ALL) ALL/s/^# //' /etc/sudoers
print_success "Sudo configured successfully"

# Install and configure boot loader
print_status "Installing and configuring GRUB"
if [ -d "/sys/firmware/efi" ]; then
    # UEFI system
    print_status "Detected UEFI system"
    grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB
else
    # BIOS system
    print_status "Detected BIOS system"
    read -p "Enter your disk device (e.g., /dev/sda): " DISK
    if [ -z "$DISK" ]; then
        print_error "Disk device cannot be empty"
    fi
    grub-install --target=i386-pc "$DISK"
fi

# Configure GRUB for OS detection
print_status "Configuring GRUB for OS detection"
sed -i 's/^#GRUB_DISABLE_OS_PROBER=false/GRUB_DISABLE_OS_PROBER=false/' /etc/default/grub
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub

# Generate GRUB config
print_status "Generating GRUB configuration"
grub-mkconfig -o /boot/grub/grub.cfg
print_success "GRUB installed and configured successfully"

# Network configuration will be handled by a separate script
print_status "Skipping network configuration as it will be handled separately"
print_success "Network setup step skipped"

# Ask for additional packages
print_status "Additional packages installation"
read -p "Would you like to install Xorg and a desktop environment? (y/n): " INSTALL_DE
if [[ "$INSTALL_DE" =~ ^[Yy]$ ]]; then
    print_status "Which desktop environment would you like to install?"
    echo "1) Xfce (lightweight)"
    echo "2) GNOME"
    echo "3) KDE Plasma"
    echo "4) i3 (window manager)"
    echo "5) None"
    read -p "Enter your choice [1-5]: " DE_CHOICE
    
    case $DE_CHOICE in
        1)
            print_status "Installing Xfce"
            pacman -S --noconfirm xorg xfce4 xfce4-goodies lightdm lightdm-gtk-greeter
            systemctl enable lightdm
            print_success "Xfce installed and configured"
            ;;
        2)
            print_status "Installing GNOME"
            pacman -S --noconfirm xorg gnome gnome-extra gdm
            systemctl enable gdm
            print_success "GNOME installed and configured"
            ;;
        3)
            print_status "Installing KDE Plasma"
            pacman -S --noconfirm xorg plasma kde-applications sddm
            systemctl enable sddm
            print_success "KDE Plasma installed and configured"
            ;;
        4)
            print_status "Installing i3"
            pacman -S --noconfirm xorg i3-wm i3status i3lock dmenu lightdm lightdm-gtk-greeter
            systemctl enable lightdm
            print_success "i3 installed and configured"
            ;;
        5)
            print_status "Skipping desktop environment installation"
            ;;
        *)
            print_status "Invalid choice, skipping desktop environment installation"
            ;;
    esac
fi

# Final instructions
print_status "Installation completed successfully"
echo -e "${BOLD}Next steps:${NC}"
echo "1. Exit the chroot environment: exit"
echo "2. Unmount all partitions: umount -R /mnt"
echo "3. Reboot: reboot"
echo ""
echo -e "${BOLD}After rebooting:${NC}"
echo "1. Log in with your new user account"
echo "2. Run your network configuration script"
echo "3. Update the system: sudo pacman -Syu"
echo ""
echo -e "${BOLD}===============================================${NC}"
echo -e "${BOLD}  Installation completed successfully!${NC}"
echo -e "${BOLD}===============================================${NC}"
