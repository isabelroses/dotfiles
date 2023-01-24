#!/usr/bin/env bash
# Usage :
# ./spotify_installer.sh
# and follow instructions

# Global variables
INSTALL_PATH=""$HOME"/.local/share"
BINARY_PATH=""$HOME"/.local/bin"
SHORTCUT_PATH=""$HOME"/.local/share/applications"
MOUNT_PATH="/mnt"
RELEASE="edge"

APP_NAME=spotify
SNAP_DUMP="$(curl -sH 'Snap-Device-Series: 16' http://api.snapcraft.io/v2/snaps/info/"$APP_NAME" | jq '."channel-map"[]')"
VERSION_COMMIT="$(echo "$SNAP_DUMP" | jq -r 'select(.channel.name == "'$RELEASE'") | .version')"

exec 3>&1

displayMsg () {
	command echo "$@" >&3
}

displayWelcome () {
	displayMsg "WELCOME TO SPOTIFY INSTALLATION"
	displayMsg "This setup get sources files from Spotify's"
	displayMsg "official releases in snapcraft store"
	displayMsg "Important !! For now official wayland support"
	displayMsg "is only available with edge release"
}

displayConfiguration () {
	local message

	message="$1"

	displayMsg ""
	displayMsg "$message"
	displayMsg "Install directoy : "$INSTALL_PATH""
	displayMsg "Installation will automatically create a folder"
	displayMsg "called "$APP_NAME" inside the install directory"
	displayMsg "Binary directory : "$BINARY_PATH""
	displayMsg "Shortcut directory : "$SHORTCUT_PATH""
	displayMsg "Mount path for installation : "$MOUNT_PATH""
	displayMsg "Spotify release : "$RELEASE""
	displayMsg "Version and commit : "$VERSION_COMMIT""
	displayMsg ""
}

checkExit () {
	local input
	local quit

	input="$1"
	quit="$2"

	if [[ "$input" == "$quit" ]] 
	then
		displayMsg "Exit Spotify Installation"
		exit 0
	fi
}

chooseOptions () {
	local options
	local input

	options="$@"

	until echo "$options" | grep -qw "$input"
	do
		displayMsg "Choose between : "$options""
		read input
	done

	echo "$input"
}

modifyPath () {
	local namePath
	local path
	local answer
	local input
  
	namePath="$1"
	path="$2"

	while [[ "$answer" != "y" ]]
	do
		displayMsg "Change the "$namePath" : "$path""
		displayMsg "Type the new path"
		read input
		if [[ "$input" == "" ]]
		then
			input="$path"
			displayMsg "Path can not be empty"
			displayMsg "Path unchanged"
		fi
		displayMsg "Is $input the right path ?"
		displayMsg "Type y or n"
		read answer
	done
  
	echo "$input"

	[[ "$path" != "$input" ]] && return 6 
}

changePaths () {
	local option
	local returnValue

	displayMsg "Do you want to change paths ?"
	option="$(chooseOptions "y" "n" "q")"
	checkExit "$option" "q"

	if [[ "$option" == "y" ]]
	then
		INSTALL_PATH="$(modifyPath "install directory" "$INSTALL_PATH")"
		returnValue="$?"
		changes="$(("$changes"+"$returnValue"))"
		BINARY_PATH="$(modifyPath "binary directory" "$BINARY_PATH")"
		returnValue="$?"
		changes="$(("$changes"+"$returnValue"))"
		SHORTCUT_PATH="$(modifyPath "shortcut directory" "$SHORTCUT_PATH")"
		returnValue="$?"
		changes="$(("$changes"+"$returnValue"))"
		MOUNT_PATH="$(modifyPath "mount directory" "$MOUNT_PATH")"
		returnValue="$?"
		changes="$(("$changes"+"$returnValue"))"
	fi
}

whichRelease () {
	local releasesVersions
	local releases
	local choice

	releasesVersions="$(echo "$SNAP_DUMP" | jq -r '.channel.name, .version')"
	releases="$(echo "$SNAP_DUMP" | jq -r '.channel.name')"

	displayMsg "Informations about releases and versions"
	displayMsg "$releasesVersions"
  
	choice="$(chooseOptions "$releases")" 

	echo "$choice"

	[[ "$RELEASE" != "$choice" ]] && return 6 
}

