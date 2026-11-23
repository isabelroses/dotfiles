pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Networking as Net

Singleton {
  id: root

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
