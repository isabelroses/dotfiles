import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.data

ColumnLayout {
  id: root

  Layout.alignment: Qt.AlignHCenter
  spacing: 2
  visible: Config.get("bar.show_tray") && SystemTray.items.values.length > 0

  Repeater {
    model: SystemTray.items

    delegate: SystrayItem {}
  }
}
