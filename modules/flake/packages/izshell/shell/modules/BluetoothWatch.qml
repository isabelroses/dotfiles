import QtQuick
import Quickshell
import qs.services

// Quickshell only looks for BlueZ once, at startup. If the shell came up while
// bluetoothd was down (a rebuild restarts it), restart the shell's service once
// BlueZ is back, so Bluetooth isn't missing for the rest of the session. Only
// the systemd service does this, never a test instance run by hand.
Scope {
  Connections {
    target: System
    function onBluezRunningChanged() { if (System.bluezRunning) settle.restart(); }
  }

  // BlueZ registers its name before its adapters
  Timer {
    id: settle
    interval: 2000
    onTriggered: if (Bluetooth.adapter === null && Quickshell.env("INVOCATION_ID") !== null) System.restartUnit("izshell.service", false)
  }
}
