import QtQuick
import qs.data

// Inline error box; hidden while `text` is empty.
Rectangle {
  property alias text: label.text

  visible: text !== ""
  implicitHeight: label.implicitHeight + 16
  radius: Theme.radiusSm
  color: Utils.withAlpha(Theme.colors.error, 0.12)
  border.color: Theme.colors.error
  border.width: 1

  StyledText {
    id: label
    anchors { fill: parent; margins: 8 }
    color: Theme.colors.error
    font.pixelSize: 11
    wrapMode: Text.Wrap
  }
}
