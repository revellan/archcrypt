#!/bin/bash
parted -s "$2" mklabel gpt
echo -e "mkpart efi fat32 777 3GB\nmkpart ${3} ext4 3GB ${1}GB\nset 1 esp on\nquit" | parted "$2" >/dev/null