//@ pragma IconTheme Cosmic

import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "root:/services"

IconImage {
  id: networkIcon
  source: Quickshell.iconPath(Networking.active.icon)

  width: 16
  height: 16
  Layout.alignment: Qt.AlignCenter
}
