//@ pragma IconTheme Cosmic

import Quickshell
import Quickshell.Widgets
import "root:/services"

IconImage {
  id: networkIcon
  source: Quickshell.iconPath(Networking.active?.icon)

  anchors.centerIn: parent
  width: 16
  height: 16

  onStatusChanged: {
    if (status === Image.Error) {
      console.error("Failed to load background image:", source);
    }
  }
}
