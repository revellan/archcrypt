#!/bin/bash
var=$(echo "$1" | grep -o nvme)
if [ -z "$var" ];then
    cryptsetup open "${1}2" "$2"
else
    cryptsetup open "${1}p2" "$2"
fi
