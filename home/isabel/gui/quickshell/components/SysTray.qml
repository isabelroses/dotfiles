import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import "root:/data"
import "root:/components"

ColumnLayout {
  id: root

  Layout.alignment: Qt.AlignCenter
  spacing: 6

  Repeater {
    model: SystemTray.items

    delegate: SystrayItem {}
  }
}
