#!/bin/bash
cd /home/xon/.local/share/gnome-shell/extensions/gsconnect@andyholmes.github.io/service
status="$(systemctl show sshd --no-page)"

active_state=$(echo "${status}" | grep 'ActiveState=' | cut -f2 -d=)
if [ "${active_state}" == "active" ]
then
     ./daemon.js GSConnect -d $(./daemon.js GSConnect -a) --ping
else
     out="Not running"
fi

./daemon.js GSConnect -d $(./daemon.js GSConnect -a) --notification="test" --notification-body=$out
