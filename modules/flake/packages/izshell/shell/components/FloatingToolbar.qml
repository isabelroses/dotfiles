import QtQuick
import qs.data

// The raised pill of buttons the screenshot picker and editor float at the
// bottom of the screen. Children go in a row, split by FloatingToolbar.Separator.
Item {
  default property alias content: row.data

  anchors.horizontalCenter: parent.horizontalCenter
  anchors.bottom: parent.bottom
  implicitWidth: row.implicitWidth + 12
  implicitHeight: 56

  CardSurface { raised: true; radius: Theme.sheetRadius }

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 2
  }

  component Close: IconButton {
    anchors.verticalCenter: parent.verticalCenter
    icon: "window-close-symbolic"
    size: 12
    padding: 16
    color: Theme.colors.textMuted
  }

  component Separator: Rectangle {
    anchors.verticalCenter: parent.verticalCenter
    width: 1
    height: 24
    color: Theme.colors.border
  }
}
