import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

IconImage {
  id: launcher
  source: Quickshell.iconPath("nix-snowflake")

  Layout.alignment: Qt.AlignCenter

  width: 16
  height: 16

  Process {
    id: launcherProcess
    command: ["vicinae", "toggle"]
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: launcherProcess.running = true;
  }
}
