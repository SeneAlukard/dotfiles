# Arch Linux Installation Guide

This comprehensive guide walks through installing Arch Linux, with optional dual-boot configuration and shared partitions.

## Pre-Installation Preparation

### 1. Download the Arch ISO
Download the latest Arch ISO from [archlinux.org](https://archlinux.org/download/).

### 2. Create a Bootable USB
Use tools like `dd`, Rufus, Balena Etcher, or Ventoy to create a bootable USB drive.

```sh
# Example using dd (be very careful with this command)
sudo dd bs=4M if=/path/to/archlinux.iso of=/dev/sdX status=progress oflag=sync
```

### 3. Boot from USB
- Insert the USB drive and restart your computer
- Enter BIOS/UEFI settings (usually by pressing F2, Delete, or another key during startup)
- Set boot priority to the USB drive
- Save and exit

## Initial Setup in Live Environment

### 1. Verify Boot Mode
Confirm if you're in UEFI mode:

```sh
ls /sys/firmware/efi/efivars
```
If the directory exists and files are listed, you're in UEFI mode.

### 2. Connect to Wi-Fi (if needed)
Unblock wireless if necessary:
```sh
sudo rfkill unblock wifi
```

Connect using `iwctl`:
```sh
iwctl
```

Inside the `iwctl` prompt:
```
device list                           # List wireless devices
station wlan0 scan                    # Scan for networks (replace wlan0 with your device)
station wlan0 get-networks            # Show available networks
station wlan0 connect "NetworkName"   # Connect to a network
```

For hidden networks:
```
station wlan0 connect-hidden "NetworkName"
```

When prompted, enter your password. Then exit `iwctl` by typing `exit`.

Verify connection:
```sh
ping -c 3 archlinux.org
```

### 3. Update System Clock
```sh
timedatectl set-ntp true
```

## Disk Partitioning

### 1. Identify Disks
```sh
lsblk
fdisk -l
```

### 2. Partition the Disk

For a new install or single-boot system:
```sh
fdisk /dev/sda   # Replace with your drive
```

In fdisk, create partitions according to your needs:
- EFI System Partition (if UEFI): 300-500MB, type EFI
- Swap partition: 1-2x RAM size
- Root partition: 25-50GB
- Home partition: Remaining space

For dual-boot or specific partition layout (like sharing a home partition):
```sh
# Example partitioning for sharing partitions
# In this example, /dev/sda8 will be the root partition for the new Arch installation
# /dev/sda9 is an existing /home partition
# /dev/sdaX is an existing swap partition
```

### 3. Format Partitions

For a new installation:
```sh
# Format EFI partition (if needed)
mkfs.fat -F32 /dev/sda1

# Create and enable swap
mkswap /dev/sda2
swapon /dev/sda2

# Format root partition
mkfs.btrfs /dev/sda3  # Or mkfs.btrfs for BTRFS

# Format home partition
mkfs.btrfs /dev/sda4  # Or mkfs.btrfs for BTRFS
```

For a dual-boot system sharing partitions:
```sh
# Format only the root partition
mkfs.btrfs /dev/sda8

# Activate existing swap (if any)
swapon /dev/sdaX
```

### 4. Mount Partitions

For a new installation:
```sh
# Mount root partition
mount /dev/sda3 /mnt

# Create and mount other directories
mkdir -p /mnt/boot/efi
mkdir -p /mnt/home
mount /dev/sda1 /mnt/boot/efi
mount /dev/sda4 /mnt/home
```

For dual-boot with shared partitions:
```sh
# Mount root partition
mount /dev/sda8 /mnt

# Mount existing home (if shared)
mkdir -p /mnt/home
mount /dev/sda9 /mnt/home

# Mount EFI partition if needed
mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

# Mount Windows EFI Partition if needed
mkdir -p /mnt/windows
mount /dev/sdaX /mnt/windows
```

## Install Base System

### 1. Install Essential Packages
##  1.1 Base Linux Kernel

```sh
# For regular kernel
pacstrap /mnt base linux linux-firmware base-devel efibootmgr grub os-prober\
  sudo vim \
  iproute2 \
  systemd-resolvconf \
  wpa_supplicant \
  dialog \
  dhcpcd \
  iw \
  wireless_tools \
  crda \
  wireless-regdb
```
## 1.2 Linux LTS Kernel
```sh
# For LTS kernel
pacstrap /mnt base linux-lts linux-firmware base-devel efibootmgr grub os-prober \ 
  sudo vim \
  iproute2 \
  systemd-resolvconf \
  wpa_supplicant \
  dialog \
  dhcpcd \
  iw \
  wireless_tools \
  crda \
  wireless-regdb
```

### 2. Generate Fstab
```sh
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab  # Verify the file
```

## Configure the System

### 1. Chroot into the New System
```sh
arch-chroot /mnt
```

### 2. Set Timezone
```sh
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
```

Replace `Region/City` with your timezone (e.g., `Europe/Istanbul`).

### 3. Set Locale
```sh
# Edit /etc/locale.gen and uncomment needed locales
vim /etc/locale.gen

# Generate locales
locale-gen

# Create /etc/locale.conf
echo "LANG=en_US.UTF-8" > /etc/locale.conf
```

### 4. Set Keymap (optional)
```sh
echo "KEYMAP=us" > /etc/vconsole.conf
```

### 5. Network Configuration
```sh
# Set hostname
echo "myhostname" > /etc/hostname

# Configure hosts file
cat > /etc/hosts << EOF
127.0.0.1     localhost
::1           localhost
127.0.1.1     myhostname.localdomain    myhostname
EOF
```

Replace `myhostname` with your chosen hostname.

### 6. Set Root Password
```sh
passwd
```

### 7. Create User Account
```sh
# Create user with home directory
useradd -m -G wheel -s /bin/bash username

# Set password
passwd username

# Configure sudo
EDITOR=vim visudo
```

Uncomment `%wheel ALL=(ALL) ALL` to allow members of the wheel group to use sudo.

### 8. Install and Configure Boot Loader
```sh
# Install GRUB for UEFI
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB

# Enable OS detection for dual boot
echo "GRUB_DISABLE_OS_PROBER=false" >> /etc/default/grub

# Generate GRUB config
grub-mkconfig -o /boot/grub/grub.cfg
```

### 9. Enable NetworkManager
```sh
systemctl enable NetworkManager
```

## Post-Installation

### 1. Exit and Reboot
```sh
exit            # Exit chroot
umount -R /mnt  # Unmount all partitions
reboot
```

### 2. First Boot Configuration

After rebooting:

1. Login with your username and password
2. Connect to Wi-Fi (if needed)
   ```sh
   nmcli device wifi list
   nmcli device wifi connect "SSID" password "password"
   ```
3. Update the system
   ```sh
   sudo pacman -Syu
   ```
4. Run the setup script
   ```sh
   git clone https://github.com/yourusername/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   chmod +x setup.sh
   ./setup.sh
   ```

## Troubleshooting

### Boot Issues in Dual-Boot
If GRUB doesn't show all operating systems, run:
```sh
sudo os-prober
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### Wi-Fi Issues
If Wi-Fi isn't working properly, ensure the proper drivers are installed:
```sh
sudo pacman -S linux-firmware
```

For specific cards, you might need additional packages:
```sh
# For Broadcom cards
sudo pacman -S broadcom-wl-dkms
# For Intel cards
sudo pacman -S intel-ucode
```

### Graphics Driver Issues
For NVIDIA graphics:
```sh
sudo pacman -S nvidia nvidia-utils
```

For AMD graphics:
```sh
sudo pacman -S xf86-video-amdgpu
```

For Intel graphics:
```sh
sudo pacman -S xf86-video-intel
```

## Next Steps

After basic installation, run the included `setup.sh` script to configure your desktop environment and install additional software. The script will set up:

1. Xfce desktop environment
2. Shell configuration (Zsh with plugins)
3. Neovim with custom configurations
4. Alacritty terminal emulator
5. Tmux with custom configurations
6. And more!


