#!/bin/bash
mountPoint="$1"
pacstrap -K "$mountPoint" base
echo -e "pacman -S --noconfirm linux linux-lts linux-headers linux-lts-headers linux-firmware base-devel sudo lvm2 rsync efibootmgr grub git networkmanager mkinitcpio\nexit" | arch-chroot "$mountPoint"