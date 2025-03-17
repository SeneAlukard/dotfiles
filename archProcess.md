
# Installing Arch Linux on `/dev/sda8` and Sharing `/home` & `swap`

This guide shows how to install Arch Linux on `/dev/sda8` alongside an existing system and share `/home` and `swap`.

### 1. **Boot from Arch Live ISO**
Download the Arch ISO, write it to a USB, and boot the live system.

### 2. **Wi-Fi Unblock for iwctl and Connecting to Hidden Network**
To unblock Wi-Fi, run:
```sh
sudo rfkill unblock wifi
```

Next, to connect to a hidden Wi-Fi network using `iwctl`:

1. Enter `iwctl`:
   ```sh
   iwctl
   ```

2. Scan for available networks:
   ```sh
   station wlan0 scan
   ```

3. Connect to the hidden network by specifying the SSID:
   ```sh
   station wlan0 connect-hidden YourNetworkName
   ```

4. If prompted, enter the Wi-Fi password.

5. Verify the connection:
   ```sh
   station wlan0 show
   ```

### 3. **Format and Mount Partitions**
Format and mount the partitions:
```sh
mkfs.btrfs /dev/sda8
mount /dev/sda8 /mnt
mount /dev/sda9 /mnt/home
swapon /dev/sdaX  # If swap exists
```

For LTS kernel:
```sh
pacstrap /mnt base linux-lts linux-firmware efibootmgr grub os-prober iw wpa_supplicant systemd-networkd
```

### 4. **Generate Fstab**
Generate the `fstab` file:
```sh
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
```

### 5. **Chroot into New System**
Chroot into the newly installed system:
```sh
arch-chroot /mnt
```

### 6. **Configure Basic Settings**
Configure basic system settings, including timezone and hostname:
```sh
ln -sf /usr/share/zoneinfo/Europe/Istanbul /etc/localtime
hwclock --systohc
echo "arch-second" > /etc/hostname
```

Localization settings:
```sh
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
locale-gen
```

Set the root password:
```sh
passwd
```

### 7. **Create User Account**
Create a new user account and set a password:
```sh
useradd -m -G wheel -s /bin/zsh xkenshi
passwd xkenshi
```

Grant sudo access:
```sh
pacman -S sudo
echo "xkenshi ALL=(ALL) ALL" >> /etc/sudoers
```

### 8. **Update GRUB**
Update GRUB settings:
```sh
modify /etc/default/grub ==> GRUB_DISABLE_OS_PROBER=false
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

### 9. **Reboot and Test**
Exit the chroot environment, unmount the system, and reboot:
```sh
exit
umount -R /mnt
reboot
```

If the new system doesn’t show in GRUB, run:
```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

---

### **Result**
- Two Arch Linux systems working.
- Shared `/home` and `swap`.

---

### **Wi-Fi Unblock for iwctl**

To unblock Wi-Fi:
```sh
sudo rfkill unblock wifi
```

Now, connect to a hidden Wi-Fi network using `iwctl`:

1. Enter `iwctl`:
   ```sh
   iwctl
   ```

2. Scan for available networks:
   ```sh
   station wlan0 scan
   ```

3. Connect to the hidden network:
   ```sh
   station wlan0 connect-hidden YourNetworkName
   ```

4. If prompted, enter the Wi-Fi password.

5. Verify the connection:
   ```sh
   station wlan0 show
   ```

