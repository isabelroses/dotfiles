#!/bin/bash

function close() {
	eww -c "$HOME/.config/eww/iceberg/menu" close sys-menu time-menu
	$HOME/.scripts/dashboard close
}

function lock() {
	close
	betterlockscreen -l dim
}

function llogout() {
	close
	bspc quit
}

function rrestart() {
	close
	reboot
}

function sshutdown() {
	close
	shutdown now
}

case "$1" in
	lock) lock;;
	logout) llogout;;
	reboot) rrestart;;
	shutdown) sshutdown;;
	*) echo "unrecognized command" && exit 1;;
esac

