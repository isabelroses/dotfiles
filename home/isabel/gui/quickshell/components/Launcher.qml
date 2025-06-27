import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Widgets

IconImage {
  id: launcher
  source: Quickshell.iconPath("nix-snowflake")

  anchors {
    horizontalCenter: parent.horizontalCenter
    top: parent.top
    topMargin: 15
  }

  width: 16
  height: 16

  Process {
    id: launcherProcess
    command: ["qs", "ipc", "call", "launcher", "toggle"]
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    onClicked: launcherProcess.running = true;
  }
}
