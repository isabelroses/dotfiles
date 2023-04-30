#!/bin/bash

CACHE_DIR="$HOME/.cache/eww"
WEATHER_API_KEY="146e11f44d13a7ea1198179af3c4eb91"
WEATHER_API_CITY="seattle"

function fetch_weather() {
	if [ -f "$CACHE_DIR/weather" ];then
		if (($(date +"%s")-$(stat --format "%Y" "$CACHE_DIR/weather")>300));then
			local res=$(curl --connect-timeout 4 -sf "api.openweathermap.org/data/2.5/weather?q=$WEATHER_API_CITY&appid=$WEATHER_API_KEY&units=imperial")
			if ! [ -z $res ];then
				echo $res > "$CACHE_DIR/weather"
			fi
		fi
	else
		local res=$(curl --connect-timeout 4 -sf "api.openweathermap.org/data/2.5/weather?q=$WEATHER_API_CITY&appid=$WEATHER_API_KEY&units=imperial")
		if ! [ -z $res ];then
			touch "$CACHE_DIR/weather"
			echo $res > "$CACHE_DIR/weather"
		fi
	fi
}

function weather_get() {
	local json=$(cat "$CACHE_DIR/weather")
	if echo "$json" | jq empty;then
		local res=$(echo "$json" | jq -r "$1")
		[[ $res = "null" ]] && echo "$2" || echo "$res"
	else
		echo $2
	fi
}


function name() {
	weather_get ".weather[0].main" "Not Available"
}

function temp() {
	local tmp=$(weather_get ".main.temp" "--")
	if [ $tmp != "--" ];then
		echo "$tmp" | awk '{printf("%d\n",$1 + 0.5)}'
	else
		echo $tmp
	fi
}

function icon() {
	local ico=$(weather_get ".weather[0].icon" "")
	case $ico in
		"01d") echo "";;
		"01n") echo "";;
		"02d") echo "";;
		"02n") echo "";;
		"03d") echo "";;
		"03n") echo "";;
		"04d") echo "";;
		"04n") echo "";;
		"09d") echo "";;
		"09n") echo "";;
		"10d") echo "";;
		"10n") echo "";;
		"11d") echo "";;
		"11n") echo "";;
		"13d") echo "";;
		"13n") echo "";;
		"50d") echo "";;
		"50n") echo "";;
		*) echo "";;
	esac
}

if ! [ -d "$CACHE_DIR/weather" ];then
	mkdir -p "$CACHE_DIR"
fi

fetch_weather

echo "{\"icon\":\"$(icon)\",\"name\":\"$(name)\",\"temp\":\"$(temp)\"}"

