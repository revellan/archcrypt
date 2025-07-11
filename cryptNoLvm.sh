#!/bin/bash
mkfs.ext4 "/dev/mapper/${1}"
mount "/dev/mapper/${1}" "$2"