pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking as Net

Singleton {
  id: root

  property bool keepAwake: false
  // The lock outlives a shell restart (a crash mid-lock must come back locked),
  // but not the compositor: the file holds the Hyprland instance that was
  // locked, so a fresh login never inherits a lock from a session that ended
  // locked (reboot/shutdown from the lock screen).
  readonly property string lockKey: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "1"
  property bool locked: lockState.text().trim() === lockKey
  onLockedChanged: lockState.setText(locked ? lockKey : "")

  FileView {
    id: lockState
    path: Quickshell.statePath("locked")
    blockLoading: true
    blockWrites: true
    printErrors: false
  }

  Binding {
    target: Quickshell
    property: "watchFiles"
    value: !root.locked
  }

  function lock(): void {
    Surfaces.closeAll();
    locked = true;
  }

  // the network the wifi password Surface is asking about
  property Net.WifiNetwork wifiPasswordTarget: null
  property string wifiPasswordError: ""

  function openWifiPassword(net: Net.WifiNetwork): void {
    wifiPasswordError = "";
    wifiPasswordTarget = net;
    Surfaces.open("wifiPassword");
  }

  function closeWifiPassword(): void {
    Surfaces.close("wifiPassword");
  }

  // however the prompt closed (cancel, escape, connected), it forgets its network
  Connections {
    target: Surfaces
    function onWifiPasswordOpenChanged(): void {
      if (Surfaces.wifiPasswordOpen) return;
      root.wifiPasswordTarget = null;
      root.wifiPasswordError = "";
    }
  }
}
