#!/bin/bash

MAXWORDLENGTH=25

isPassword() {
  if [[ $(wc -w <<< $1) -ne 1 ]]; then return 1; fi
  if [[ $(wc -m <<< $1) -lt 6 ]]; then return 1; fi
  if [[ "$1" == *[A-Z]* && "$1" == *[a-z]* && "$1" == *[0-9]* ]]; then return 0; fi
  return 1
}

clean() {
    val=${val//\\/\\\\}
    val=${val/\$\{/\\\$\\\{}
    val=${val//\"/\\\"}
    val=$(sed "s/[^[:space:]]\{$MAXWORDLENGTH\}/& /g" <<< $val)
    echo "$val"
}

yuckify() {
  hist="$(cliphist list)"
  if [[ $(wc -w <<< $hist) -eq 0 ]]; then
    echo "(cb_empty)"
    return 0
  fi
  while IFS= read -r item; do
    val="$(cut -d ' ' -f 2- <<< $item)"
    cleaned="$(clean $val)"
    id="$(cut -d '.' -f 1 <<< $item)"
    ls "/tmp/eww/clipboard/$id.image" > /dev/null 2>&1
    if [ $? -eq 0 ]; then
      yuck="$yuck (cb_image :path \"/tmp/eww/clipboard/$id.image\" :index \"$id\")"
    elif isPassword "$val"; then
      hidden="$(sed "s/\S/⬤/g" <<< $cleaned)"
      yuck="$yuck (cb_password :hidden \"$hidden\" :content \"$cleaned\" :index \"$id\")"
    else
      yuck="$yuck (cb_text :content \"$cleaned\" :index \"$id\")"
    fi
  done <<< $hist
  echo "(box :orientation \"vertical\" $yuck)"
}

store() {
  cliphist store
  id="$(cliphist list | head -1 | cut -d '.' -f 1)"
  rm "/tmp/eww/clipboard/$id.image" > /dev/null 2>&1
  case $1 in
    image)
      echo "$id. " | cliphist decode > "/tmp/eww/clipboard/$id.image"
    ;;
  esac
  echo $(yuckify)
}

watch() {
  (wl-paste -t text/plain -w ~/.config/eww/iceberg/menu/scripts/clipboard store text) & pidtxt=$!
  (wl-paste -t image -w ~/.config/eww/iceberg/menu/scripts/clipboard store image) & pidimg=$!
  PIDS="$pidtxt $pidimg"
  trap "kill $PIDS" SIGINT
  wait $PIDS
}

refresh() {
  cliphist decode <<< "$(cliphist list | head -1 | cut -d '.' -f 1). " | wl-copy
}

case $1 in
  store) store $2;;
  get) yuckify;;
  watch) watch;;
  reload) refresh;;
esac
