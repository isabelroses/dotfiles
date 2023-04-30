#!/bin/bash

CACHE_DIR="$HOME/.cache/eww"

function restore() {
	[ -f "$CACHE_DIR/night.lock" ] && redshift -P -O 5000 || redshift -x
	[ $(dunstctl is-paused) = "true" ] && dunstctl set-paused true || dunstctl set-paused false
}

function toggle_wifi() {
	[ $(nmcli r wifi) = "enabled" ] && nmcli r wifi off || nmcli r wifi on
}

function follow_wifi() {
	[ $(nmcli r wifi) = "enabled" ] && local status="on" || local status="off"
	[ $status = "on" ] && local ico="" || local ico=""
	echo "{\"state\":\"$status\",\"icon\":\"$ico\"}"
	while sleep 0.1; do
		[ $(nmcli r wifi) = "enabled" ] && local ns="on" || local ns="off"
		if [ $status != $ns ];then
			status=$ns
			[ $status = "on" ] && local ico="" || local ico=""
			echo "{\"state\":\"$status\",\"icon\":\"$ico\"}"
		fi
	done
}

function toggle_air() {
	[ -f "$CACHE_DIR/air.lock" ] && rm "$CACHE_DIR/air.lock" || touch "$CACHE_DIR/air.lock"
	if [ -f "$CACHE_DIR/air.lock" ];then
		rfkill block wlan
		rfkill block bluetooth
	else
		rfkill unblock wlan
		rfkill unblock bluetooth
	fi
}

function follow_air() {
	[ -f "$CACHE_DIR/air.lock" ] && local status="on" || local status="off"
	[ $status = "on" ] && local ico="" || local ico=""
	echo "{\"state\":\"$status\",\"icon\":\"$ico\"}"
	while sleep 0.1; do
		[ -f "$CACHE_DIR/air.lock" ] && local ns="on" || local ns="off"
		if [ $status != $ns ];then
			status=$ns
			[ $status = "on" ] && local ico="" || local ico=""
			echo "{\"state\":\"$status\",\"icon\":\"$ico\"}"
		fi
	done
}

function toggle_dnd() {
	[ $(dunstctl is-paused) = "true" ] && dunstctl set-paused false || dunstctl set-paused true
}

function follow_dnd() {
	[ $(dunstctl is-paused) = "true" ] && local status="on" || local status="off"
	[ $status = "on" ] && local ico="" || local ico=""
	echo "{\"state\":\"$status\",\"icon\":\"$ico\"}"
	while sleep 0.1; do
		[ $(dunstctl is-paused) = "true" ] && local ns="on" || local ns="off"
		if [ $status != $ns ];then
			status=$ns
			[ $status = "on" ] && local ico="" || local ico=""
			echo "{\"state\":\"$status\",\"icon\":\"$ico\"}"
		fi
	done
}

function toggle_night() {
	[ -f "$CACHE_DIR/night.lock" ] && rm "$CACHE_DIR/night.lock" || touch "$CACHE_DIR/night.lock"
	[ -f "$CACHE_DIR/night.lock" ] && redshift -P -O 5000 || redshift -x
}

function follow_night() {
	[ -f "$CACHE_DIR/night.lock" ] && local status="on" || local status="off"
	[ $status = "on" ] && local ico="" || local ico=""
	echo "{\"state\":\"$status\",\"icon\":\"$ico\"}"
	while sleep 0.1; do
		[ -f "$CACHE_DIR/night.lock" ] && local ns="on" || local ns="off"
		if [ $status != $ns ];then
			status=$ns
			[ $status = "on" ] && local ico="" || local ico=""
			echo "{\"state\":\"$status\",\"icon\":\"$ico\"}"
		fi
	done
}

function toggle_blue() {
	[ -f "$CACHE_DIR/blue.lock" ] && rm "$CACHE_DIR/blue.lock" || touch "$CACHE_DIR/blue.lock"
	[ -f "$CACHE_DIR/blue.lock" ] && bluetoothctl power off || bluetoothctl power on
}

function follow_blue() {
	[ -f "$CACHE_DIR/blue.lock" ] && local status="off" || local status="on"
	[ $status = "on" ] && local ico="" || local ico=""
	echo "{\"state\":\"$status\",\"icon\":\"$ico\"}"
	while sleep 0.1; do
		[ -f "$CACHE_DIR/blue.lock" ] && local ns="off" || local ns="on"
		if [ $status != $ns ];then
			status=$ns
			[ $status = "on" ] && local ico="" || local ico=""
			echo "{\"state\":\"$status\",\"icon\":\"$ico\"}"
		fi
	done
}

function screenshot() {
	eww -c "$HOME/.config/eww/iceberg/menu" close sys-menu
	flameshot gui
}

case "$1" in
	"toggle-wifi") toggle_wifi;;
	"toggle-blue") toggle_blue;;
	"toggle-air") toggle_air;;
	"toggle-dnd") toggle_dnd;;
	"toggle-night") toggle_night;;
	"screenshot") screenshot;;
	"toggle-blue") toggle_blue;;
	"wifi") follow_wifi;;
	"air") follow_air;;
	"dnd") follow_dnd;;
	"night") follow_night;;
	"blue") follow_blue;;
	"restore") restore;;
	*) echo "unknown command";;
esac

