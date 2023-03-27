#!/bin/bash

CACHE_DIR="$HOME/.cache/eww"
animate="$HOME/.config/eww/iceberg/common/scripts/animations"
delta=2

function percent () {
	echo $(pamixer --get-volume) 
}

function icon() {
	local per=$(percent)
	local muted=$(pamixer --get-mute)

	if [ "$muted" = "true" ]; then
		echo "" 
	elif (( per >= 60 )); then
		echo "" 
	elif (( per >= 20 )); then
		echo "" 
	elif (( per <= 20 )); then
		echo "" 
	fi
}

function set_vol() {
	local val=$(printf "%.0f\n" "$1")
	pamixer --set-volume $val
}

function toggle_mute() {
	pamixer --toggle-mute
}

function follow() {
	local scalar=$(percent)
	$animate run -i "vol" -s $scalar -e "ease_out_expo"
	local v=$(percent)
	echo $v
	while sleep 0.1; do
		local nv=$(percent)
		[[ $v -ne $nv ]] && v=$nv && echo $nv
	done
}

function change() {
	[ "$1" = "up" ] && pamixer --increase $delta || pamixer --decrease $delta
}


case "$1" in
	"percent") percent;;
	"icon") icon;;
	"set") set_vol "$2";;
	"follow") follow "$2";;
	"change") change "$2";;
	"toggle-mute") toggle_mute;;
	*) echo "Unknown command";;
esac
