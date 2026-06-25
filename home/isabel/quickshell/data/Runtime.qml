pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  function toggleQuickSettings() {
      quickSettingsOpen = !quickSettingsOpen;
  }
  property bool quickSettingsOpen: false

  property var wifiPasswordTarget: null
  property string wifiPasswordError: ""

  function openWifiPassword(net) {
      wifiPasswordError = "";
      wifiPasswordTarget = net;
  }

  function closeWifiPassword() {
      wifiPasswordTarget = null;
      wifiPasswordError = "";
  }
}
