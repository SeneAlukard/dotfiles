
# Installing Arch Linux on `/dev/sda8` and Sharing `/home` & `swap`

This guide shows how to install Arch Linux on `/dev/sda8` alongside an existing system and share `/home` and `swap`.

1. **Boot from Arch Live ISO**
Download the Arch ISO, write it to a USB, and boot the live system.

2. **Format and Mount Partitions**
```sh
mkfs.btrfs /dev/sda8
mount /dev/sda8 /mnt
mount /dev/sda9 /mnt/home
swapon /dev/sdaX  # If swap exists
```

3. **Install Base System**
```sh
pacstrap /mnt base linux linux-firmware
```
For LTS kernel:
```sh
pacstrap /mnt base linux-lts linux-firmware
```

4. **Generate Fstab**
```sh
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab
```

5. **Chroot into New System**
```sh
arch-chroot /mnt
```

6. **Configure Basic Settings**
```sh
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
echo "arch-second" > /etc/hostname
```
Localization:
```sh
echo "LANG=en_US.UTF-8" > /etc/locale.conf
locale-gen
```
Set root password:
```sh
passwd
```

7. **Create User Account**
```sh
useradd -m -G wheel -s /bin/zsh xkenshi
passwd xkenshi
```
Grant sudo:
```sh
pacman -S sudo
echo "xkenshi ALL=(ALL) ALL" >> /etc/sudoers
```

8. **Update GRUB**
```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

9. **Reboot and Test**
```sh
exit
umount -R /mnt
reboot
```
If the new system doesn’t show, run:
```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

**Result**
- Two Arch Linux systems working.
- Shared `/home` and `swap`.

---

**Wi-Fi Unblock for iwctl**
To unblock Wi-Fi:
```sh
sudo rfkill unblock wifi
```

