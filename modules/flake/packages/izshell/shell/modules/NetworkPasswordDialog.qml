import QtQuick
import Quickshell
import qs.data
import qs.components
import qs.services

// The Wi-Fi password Surface: open while a join attempt asks for a password.
// With the quick settings sheet open the prompt stacks on top of it; otherwise
// it is a modal.
Scope {
  Connections {
    target: Networking
    function onJoinStateChanged(): void {
      // the prompt stays up while its password is tried
      if (Networking.joinState === "needsPassword") Surfaces.open("wifiPassword");
      else if (Networking.joinState !== "connecting") Surfaces.close("wifiPassword");
    }
  }

  // dismissed some other way (escape, clicking out): the attempt is over
  Connections {
    target: Surfaces
    function onWifiPasswordOpenChanged(): void {
      if (!Surfaces.wifiPasswordOpen && ["needsPassword", "connecting"].includes(Networking.joinState)) Networking.cancel();
    }
  }

  LazyLoader {
    active: Surfaces.wifiPasswordOpen && !Surfaces.quickSettingsOpen

    Modal {
      namespace: "network-password"
      surface: "wifiPassword"

      WifiPasswordPrompt {}
    }
  }
}
