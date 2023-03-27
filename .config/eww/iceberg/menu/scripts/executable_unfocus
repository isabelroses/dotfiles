#!/bin/bash

CACHE_DIR="$HOME/.cache/eww"
eww_menu="eww -c $HOME/.config/eww/iceberg/menu"

function close() {
	$eww_menu close "$1"
	$eww_menu close unfocus
	rm "$CACHE_DIR/$1.lock"
}

function unfocus() {
	[ -f "$CACHE_DIR/notif-menu.lock" ] && close "notif-menu" 
	[ -f "$CACHE_DIR/sys-menu.lock" ] && close "sys-menu" 
	[ -f "$CACHE_DIR/time-menu.lock" ] && close "time-menu" 
}

unfocus

