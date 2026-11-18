import QtQuick
import QtQuick.Layouts
import qs.data

// An outlined box of rows, as on the settings pages. Rows stack edge to edge
// and sit a pixel in, so a hovered row never covers the outline; give each row
// after the first a Hairline. `rowRadius` fits a row's corners inside the box.
Rectangle {
  default property alias rows: column.data
  readonly property real rowRadius: Math.max(0, radius - 1)

  Layout.fillWidth: true
  implicitHeight: column.implicitHeight + 2
  radius: Settings.radiusMd
  color: Settings.colors.surface
  border.width: 1
  border.color: Settings.colors.border

  ColumnLayout {
    id: column
    anchors { left: parent.left; right: parent.right; top: parent.top; margins: 1 }
    spacing: 0
  }
}
