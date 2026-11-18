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
      root.offset = Settings.barVertical ? -p.x : -p.y;
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
      anchor.rect.x: Settings.barVertical ? root.offset : 0
      anchor.rect.y: Settings.barVertical ? 0 : root.offset
      anchor.rect.width: Settings.barVertical ? Settings.barWidth : root.width
      anchor.rect.height: Settings.barVertical ? root.height : Settings.barWidth
      anchor.edges: Settings.barAwayEdge
      anchor.gravity: Settings.barAwayEdge

      implicitWidth: root.content ? body.implicitWidth + 20 : Math.min(label.implicitWidth + 20, 320)
      implicitHeight: root.content ? body.implicitHeight + 20 : label.implicitHeight + 12

      Rectangle {
        anchors.fill: parent
        radius: root.content ? Settings.cardRadius : Settings.radiusSm
        color: Settings.colors.base
        border.color: Settings.colors.borderStrong
        border.width: 1

        // accent stripe on the side touching the bar; square, so square tooltips only
        Rectangle {
          visible: Settings.radiusSm <= 2
          color: Settings.colors.accent
          x: Settings.barSide === "right" ? parent.width - width : 0
          y: Settings.barOnBottom ? parent.height - height : 0
          width: Settings.barVertical ? 2 : parent.width
          height: Settings.barVertical ? parent.height : 2
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
