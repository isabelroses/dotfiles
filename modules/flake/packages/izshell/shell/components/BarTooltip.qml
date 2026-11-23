import QtQuick
import Quickshell
import qs.data

Item {
  id: root

  property string text: ""
  property Component content: null
  property int delay: 350
  readonly property bool hovered: hover.hovered
  property bool shown: false
  property real offset: 0

  anchors.fill: parent

  HoverHandler {
    id: hover
    onHoveredChanged: {
      root.shown = false;
      if (!hovered || (root.text === "" && !root.content)) return timer.stop();
      const p = root.mapToItem(null, 0, 0);
      root.offset = BarPlacement.vertical ? -p.x : -p.y;
      timer.restart();
    }
  }

  Timer {
    id: timer
    interval: root.delay
    onTriggered: root.shown = true
  }

  onTextChanged: if (text === "" && !content) shown = false

  LazyLoader {
    active: root.shown

    PopupWindow {
      visible: true
      color: "transparent"

      anchor.item: root
      readonly property var place: BarPlacement.popupAnchor(root, root.offset, false)
      anchor.rect.x: place.x
      anchor.rect.y: place.y
      anchor.rect.width: place.width
      anchor.rect.height: place.height
      anchor.edges: place.edges
      anchor.gravity: place.gravity

      implicitWidth: root.content ? body.implicitWidth + 20 : Math.min(label.implicitWidth + 20, 320)
      implicitHeight: root.content ? body.implicitHeight + 20 : label.implicitHeight + 12

      Rectangle {
        anchors.fill: parent
        radius: root.content ? Theme.cardRadius : Theme.radiusSm
        color: Theme.colors.base
        border.color: Theme.colors.borderStrong
        border.width: 1

        // accent stripe on the side touching the bar; square, so square tooltips only
        Rectangle {
          visible: Theme.radiusSm <= 2
          color: Theme.colors.accent
          readonly property var line: BarPlacement.edgeLine(parent.width, parent.height, 2, true)
          x: line.x
          y: line.y
          width: line.width
          height: line.height
        }

        Loader {
          id: body
          anchors.centerIn: parent
          sourceComponent: root.content
        }

        StyledText {
          id: label
          visible: !root.content
          anchors.centerIn: parent
          width: Math.min(implicitWidth, 300)
          text: root.text
          font.pixelSize: 12
          wrapMode: Text.Wrap
        }
      }
    }
  }
}
