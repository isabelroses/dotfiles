import QtQuick
import Quickshell
import qs.data
import qs.components

// Wi-Fi password as a modal, for when quick settings is closed. With the
// sheet open the prompt stacks on top of it instead.
LazyLoader {
  active: Surfaces.wifiPasswordOpen && !Surfaces.quickSettingsOpen

  Modal {
    namespace: "network-password"
    surface: "wifiPassword"

    WifiPasswordPrompt {}
  }
}
