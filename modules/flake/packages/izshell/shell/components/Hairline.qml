import QtQuick
import qs.data

// A divider inside a box, inset from its edges. Horizontal ones sit along the
// top of their parent unless anchored otherwise; vertical ones along the left.
Rectangle {
  property bool vertical: false
  property real inset: 12

  anchors {
    left: parent.left
    right: vertical ? undefined : parent.right
    top: parent.top
    bottom: vertical ? parent.bottom : undefined
    leftMargin: vertical ? 0 : inset
    rightMargin: vertical ? 0 : inset
    topMargin: vertical ? inset : 0
    bottomMargin: vertical ? inset : 0
  }
  width: 1
  height: 1
  color: Theme.colors.border
}
