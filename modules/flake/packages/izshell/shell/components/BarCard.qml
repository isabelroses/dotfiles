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

  implicitWidth: BarPlacement.vertical ? thickness : group.implicitWidth + padding * 2
  implicitHeight: BarPlacement.vertical ? group.implicitHeight + padding * 2 : thickness

  CardSurface {
    // attached bars draw one strip behind all the cards instead
    visible: BarPlacement.floating
    vertical: BarPlacement.vertical
  }

  BarGroup {
    id: group
    anchors.centerIn: parent
    spacing: root.spacing
  }
}
