import QtQuick
import Quickshell
import qs.data
import qs.components

// Wi-Fi password as a modal, for when quick settings is closed. With the
// sheet open the prompt stacks on top of it instead.
LazyLoader {
  active: Runtime.wifiPasswordTarget !== null && !Runtime.quickSettingsOpen

  Modal {
    namespace: "network-password"
    onDismissed: Runtime.closeWifiPassword()

    WifiPasswordPrompt {}
  }
}
