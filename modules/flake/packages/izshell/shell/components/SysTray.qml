import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import qs.data

BarGroup {
  id: root

  Layout.alignment: Qt.AlignCenter
  spacing: 2
  visible: items.values.length > 0

  // case-insensitive match on the item's id (e.g. "spotify-client") or title (e.g. "spotify")
  readonly property list<string> hidden: Settings.bar.tray_hidden.map(s => s.toLowerCase())

  ScriptModel {
    id: items
    values: SystemTray.items.values.filter(item =>
      !root.hidden.includes(item.id.toLowerCase()) && !root.hidden.includes(item.title.toLowerCase()))
  }

  Repeater {
    model: items

    delegate: SystrayItem {}
  }
}
