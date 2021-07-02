#!/bin/bash

# Quit the script if any command fails
set -e

shutdown='Shutdown\0icon\x1fkshutdown'
lock='Lock\0icon\x1fsystem-lock-screen'
reboot='Reboot\0icon\x1fsystem-restart'
hibernate='Hibernate\0icon\x1fsystem-hibernate'

case "$1" in
'')
	echo -e "$shutdown"
	echo -e "$lock"
	echo -e "$reboot"
	echo -e "$hibernate"
	;;
Lock)
	spotify lock
	loginctl lock-session
	;;
Suspend)
	systemctl hibernate
	;;
Reboot)
	reboot
	;;
Shutdown)
	poweroff
	;;
esac

