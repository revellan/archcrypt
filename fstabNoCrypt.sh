#!/bin/bash
mountPoint="$1"
devName="$2"
swapPartN="$3"
if [ "$swapPartN" != "0" ];then
    var=$(echo "$devName" | grep -o nvme)
    if [ -z "$var" ];then
        swapPart=${devName}${swapPartN}
    else
        swapPart=${devName}p${swapPartN}
    fi
fi
echo -e "# Static information about the filesystems.\n# See fstab(5) for details.\n\n# <file system> <dir> <type> <options> <dump> <pass>" > "${mountPoint}/etc/fstab"
getFSID() {
    lsblk -fno UUID "$1"
}
genfstab -U "$mountPoint" | grep -C2 "$devName" >> "${mountPoint}/etc/fstab"
if [ "$swapPartN" != '0' ];then
    swapUUID=$(getFSID "$swapPart")
    echo -e "# $swapPart\nUUID=${swapUUID} none swap defaults 0 0\n" >> "${mountPoint}/etc/fstab"
fi