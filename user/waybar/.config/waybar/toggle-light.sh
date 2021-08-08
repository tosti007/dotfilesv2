#!/usr/bin/sh

if [[ "$(light -Gr)" -gt 25 ]]; then
	light -S 6
else
	light -S 100
fi
