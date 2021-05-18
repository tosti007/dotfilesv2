#!/bin/bash

bwrofi='Bitwarden\0icon\x1fpasswordsafe'
nmrofi='Network\0icon\x1fnetwork-workgroup'

# https://github.com/davatorium/rofi/issues/919
waitAndRun() {
	# wait for a lock on the rofi pidfile
	flock $XDG_RUNTIME_DIR/rofi.pid true
	case "$@" in
		Bitwarden)
			rofi-rbw
			;;
		Network)
			nmrofi
			;;
	esac
}

if [ -z $@ ]; then
	echo -e "$bwrofi"
	echo -e "$nmrofi"
else
	waitAndRun "$@" </dev/null >/dev/null 2>/dev/null &
fi
