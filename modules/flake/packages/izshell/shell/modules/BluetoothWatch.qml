import QtQuick
import Quickshell
import Quickshell.Io
import qs.services

// Quickshell only looks for BlueZ once, at startup. If the shell came up while
// bluetoothd was down (a rebuild restarts it), wait for it and restart the
// shell's service so Bluetooth isn't missing for the rest of the session.
// Only the systemd service does this, never a test instance run by hand.
Scope {
  Process {
    running: Bluetooth.adapter === null && Quickshell.env("INVOCATION_ID") !== null
    command: ["sh", "-c", "gdbus wait --system org.bluez && sleep 2 && busctl --system --list tree org.bluez | grep -q /org/bluez/hci"]
    onExited: (code) => {
      if (code === 0 && Bluetooth.adapter === null)
        Quickshell.execDetached(["systemctl", "--user", "restart", "izshell.service"]);
    }
  }
}
