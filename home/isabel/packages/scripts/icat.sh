#!/usr/bin/env -S bash -euo pipefail

CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}/icat"
mkdir -p "$CACHEDIR"
CACHEFILE=""

terminal=""
case "${TERM_PROGRAM-}" in
iTerm.app) terminal="iterm" ;;
vscode) terminal="sixel" ;;
WezTerm) terminal="wezterm" ;;
esac

case "${TERM-}" in
foot) terminal="sixel" ;;
xterm-kitty) terminal="kitty" ;;
esac
[[ -z $terminal ]] && echo "Unsupported terminal" && exit 1

function display() {
  case $terminal in
  iterm) imgcat </dev/stdin ;;
  kitty) kitty +kitten icat </dev/stdin ;;
  sixel) convert - sixel:- ;;
  wezterm) wezterm imgcat </dev/stdin ;;
  esac
}

function displaySVG() {
  [[ ! -x "$(command -v convert)" ]] && echo "convert not found, install imagemagick" && exit 1
  convert -background none -density 192 - png:- | display
}

function displayVID() {
  if [[ ! -t 0 ]]; then
    set -- /dev/stdin
  fi
  if [[ $(file --mime-type "$1" | cut -d " " -f2-) != "video/gif" ]]; then
    ffmpeg -i "$1" \
      -loglevel fatal -hide_banner \
      -vf "fps=10,scale=720:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
      -loop 0 "${CACHEFILE}.gif"
    mv "${CACHEFILE}.gif" "$CACHEFILE"
  fi
  display <"$CACHEFILE"
}

function handleLocalFile() {
  case "$(file -b --mime-type "$1")" in
  *svg*) displaySVG <"$1" ;;
  *video*) displayVID "$1" ;;
  *image*) display <"$1" ;;
  *) echo "Unknown file type" && exit 1 ;;
  esac
  exit 0
}

if [ ! -t 0 ]; then
  input="$(cat - | base64 | tr -d "\n")"

  CACHEFILE="$CACHEDIR/$(echo "$input" | shasum -a 256 | cut -d " " -f1)"
  [[ -f $CACHEFILE ]] && handleLocalFile "$CACHEFILE"

  headers="$(echo "$input" | base64 -d | file - --mime-type | cut -d " " -f2-)"

  case $headers in
  *svg*) echo "$input" | base64 -d | displaySVG ;;
  *video*) echo "$input" | base64 -d | displayVID ;;
  *image*) echo "$input" | base64 -d | display ;;
  *) echo "Unknown file type" && exit 1 ;;
  esac
elif [[ ${1-} == http* ]]; then
  CACHEFILE="$CACHEDIR/$(echo "$1" | shasum -a 256 | cut -d " " -f1)"
  [[ -f $CACHEFILE ]] && handleLocalFile "$CACHEFILE"

  meta="$(curl -sSLI "$1" | grep -i "^content-type:" | tail -n1 | cut -d " " -f2- | cut -d "/" -f1)"
  VALID_MIME_TYPES="image video svg"

  if [[ -z $meta ]]; then
    echo "No content-type header found" && exit 1
  elif [[ ! $VALID_MIME_TYPES =~ $meta ]]; then
    echo "Invalid content-type: $meta" && exit 1
  else
    curl -fsSL "$1" >"$CACHEFILE"
    handleLocalFile "$CACHEFILE"
  fi
elif [[ -n ${1-} ]]; then
  [[ ! -f $1 ]] && echo "File not found: $1" && exit 1

  CACHEFILE="$CACHEDIR/$(shasum -a 256 "$1" | cut -d " " -f1)"
  [[ -f $CACHEFILE ]] && handleLocalFile "$CACHEFILE"

  handleLocalFile "$1"
elif [[ -z ${1-} ]]; then
  echo "Usage: icat <file|url>" && exit 0
fi
