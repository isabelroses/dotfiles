#!/bin/bash

function has_player() {
    if playerctl status &> /dev/null;then
        [[ $(playerctl status) = "Stopped" ]] && return 1 || return 0
    else
        return 1 
    fi
}

function title() {
    if has_player;then
        playerctl metadata title
    else
        echo "Nothing Playing"
    fi
}

function artist() {
    if has_player;then
        playerctl metadata artist
    fi
}

function ttime() {
    if has_player;then
        playerctl metadata --format "{{duration(position)}} / {{duration(mpris:length)}}"
    else
        echo "--:-- / --:--"
    fi
}

function class() {
    [[ has_player && "$status" = "Playing" ]] && echo "pause" || echo "play"
    playerctl --follow status | while read -r status; do
    [[ has_player && "$status" = "Playing" ]] && echo "pause" || echo "play"
done;
}

function icon() {
    [[ has_player && "$status" = "Playing" ]] && echo "" || echo ""
    playerctl --follow status | while read -r status; do
    [[ has_player && "$status" = "Playing" ]] && echo "" || echo ""
done
}

function toggle() {
    if has_player; then
        playerctl play-pause
    fi
}

function percent() {
    local pos=$(playerctl position)
    local len=$(playerctl metadata mpris:length)
    echo "$pos $len" | awk '{ print ($1 / $2 * 1000000) * 100 }'
}

function prev() {
    if has_player;then
        playerctl previous
    fi
}

function next() {
    if has_player;then
        playerctl next
    fi
}

case "$1" in
    "title") title;;
    "artist") artist;;
    "time") ttime;;
    "toggle") toggle;;
    "icon") icon;;
    "percent") percent;;
    "prev") prev;;
    "next") next;;
    "class") class;;
    *) echo "Unrecognized command";;
esac

