#!/bin/bash
lsblk --output SIZE -nbd "$1" | tr -d "\n"