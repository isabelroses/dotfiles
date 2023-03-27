#!/bin/bash

animate="$HOME/.config/eww/iceberg/common/scripts/animations"
CACHE_DIR="$HOME/.cache/eww"

function ram() {
	printf "%.0f\n" $(free -m | grep Mem | awk '{print ($3/$2)*100}')
}

function cpu() {
	# credits to adi1090x
	local PREV_TOTAL=0
	local PREV_IDLE=0
	local cpuFile="/tmp/.cpu_usage"

	if [[ -f "${cpuFile}" ]]; then
		fileCont=$(cat "${cpuFile}")
		PREV_TOTAL=$(echo "${fileCont}" | head -n 1)
		PREV_IDLE=$(echo "${fileCont}" | tail -n 1)
	fi

	CPU=(`cat /proc/stat | grep '^cpu '`) # Get the total CPU statistics.
		unset CPU[0]                          # Discard the "cpu" prefix.
		IDLE=${CPU[4]}                        # Get the idle CPU time.

	# Calculate the total CPU time.
	TOTAL=0

	for VALUE in "${CPU[@]:0:4}"; do
		let "TOTAL=$TOTAL+$VALUE"
	done

	if [[ "${PREV_TOTAL}" != "" ]] && [[ "${PREV_IDLE}" != "" ]]; then
		# Calculate the CPU usage since we last checked.
		let "DIFF_IDLE=$IDLE-$PREV_IDLE"
		let "DIFF_TOTAL=$TOTAL-$PREV_TOTAL"
		let "DIFF_USAGE=(1000*($DIFF_TOTAL-$DIFF_IDLE)/$DIFF_TOTAL+5)/10"
		echo "${DIFF_USAGE}" 
	else
		echo "?"
	fi

	# Remember the total and idle CPU times for the next check.
	echo "${TOTAL}" > "${cpuFile}"
	echo "${IDLE}" >> "${cpuFile}"
}

function dsk() {
	df -h /home | awk '{ print $5 }' | tail -1 | sed 's/%//' 
}

function dsk_total() {
	df -h /home | awk '{ print $2 }' | tail -1 | sed 's/G//'
}

function follow() {
	case "$1" in
		"ram") $animate run -i "ram" -s $(ram);;
		"cpu") $animate run -i "cpu" -s $(cpu);;
		"dsk") $animate run -i "dsk" -s $(dsk);;
		*) echo "unknown stat" && exit 1
	esac

	while sleep 5; do
		case  "$1" in
			"ram") ram;;
			"cpu") cpu;;
			"dsk") dsk;;
		esac
	done
}


case "$1" in
	"ram") ram;;
	"ram_total") ram_total;;
	"cpu") cpu;;
	"dsk") dsk;;
	"dsk_total") dsk_total;;
	"follow") follow "$2";;
	*) echo "unknown command" && exit 1;;
esac

