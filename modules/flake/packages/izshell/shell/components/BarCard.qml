import QtQuick
import qs.data

// One card of the bar; when the bar is attached it is just a group on the strip.
// Children are laid out along it like a BarGroup.
Item {
  id: root

  default property alias content: group.data
  property real padding: 5
  property real spacing: 10
  readonly property real thickness: Theme.cardThickness

  implicitWidth: Theme.barVertical ? thickness : group.implicitWidth + padding * 2
  implicitHeight: Theme.barVertical ? group.implicitHeight + padding * 2 : thickness

  CardSurface {
    // attached bars draw one strip behind all the cards instead
    visible: Theme.barFloating
    vertical: Theme.barVertical
  }

  BarGroup {
    id: group
    anchors.centerIn: parent
    spacing: root.spacing
  }
}
