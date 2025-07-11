#!/bin/bash
if [ "$(whoami)" == "root" ]; then
	cd "$(dirname "$0")" || exit 1
	echo -e '#!/usr/bin/env bash\n/opt/archcrypt/main.py "$@"' > /usr/bin/archcrypt
	chmod 755 /usr/bin/archcrypt
	chmod 755 /opt/archcrypt/*
	echo "installation finished, no error reported!"
else
	echo "the program has to be run as root!"
fi
