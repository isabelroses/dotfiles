import QtQuick
import qs.data

// A rectangle that reacts to the pointer; colour changes fade.
Rectangle {
  id: root

  readonly property alias hovered: area.containsMouse
  readonly property alias pressed: area.pressed
  property alias acceptedButtons: area.acceptedButtons

  signal clicked(mouse: MouseEvent)
  signal scrolled(wheel: WheelEvent)

  color: "transparent"
  Behavior on color { ColorAnimation { duration: Settings.animFast } }

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: (mouse) => root.clicked(mouse)
    onWheel: (wheel) => root.scrolled(wheel)
  }
}
