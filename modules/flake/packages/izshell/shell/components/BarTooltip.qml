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
      root.offset = Theme.barVertical ? -p.x : -p.y;
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
      anchor.rect.x: Theme.barVertical ? root.offset : 0
      anchor.rect.y: Theme.barVertical ? 0 : root.offset
      anchor.rect.width: Theme.barVertical ? Theme.barWidth : root.width
      anchor.rect.height: Theme.barVertical ? root.height : Theme.barWidth
      anchor.edges: Theme.barAwayEdge
      anchor.gravity: Theme.barAwayEdge

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
          x: Theme.barSide === "right" ? parent.width - width : 0
          y: Theme.barOnBottom ? parent.height - height : 0
          width: Theme.barVertical ? 2 : parent.width
          height: Theme.barVertical ? parent.height : 2
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
