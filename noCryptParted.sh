#!/bin/bash
devSize="$1"
devName="$2"
rootSize="$3"
homeSize="$4"
swapSize="$5"
mountPoint="$6"
bootPartSize="3"
parted -s "$2" mklabel gpt
parted -s "$2" "mkpart efi fat32 777 ${bootPartSize}GB"
parted -s "$2" "set 1 esp on"
formatPartsFunction() {
    nvmeVar=$(echo "$devName" | grep -o nvme)
    if [ -z "$nvmeVar" ];then
        yes | mkfs.ext4 "${devName}2"
        if [ "$homeSize" != '0' ];then
            yes | mkfs.ext4 "${devName}3"
            if [ "$swapSize" != '0' ];then
                mkswap "${devName}4"
            fi
        elif [ "$swapSize" != '0' ];then
            mkswap "${devName}3"
        fi
        yes | mkfs.fat -F32 "${devName}1"
    else
        yes | mkfs.ext4 "${devName}p2"
        if [ "$homeSize" != '0' ];then
            yes | mkfs.ext4 "${devName}p3"
            if [ "$swapSize" != '0' ];then
                mkswap "${devName}p4"
            fi
        elif [ "$swapSize" != '0' ];then
            mkswap "${devName}p3"
        fi
        yes | mkfs.fat -F32 "${devName}p1"
    fi
}
mountPartsFunction() {
    nvmeVar=$(echo "$devName" | grep -o nvme)
    if [ -z "$nvmeVar" ];then
        mount --mkdir "${devName}2" "$mountPoint"
        if [ "$homeSize" != '0' ];then
            mount --mkdir "${devName}3" "${mountPoint}/home"
        fi
        mount --mkdir "${devName}1" "${mountPoint}/boot"
    else
        mount --mkdir "${devName}p2" "$mountPoint"
        if [ "$homeSize" != '0' ];then
            mount --mkdir "${devName}p3" "${mountPoint}/home"
        fi
        mount --mkdir "${devName}p1" "${mountPoint}/boot"
    fi
}
mkpartsfunction() {
    if [ "$rootSize" == 'ETL' ];then
        anotherVar=$(($homeSize + $swapSize))
        rootSizeVar=$(($devSize - $anotherVar))
        rootSizeA=$(($rootSizeVar - $bootPartSize))
        parted -s "$devName" "mkpart root ext4 ${bootPartSize}GB ${rootSizeA}GB"
        if [ "$homeSize" != '0' ];then
            parted -s "$devName" "mkpart home ext4 ${rootSizeA}GB $(($rootSizeA + $homeSize))GB"
        fi
        if [ "$swapSize" != '0' ];then
            parted -s "$devName" "mkpart swap linux-swap $(($rootSizeA + $homeSize))GB ${devSize}GB"
        fi
    elif [ "$homeSize" == 'ETL' ];then
        calcVarA=$(($devSize - $rootSize))
        calcVarB=$(($calcVarA - $swapSize))
        homeSizeA=$(($calcVarB - 3))
        brootSize=$(($bootPartSize + $rootSize))
        bromeSize=$(($brootSize + $homeSizeA))
        parted -s "$devName" "mkpart root ${bootPartSize}GB ${brootSize}GB"
        if [ "$homeSize" != '0' ];then
            parted -s "$devName" "mkpart home ${brootSize}GB ${bromeSize}GB"
        fi
        if [ "$swapSize" != '0' ];then
            parted -s "$devName" "mkpart swap ${bromeSize}GB ${devSize}GB"
        fi
    elif [ "$swapSize" == 'ETL' ];then
        brootSize=$(($bootPartSize + $rootSize))
        bromeSize=$(($brootSize + $homeSize))
        parted -s "$devName" "mkpart root ${bootPartSize}GB ${brootSize}GB"
        if [ "$homeSize" != '0' ];then
            parted -s "$devName" "mkpart home ${brootSize}GB ${bromeSize}GB"
        fi
        parted -s "$devName" "mkpart swap ${bromeSize}GB ${devSize}GB"
    fi
    parted -s "$devName" mkpart root 3GB
}
mkpartsfunction
echo "Formating Partitions ..."
formatPartsFunction >/dev/null
mountPartsFunction