changeRelease () {
	local option
	local returnValue

	displayMsg "Do you want to change realease version ?"
	option="$(chooseOptions "y" "n" "q")"
	checkExit "$option" "q"

	if [[ "$option" == "y" ]]
	then
		RELEASE="$(whichRelease)"
		returnValue="$?"
		changes="$(("$changes"+"$returnValue"))"
		VERSION_COMMIT="$(echo "$SNAP_DUMP" | jq -r 'select(.channel.name == "'$RELEASE'") | .version')"
	fi
}

checkChanges () {
	if [[ "$changes" -gt "5" ]]
	then
		displayConfiguration "CHANGED INSTALL CONFIGURATION"
		return 0
	else
		displayMsg "Nothing has been changed"
		return 1
  	fi
}

changeConfiguration () {
	local changes
	local returnValue

	changes="0"

	changePaths
	changeRelease
	checkChanges
	returnValue="$?"
	[[ "$returnValue" -eq 0 ]] && return 0
}

installOptions () {
	local input
	local returnValue
  
	while true
	do
		read -p $'Type c to change configuration install\nType n to keep default configuration and go to next step\nType q to quit installation :\n' input
		case "$input" in
		c)
			displayMsg "You choose change configuration"
			changeConfiguration
			returnValue="$?"
			[[ "$returnValue" -eq 0 ]] && return 0
			;;
		n)
			displayMsg "Continuing without changing install configuration"
			return 0
			;;
		q)
			displayMsg "Exit Spotify Installation"
			exit 0
			;;
		*)
			displayMsg "Invalid input"
		esac
	done
}

startInstall () {
	local answer

	while [[ "$answer" != "y" ]]
	do
		displayMsg "Start installation ?"
		displayMsg "Type y, n or q to quit"
		read answer
		checkExit "$answer" "n"
		checkExit "$answer" "q"
	done
}

installSpotify () {
	local version
	local commit
	#local sha384
	local url
	local temporyPath
	local nameFile
	local pathFile
	local sourceSpotify

	version="$(echo "$VERSION_COMMIT" | awk -F '.' '{print $1"."$2"."$3"."$4}')"
	commit="$(echo "$VERSION_COMMIT" | awk -F '.' '{print $5}')"
	#sha384=$(echo "$SNAP_DUMP" | jq -r 'select(.channel.name == "'$RELEASE'") | .download."sha3-384"')
	url="$(echo "$SNAP_DUMP" | jq -r 'select(.channel.name == "'$RELEASE'") | .download.url')"

	temporyFolder="/tmp"
	nameFile=""$APP_NAME"-"$version"-"$commit".snap"
	pathFile=""$temporyFolder"/"$nameFile""

	sourceSpotify=""$MOUNT_PATH"/usr/share/"$APP_NAME""

	echo "Downloading "$APP_NAME" version "$version" commit "$commit" from snapcraft."
	curl -f#SLo "$pathFile" "$url"

	echo "Mount "$pathFile" in "$MOUNT_PATH""
	sudo mount -t squashfs -o ro "$pathFile" "$MOUNT_PATH"

	echo "Copy "$sourceSpotify" to "$INSTALL_PATH"/"$APP_NAME""
	cp -r "$sourceSpotify" ""$INSTALL_PATH"/"$APP_NAME""

	echo "Unmount "$MOUNT_PATH""
	sudo umount "$MOUNT_PATH"

	echo "Remove "$pathFile""
	rm "$pathFile"

	echo "Create symlink to binary"
	ln -sf ""$INSTALL_PATH"/"$APP_NAME"/spotify" ""$BINARY_PATH"/spotify"

	echo "Enable spotify to open URLs from the webapp and wayland support"
	sed -i 's/^Exec=.*/Exec=spotify --enable-features=UseOzonePlatform --ozone-platform=wayland --uri=%U/' ""$INSTALL_PATH"/"$APP_NAME"/spotify.desktop"

	echo "Enable spotify to use icons from theme"
	sed -i 's/^Icon=.*/Icon=spotify-client/' ""$INSTALL_PATH"/"$APP_NAME"/spotify.desktop"

	echo "Deploy shortcut application"
	ln -sf ""$INSTALL_PATH"/"$APP_NAME"/spotify.desktop" ""$SHORTCUT_PATH"/spotify.desktop"
}

# Main
displayWelcome
displayConfiguration "DEFAULT INSTALL CONFIGURATION"
installOptions
startInstall
installSpotify
