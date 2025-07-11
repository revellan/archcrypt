#!/bin/bash
var=$(echo "$1" | grep -o nvme)
if [ -z "$var" ];then
    mount --mkdir "${1}1" "${2}/boot"
else
    mount --mkdir "${1}p1" "${2}/boot"
fi