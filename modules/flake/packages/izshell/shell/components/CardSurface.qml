import QtQuick
import QtQuick.Effects
import QtQuick.Shapes
import qs.data

// The card look on its own: a soft stacked shadow under a solid base fill,
// and an outline that fades out down its length. Fills its parent; put it
// first so content draws on top.
Item {
  id: root

  // flush against the screen edge: square, no shadow, and only the edge facing
  // away from the bar gets an outline
  property bool attached: false
  property real radius: attached ? 0 : Theme.cardRadius
  property bool vertical: true
  property bool raised: false

  anchors.fill: parent

  Repeater {
    model: root.attached ? []
      : Theme.colors.light
        ? (root.raised ? [{ y: 8, blur: 24, a: 0.12 }, { y: 1, blur: 3, a: 0.08 }]
                       : [{ y: 3, blur: 10, a: 0.10 }, { y: 1, blur: 2, a: 0.06 }])
        : (root.raised ? [{ y: 10, blur: 28, a: 0.40 }, { y: -2, blur: 12, a: 0.20 }]
                       : [{ y: 4, blur: 10, a: 0.30 }, { y: -1, blur: 6, a: 0.16 }])

    RectangularShadow {
      required property var modelData
      anchors.fill: parent
      offset: Qt.vector2d(0, modelData.y)
      radius: root.radius
      blur: modelData.blur
      color: Qt.rgba(0, 0, 0, modelData.a)
    }
  }

  Rectangle { anchors.fill: parent; radius: root.radius; color: Theme.colors.base }

  Shape {
    visible: !root.attached
    anchors.fill: parent
    preferredRendererType: Shape.CurveRenderer

    ShapePath {
      strokeWidth: 1
      fillColor: "transparent"
      strokeGradient: LinearGradient {
        x2: root.vertical ? 0 : root.width
        y2: root.vertical ? root.height : 0
        GradientStop { position: 0; color: Theme.colors.borderStrong }
        GradientStop { position: 1; color: Utils.withAlpha(Theme.colors.borderStrong, 0.15) }
      }
      PathRectangle {
        x: 0.5; y: 0.5
        width: root.width - 1; height: root.height - 1
        radius: Math.max(0, root.radius - 0.5)
      }
    }
  }

  Rectangle {
    visible: root.attached
    readonly property var line: BarPlacement.edgeLine(parent.width, parent.height, 1, false)
    x: line.x
    y: line.y
    width: line.width
    height: line.height
    color: Theme.colors.border
  }
}
