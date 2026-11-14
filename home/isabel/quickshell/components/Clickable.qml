import QtQuick

Rectangle {
  id: root

  readonly property alias hovered: area.containsMouse
  readonly property alias pressed: area.pressed
  property alias acceptedButtons: area.acceptedButtons

  signal clicked(var mouse)
  signal scrolled(var wheel)

  color: "transparent"

  MouseArea {
    id: area
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    onClicked: (mouse) => root.clicked(mouse)
    onWheel: (wheel) => root.scrolled(wheel)
  }
}
