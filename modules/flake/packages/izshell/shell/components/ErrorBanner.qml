import QtQuick
import qs.data

// Inline error box; hidden while `text` is empty.
Rectangle {
  property alias text: label.text

  visible: text !== ""
  implicitHeight: label.implicitHeight + 16
  radius: Settings.radiusSm
  color: Utils.withAlpha(Settings.colors.error, 0.12)
  border.color: Settings.colors.error
  border.width: 1

  StyledText {
    id: label
    anchors { fill: parent; margins: 8 }
    color: Settings.colors.error
    font.pixelSize: 11
    wrapMode: Text.Wrap
  }
}
