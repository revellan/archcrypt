#!/bin/bash
rootSize=${2}
homeSize=${3}
swapSize=${4}
vgName=${5}
mountPoint=${6}
pvcreate "/dev/mapper/${1}"
vgcreate "$vgName" "/dev/mapper/${1}"
mkFileSystems() {
	localvar="${1}Size"
	if [ "${!localvar}" != 'ZERO' ];then
		mkfs.ext4 "/dev/${vgName}/${1}" >/dev/null
	fi
}
rootSizef() {
	if [ "$rootSize" != "ZERO" ];then
		if [ "$1" == "0" ];then
			lvcreate -L "${rootSize}G" -n root "$vgName"
		elif [ "$1" == "1" ];then
			lvcreate -l 100%FREE -n root "$vgName"
		fi
	fi
}
homeSizef() {
	if [ "$homeSize" != "ZERO" ];then
		if [ "$1" == "0" ];then
			lvcreate -L "${homeSize}G" -n home "$vgName"
		elif [ "$1" == "1" ];then
			lvcreate -l 100%FREE -n home "$vgName"
		fi
	fi
}
swapSizef() {
	if [ "$swapSize" != "ZERO" ];then
		lvcreate -l 100%FREE -n swap "$vgName"
		mkswap "/dev/${vgName}/swap"
	fi
}
if [ "$rootSize" == 'ETL' ];then
	rootSizef "1" >/dev/null
	if [ "$swapSize" != 'ZERO' ] && [ "$homeSize" != 'ZERO' ];then
		homeSwapSize=$(($homeSize + $swapSize))
		lvreduce -L "-${homeSwapSize}G " "${vgName}/root" >/dev/null
	elif [ "$swapSize" != 'ZERO' ];then
		lvreduce -L "-${swapSize}G" "${vgName}/root" >/dev/null
	elif [ "$homeSize" != 'ZERO' ];then
		lvreduce -L "-${homeSize}G " "${vgName}/root" >/dev/null
	fi
	mkFileSystems root 
	mount --mkdir "/dev/${vgName}/root" "${mountPoint}"
	homeSizef "0" >/dev/null
	mkFileSystems home
	mount --mkdir "/dev/${vgName}/home" "${mountPoint}/home"
	swapSizef "0" >/dev/null
elif [ "$homeSize" == 'ETL' ];then
	rootSizef "0" >/dev/null
	mkFileSystems root
	mount --mkdir "/dev/${vgName}/root" "${mountPoint}"
	homeSizef "1" >/dev/null
	if [ "$swapSize" != 'ZERO' ];then lvreduce -L "-${swapSize}G" "${vgName}/home" >/dev/null;fi
	mkFileSystems home
	mount --mkdir "/dev/${vgName}/home" "${mountPoint}/home"
	swapSizef "0" >/dev/null
elif [ "$swapSize" == 'ETL' ];then
	rootSizef "0" >/dev/null
	mkFileSystems root
	mount --mkdir "/dev/${vgName}/root" "${mountPoint}"
	homeSizef "0" >/dev/null
	mkFileSystems home
	mount --mkdir "/dev/${vgName}/home" "${mountPoint}/home"
	swapSizef "1" >/dev/null
fi
