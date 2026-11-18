import QtQuick
import QtQuick.Layouts
import qs.data

// One boxed row on a settings page, matching the schema rows' look. Children
// stack in a column inside its padding.
Rectangle {
  id: root

  default property alias content: column.data
  property alias spacing: column.spacing

  Layout.fillWidth: true
  implicitHeight: column.implicitHeight + 24
  radius: Settings.radiusMd
  color: Settings.colors.surface
  border.width: 1
  border.color: Settings.colors.border

  ColumnLayout {
    id: column
    anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 14; rightMargin: 12 }
    spacing: 10
  }
}
