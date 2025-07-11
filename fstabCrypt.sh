#!/bin/bash
vgName="$1"
devName="$2"
mountPoint="$3"
homeSize="$4"
swapSize="$5"
getFSID() {
    lsblk -fno UUID "$1"
}
echo -e "# Static information about the filesystems.\n# See fstab(5) for details.\n\n# <file system> <dir> <type> <options> <dump> <pass>" > "${mountPoint}/etc/fstab"
echo -e "# /dev/${vgName}/root\nUUID=$(getFSID /dev/${vgName}/root) / ext4 rw,relatime 0 1\n" >> "${mountPoint}/etc/fstab"
if [ "$homeSize" != 'ZERO' ];then
    echo -e "# /dev/${vgName}/home\nUUID=$(getFSID /dev/${vgName}/home) /home ext4 rw,relatime 0 2\n" >> "${mountPoint}/etc/fstab"
fi
var=$(echo "$devName" | grep -o nvme)
if [ -z "$var" ];then
    echo -e "# ${devName}1\nUUID=$(getFSID ${devName}1) /boot vfat defaults 0 2\n" >> "${mountPoint}/etc/fstab"
else
    echo -e "# ${devName}p1\nUUID=$(getFSID ${devName}p1) /boot vfat defaults 0 2\n" >> "${mountPoint}/etc/fstab"
fi
if [ "$swapSize" != 'ZERO' ];then
    echo -e "# /dev/${vgName}/swap\nUUID=$(getFSID /dev/${vgName}/swap) none swap defaults 0 0\n" >> "${mountPoint}/etc/fstab"
fi