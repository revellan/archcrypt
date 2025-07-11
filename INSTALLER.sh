#!/bin/bash
if [ "$(whoami)" == "root" ]; then
	cd "$(dirname "$0")" || exit
	rsync --delete -rc ../ArchInstall /opt
	echo -e '#!/bin/bash\n/opt/ArchInstall/main.py "$@"' > /usr/bin/ArchInstall
	chmod 755 /usr/bin/ArchInstall
	chmod 755 /opt/ArchInstall/*
	echo "installation finished, no error reported!"
else
	echo "the program has to be run as root!"
fi
