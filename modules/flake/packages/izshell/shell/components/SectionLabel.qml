import QtQuick
import QtQuick.Layouts
import qs.data

// A heading in the display serif. A `tint` shows as a small dot after it.
RowLayout {
  id: root

  property string text: ""
  property color tint: "transparent"
  property int size: 20

  spacing: 8

  StyledText { text: root.text; serif: true; font.pixelSize: root.size }

  Rectangle {
    visible: root.tint.a > 0
    Layout.alignment: Qt.AlignVCenter
    implicitWidth: 6
    implicitHeight: 6
    radius: Settings.pill(height)
    color: root.tint
  }
}
