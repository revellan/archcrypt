#!/bin/bash
devName="$1"
cryptName="$2"
vgName="$3"
lvmVar="$4"
mountPoint="$5"
var=$(echo "$devName" | grep -o nvme)
if [ -z "$var" ];then
    cryptPartName="${devName}2"
else
    cryptPartName="${devName}p2"
fi
getFSID() {
	lsblk -fn "$1" | grep "$(echo $1 | cut -d '/' -f3)" | awk '{print $4}'
}
echoFunctionGrub() {
    echo -e "GRUB_DEFAULT=saved\nGRUB_TIMEOUT=5\nGRUB_DISTRIBUTOR=\"Arch\"\nGRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\""
}
echoFunctionGrub2() {
    echo -e "GRUB_PRELOAD_MODULES=\"part_gpt part_msdos\"\nGRUB_ENABLE_CRYPTODISK=y\nGRUB_TIMEOUT_STYLE=menu\nGRUB_TERMINAL_INPUT=console\nGRUB_GFXMODE=auto\nGRUB_GFXPAYLOAD_LINUX=keep\nGRUB_DISABLE_RECOVERY=true\nGRUB_SAVEDEFAULT=true\nGRUB_DISABLE_SUBMENU=y"
}
if [ "$lvmVar" == 'False' ];then
    echoFunctionGrub > "${mountPoint}/etc/default/grub"
    echo "GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(getFSID "${cryptPartName}"):${cryptName} root=/dev/mapper/${cryptName}\"" >> "${mountPoint}/etc/default/grub"
    echoFunctionGrub2 >> "${mountPoint}/etc/default/grub"
else
    echoFunctionGrub > "${mountPoint}/etc/default/grub"
    echo "GRUB_CMDLINE_LINUX=\"cryptdevice=UUID=$(getFSID "${cryptPartName}"):${cryptName} root=/dev/${vgName}/root\"" >> "${mountPoint}/etc/default/grub"
    echoFunctionGrub2 >> "${mountPoint}/etc/default/grub"
fi
