#!/bin/bash

# Let's wait for playerctl to be able to catch up
sleep 0.5s

case "$1" in
change | start)
	echo hook:module/spotify2 >/tmp/polybar_mqueue_top
	;;
stop)
	# pause also implies stop, so let's ignore that
	;;
close)
	echo hook:module/spotify1 >/tmp/polybar_mqueue_top
	;;
esac

