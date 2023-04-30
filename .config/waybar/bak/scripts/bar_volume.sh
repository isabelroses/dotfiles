#!/usr/bin/env bash
# Usage:
# ./bar_volume.sh mute
# ./bar_volume.sh raise <value>
# ./bar_volume.sh lower <value>

# Global variables
KEY="$1"
VOLUME="$2"
MAX_VOLUME="100"
SINK_INDEX="0"

# Function to mute/unmute
muteVolume () {
	pactl set-sink-mute "$SINK_INDEX" toggle
}

# Function to unmute when raise/lower volume
unmuteVolume () {
	local volumeStatus="$(pactl get-sink-mute "$SINK_INDEX" | awk '{print $2}')"

	if [[ "$volumeStatus" == yes ]]
	then
		pactl set-sink-mute "$SINK_INDEX" false
	fi
}

# Function to raise volume
raiseVolume () {
	# Set variables volume for each outputs
	local setVolumeLeft="$VOLUME"
	local setVolumeRight="$VOLUME"

	# Get level volume from left and right outputs
	local levelVolumeLeft="$(pactl get-sink-volume "$SINK_INDEX" | grep Volume | awk '{print $5}' | tr -d '%')"
	local levelVolumeRight="$(pactl get-sink-volume "$SINK_INDEX" | grep Volume | awk '{print $12}' | tr -d '%')"

	# Raise left output if needed
	if [[ "$levelVolumeLeft" -lt "$MAX_VOLUME" ]]
	then
		# Volume offset to avoid exceeding the max volume	
		local offsetVolumeLeft="$(("$MAX_VOLUME"-"$levelVolumeLeft"))"
		[[ "$setVolumeLeft" -gt "$offsetVolumeLeft" ]] && setVolumeLeft="$offsetVolumeLeft"

		pactl set-sink-volume "$SINK_INDEX" +"$setVolumeLeft"% +0%
	fi

	# Raise right output if needed
	if [[ "$levelVolumeRight" -lt "$MAX_VOLUME" ]]
	then
		# Volume offset to avoid exceeding the max volume
		local offsetVolumeRight="$(("$MAX_VOLUME"-"$levelVolumeRight"))"
		[[ "$setVolumeRight" -gt "$offsetVolumeRight" ]] && setVolumeRight="$offsetVolumeRight"

		pactl set-sink-volume "$SINK_INDEX" +0% +"$setVolumeRight"%
	fi
}

# Function to lower volume
lowerVolume () {
	pactl set-sink-volume "$SINK_INDEX" -"$VOLUME"%
}

# Main
case "$KEY" in
	mute)
		muteVolume
		;;
	raise)
		unmuteVolume
		raiseVolume
		;;
	lower)
		unmuteVolume
		lowerVolume
		;;
esac
