#!/bin/bash
mountPoint="$1"
lvmVar="$2"
if [ "$lvmVar" == 'False' ];then
    echo -e "MODULES=()\nBINARIES=()\nFILES=()\nHOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck)" > "${mountPoint}/etc/mkinitcpio.conf"
else
    echo -e "MODULES=()\nBINARIES=()\nFILES=()\nHOOKS=(base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt lvm2 filesystems fsck)" > "${mountPoint}/etc/mkinitcpio.conf"
fi