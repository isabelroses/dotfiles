import QtQuick
import Quickshell
import Quickshell.Widgets
import "root:/data"

Item {
  id: iconButton
  width: 16
  height: 16

  property string icon: ""
  signal clicked

  MouseArea {
    anchors.fill: parent
    onClicked: iconButton.clicked()
  }

  Text {
    anchors.fill: parent
    text: iconButton.icon
    color: Settings.colors.foreground
    font.pixelSize: 18
  }
}
