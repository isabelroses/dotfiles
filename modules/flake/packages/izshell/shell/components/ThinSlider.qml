import QtQuick
import QtQuick.Controls.Basic
import qs.data

Slider {
  id: root

  property color tint: Theme.colors.accent
  property int handleWidth: 8
  property int handleHeight: 12

  implicitHeight: handleHeight
  padding: 0

  background: Rectangle {
    y: root.availableHeight / 2 - height / 2
    width: root.availableWidth
    height: 4
    color: Theme.colors.overlay

    Rectangle { width: root.visualPosition * parent.width; height: parent.height; color: root.tint }
  }

  handle: Rectangle {
    x: root.visualPosition * (root.availableWidth - width)
    y: root.availableHeight / 2 - height / 2
    width: root.handleWidth
    height: root.handleHeight
    radius: Theme.radiusXs
    color: root.pressed || root.hovered ? Theme.colors.text : root.tint
  }
}
