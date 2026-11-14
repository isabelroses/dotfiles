import QtQuick
import Quickshell
import Quickshell.Networking as Net
import qs.data
import qs.components

LazyLoader {
  active: Runtime.wifiPasswordTarget !== null

  Modal {
    id: win
    namespace: "network-password"
    property bool connecting: false
    onDismissed: Runtime.closeWifiPassword()

    PasswordPrompt {
      icon: "network-wireless-encrypted-symbolic"
      title: Runtime.wifiPasswordTarget?.name ?? ""
      subtitle: "Password required"
      message: Runtime.wifiPasswordError
      error: Runtime.wifiPasswordError !== ""
      busy: win.connecting
      confirmText: "Connect"
      busyText: "Connecting…"
      onCancelled: Runtime.closeWifiPassword()
      onSubmitted: (password) => {
        Runtime.wifiPasswordError = "";
        win.connecting = true;
        Runtime.wifiPasswordTarget.connectWithPsk(password);
      }
    }

    Connections {
      target: Runtime.wifiPasswordTarget
      ignoreUnknownSignals: true
      function onConnectedChanged() {
        if (Runtime.wifiPasswordTarget?.connected) Runtime.closeWifiPassword();
      }
      function onConnectionFailed(reason) {
        win.connecting = false;
        Runtime.wifiPasswordError = "Connection failed: " + Net.ConnectionFailReason.toString(reason);
      }
    }
  }
}
