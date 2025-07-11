#!/bin/bash
mountPoint="$1"
echoFunctionGrub() {
    echo -e "GRUB_DEFAULT=saved\nGRUB_TIMEOUT=5\nGRUB_DISTRIBUTOR=\"Arch\"\nGRUB_CMDLINE_LINUX_DEFAULT=\"loglevel=3 quiet\"\nGRUB_CMDLINE_LINUX=\"\"\nGRUB_PRELOAD_MODULES=\"part_gpt part_msdos\"\nGRUB_TIMEOUT_STYLE=menu\nGRUB_TERMINAL_INPUT=console\nGRUB_GFXMODE=auto\nGRUB_GFXPAYLOAD_LINUX=keep\nGRUB_DISABLE_RECOVERY=true\nGRUB_SAVEDEFAULT=true\nGRUB_DISABLE_SUBMENU=y"
}
echo "Installing Grub ..."
echoFunctionGrub > "${mountPoint}/etc/default/grub"