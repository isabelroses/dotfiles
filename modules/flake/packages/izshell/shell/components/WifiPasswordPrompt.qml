import QtQuick
import Quickshell.Networking as Net
import qs.data

// Password prompt for Runtime.wifiPasswordTarget, with the connect logic. Used
// as a stacked card in quick settings, or inside a modal when that is closed.
PasswordPrompt {
  id: root

  property bool connecting: false

  icon: "network-wireless-encrypted-symbolic"
  title: Runtime.wifiPasswordTarget?.name ?? ""
  subtitle: "Password required"
  message: Runtime.wifiPasswordError
  error: Runtime.wifiPasswordError !== ""
  busy: root.connecting
  confirmText: "Connect"
  busyText: "Connecting…"
  onCancelled: Runtime.closeWifiPassword()
  onSubmitted: (password) => {
    Runtime.wifiPasswordError = "";
    root.connecting = true;
    Runtime.wifiPasswordTarget.connectWithPsk(password);
  }

  Connections {
    target: Runtime.wifiPasswordTarget
    ignoreUnknownSignals: true
    function onConnectedChanged() {
      if (Runtime.wifiPasswordTarget?.connected) Runtime.closeWifiPassword();
    }
    function onConnectionFailed(reason: int) {
      root.connecting = false;
      Runtime.wifiPasswordError = "Connection failed: " + Net.ConnectionFailReason.toString(reason);
    }
  }
}
