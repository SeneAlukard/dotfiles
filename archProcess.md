# Arch Linux'u `/dev/sda8` Üzerine Kurma ve `/home` & `swap` Paylaşma

Bu kılavuz, mevcut Arch Linux kurulumunun yanına `/dev/sda8` üzerine ikinci bir Arch Linux kurulumu yapmayı ve `/home` ile `swap` bölümlerini paylaşmayı açıklar.

## **1. Arch Linux Live ISO ile Boot Et**
Arch Linux Live ISO'yu indir, USB'ye yazdır ve canlı sisteme boot et.

## **2. Bölümleri Formatla ve Mount Et**
Yeni Arch Linux sistemini kurmak için `/dev/sda8`'i formatla ve bağla:
```sh
mkfs.btrfs /dev/sda8
mount /dev/sda8 /mnt
```

Mevcut `/home` bölümünü bağla:
```sh
mount /dev/sda9 /mnt/home
```

Swap bölümü varsa etkinleştir:
```sh
swapon /dev/sdaX  # Swap bölümünü kullan
```

## **3. Temel Sistemi Kur**
```sh
pacstrap /mnt base linux linux-firmware
```
Alternatif olarak LTS kernel kullanmak istersen:
```sh
pacstrap /mnt base linux-lts linux-firmware
```

## **4. Fstab Dosyasını Oluştur**
```sh
genfstab -U /mnt >> /mnt/etc/fstab
cat /mnt/etc/fstab  # Kontrol et
```
Burada `/home` ve `swap` bölümlerinin listelendiğinden emin ol.

## **5. Yeni Sisteme Chroot Yap**
```sh
arch-chroot /mnt
```

## **6. Temel Sistem Ayarlarını Yap**
```sh
ln -sf /usr/share/zoneinfo/Region/City /etc/localtime
hwclock --systohc
echo "arch-second" > /etc/hostname
```
Lokalizasyon:
```sh
echo "LANG=en_US.UTF-8" > /etc/locale.conf
echo "KEYMAP=us" > /etc/vconsole.conf
locale-gen
```
Root şifresini belirle:
```sh
passwd
```

## **7. Kullanıcı Hesabını Ayarla**
```sh
useradd -m -G wheel -s /bin/zsh xkenshi
passwd xkenshi
```
Sudo erişimi ver:
```sh
pacman -S sudo
echo "xkenshi ALL=(ALL) ALL" >> /etc/sudoers
```

## **8. GRUB’u Güncelle**
Mevcut EFI bölümü ile uğraşmaya gerek yok. Sadece eski Arch sistemin GRUB ayarlarını güncelle:
```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```
Bu işlem yeni Arch Linux kurulumunu GRUB menüsüne ekleyecektir.

## **9. Reboot ve Test**
```sh
exit
umount -R /mnt
reboot
```
GRUB menüsünde yeni Arch Linux girişinin olup olmadığını kontrol et.

Eğer GRUB yeni sistemi görmezse, ilk Arch Linux’a girip şu komutu çalıştır:
```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## **Sonuç**
✅ **İki Arch Linux sistemi çalışır durumda olacak.**
✅ **Aynı `/home` dizinini paylaşacaklar.**
✅ **Aynı `swap` bölümünü kullanacaklar.**

Bir hata alırsan veya ekleme yapmak istersen detaylı bilgiyi paylaşabilirsin. 🚀


