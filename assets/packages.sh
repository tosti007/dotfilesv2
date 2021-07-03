#!/bin/bash

function packages-parse {
	if [[ ! -e "$1" ]]; then
		echo "PATH is not a valid path"
		exit 1
	fi
	if [[ -d $1 ]]; then
		files="$(ls $1)"
	else
		files="$1"
	fi
	cat $files | sed -e 's/#.*$//; /^[[:space:]]*$/d' | tr '\n' ' '
}

function packages-install {
	yay -S --needed $1 --nocleanmenu --nodiffmenu --noeditmenu --noupgrademenu --askremovemake --removemake
}

