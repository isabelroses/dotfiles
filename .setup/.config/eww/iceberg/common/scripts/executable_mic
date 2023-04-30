#!/bin/bash

CACHE_DIR="$HOME/.cache/eww"
animate="$HOME/.config/eww/iceberg/common/scripts/animations"

function percent () {
	echo $(pamixer --default-source --get-volume) 
}

function icon() {
	local muted=$(pamixer --default-source --get-mute)
	[ "$muted" = "true" ] && echo "" || echo "" 
}

function set_val() {
	local val=$(printf "%.0f\n" "$1")
	pamixer --default-source --set-volume $val 
}

function toggle_mute() {
	pamixer --default-source --toggle-mute
}

function follow() {
	local scalar=$(percent)
	$animate run -i "mic" -s $scalar -e "ease_out_expo"

	local m=$(percent)
	echo $m
	while sleep 0.1; do
		local nm=$(percent)
		[[ $m -ne $nm ]] && m=$nm && echo $nm
	done
}

function change() {
	[ "$1" = "up" ] && pamixer --default-source --increase 1 || pamixer --default-source --decrease 1 
}


case "$1" in
	"percent") percent;;
	"icon") icon;;
	"set") set_val "$2";;
	"follow") follow "$2";;
	"change") change "$2";;
	"toggle-mute") toggle_mute;;
	*) echo "Unknown command";;
esac
