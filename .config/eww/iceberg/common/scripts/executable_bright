#!/bin/sh

CACHE_DIR="$HOME/.cache/eww"
animate="$HOME/.config/eww/iceberg/common/scripts/animations"
delta=5

function percent() {
	echo $(brightnessctl -m | cut -d "," -f 4 | sed 's/%//')
}

function change() {
	[ "$1" = "up" ] && brightnessctl set "+$delta%" 1> /dev/null || brightnessctl set "$delta%-" 1> /dev/null
}

function set_value() { 
	brightnessctl set "$1%" > /dev/null
}

function follow() {
	local scalar=$(percent)
	$animate run -i "bright" -s $scalar -e "ease_out_expo"

	local b=$(percent)
	echo $b
	while sleep 0.1; do
		local nb=$(percent)
		[[ $b -ne $nb ]] && b=$nb && echo $nb
	done
}


case "$1" in
	"percent") percent;;
	"change") change "$2";;
	"set") set_value "$2";;
	"follow") follow;;
	*) echo "Unknown command";;
esac

