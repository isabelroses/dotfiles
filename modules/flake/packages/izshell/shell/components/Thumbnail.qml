import QtQuick
import Quickshell.Widgets
import qs.data

// A picture cropped to a rounded rectangle, with its border drawn over the top
// so the image's corners can't poke past it.
Item {
  id: root

  property alias source: image.source
  property alias sourceSize: image.sourceSize
  readonly property alias status: image.status
  property real radius: Settings.radiusSm
  property int borderWidth: 1
  property color borderColor: Settings.colors.border

  ClippingRectangle {
    anchors.fill: parent
    radius: root.radius
    color: Settings.colors.overlay

    Image {
      id: image
      anchors.fill: parent
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: true
    }
  }

  Rectangle {
    anchors.fill: parent
    radius: root.radius
    color: "transparent"
    border.width: root.borderWidth
    border.color: root.borderColor
  }
}
