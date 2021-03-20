#!/bin/bash

# Quit the script if any command fails
set -e

cd "$(dirname "$0")"

case $1 in
fullscreen)
	rofi -theme fullscreen -show drun
	;;
windows)
	rofi -theme windows -show window -selected-row 1
	;;
powermenu)
	./powermenu.sh | rofi -theme powermenu -dmenu | xargs ./powermenu.sh
	;;
esac

