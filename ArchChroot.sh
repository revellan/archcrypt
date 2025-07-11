#!/bin/bash
mountPoint="$1"
keymap="$2"
hostname="$3"
username="$4"
oldHome="$5"
closeCryptDevice="$6"
vgName="$7"
cryptPartName="$8"
executable="$9"
echo "en_US.UTF-8 UTF-8" > "$mountPoint"/etc/locale.gen
echo "LANG=en_US.UTF-8" > "$mountPoint"/etc/locale.conf
echo "KEYMAP=${keymap}" > "$mountPoint"/etc/vconsole.conf
echo "$hostname" > "$mountPoint"/etc/hostname
echo -e "locale-gen\nln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime\nhwclock --systohc\nmkinitcpio -P\ngrub-install --target=x86_64-efi --efi-directory=/boot --recheck\ngrub-mkconfig -o /boot/grub/grub.cfg\nsystemctl enable NetworkManager\nexit" | arch-chroot "$mountPoint"
if [ "$username" != 'ZERO' ];then
    echo -e "root ALL=(ALL:ALL) ALL\n%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > "${mountPoint}/etc/sudoers.d/basicConfiguration"
    echo -e "groupadd ${username}\nuseradd -g ${username} -G wheel ${username}\necho -e \"root\\\\nroot\" | passwd\necho -e \"pass\\\\npass\" | passwd ${username}\ncd /opt\ngit clone https://aur.archlinux.org/yay-bin.git\nchown -R ${username}:${username} /opt/yay-bin\necho -e \"cd /opt/yay-bin\\\\nyes | makepkg -si\\\\nexit\" | su ${username}\necho -e \"yay -Syu --noconfirm\\nexit\" | su ${username}\nexit" | arch-chroot "$mountPoint"
    if [ "$oldHome" != 'ZERO' ];then
        rsync -rv "$oldHome" "${mountPoint}/home/${username}"
	echo -e "chown -R ${username}:${username} \"/home/${username}\"" | arch-chroot "$mountPoint"
    fi
fi
if [ "$executable" != 'ZERO' ];then
    cat "$executable" > "${mountPoint}/executableArchInstall.tmp"
    echo -e "echo -e \"sh /executableArchInstall.tmp\\nexit\" | su ${username}" | arch-chroot "$mountPoint"
    rm "${mountPoint}/executableArchInstall.tmp"
fi
if [ "$closeCryptDevice" == 'True' ];then
    localvar=$(fuser -m "$mountPoint" | awk '{print $1}')
    if [ -n "$localvar" ];then
        kill -SIGTERM "$localvar"
    fi
    umount -R "$mountPoint"
    vgchange -a n "$vgName"
    cryptsetup close "$cryptPartName"
fi
