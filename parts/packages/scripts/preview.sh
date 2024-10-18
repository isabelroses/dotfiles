#!/bin/sh

# modified from Elkowar
case "$1" in
-*) exit 0 ;;
esac

case "$(file --mime-type "$1")" in
*text*)
  bat --color always --plain "$1"
  ;;
*image*)
  ~/.local/bin/./icat "$1"
  ;;
*pdf)
  catimg -w 100 -r 2 "$1"
  ;;
*directory*)
  eza --icons -1 --color=always "$1"
  ;;
*)
  echo "unknown file format"
  ;;
esac
