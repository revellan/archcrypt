#!/bin/bash
var=$(echo "$1" | grep -o nvme)
if [ -z "$var" ];then
    mkfs.fat -F 32 "${1}1"
    cryptsetup luksFormat "${1}2"
else
    mkfs.fat -F 32 "${1}p1"
    cryptsetup luksFormat "${1}p2"
fi