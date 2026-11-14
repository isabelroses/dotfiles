import QtQuick
import Quickshell
import qs.data

Item {
  id: root

  property string text: ""
  property int delay: 350
  readonly property bool hovered: hover.hovered
  property bool shown: false
  property real offset: 0

  anchors.fill: parent

  HoverHandler {
    id: hover
    onHoveredChanged: {
      root.shown = false;
      if (!hovered || root.text === "") return timer.stop();
      const x = root.mapToItem(null, 0, 0).x;
      root.offset = -x;
      timer.restart();
    }
  }

  Timer {
    id: timer
    interval: root.delay
    onTriggered: root.shown = true
  }

  onTextChanged: if (text === "") shown = false

  LazyLoader {
    active: root.shown

    PopupWindow {
      visible: true
      color: "transparent"

      anchor.item: root
      anchor.rect.x: root.offset
      anchor.rect.width: Settings.barWidth
      anchor.rect.height: root.height
      anchor.edges: Settings.barOnRight ? Edges.Left : Edges.Right
      anchor.gravity: Settings.barOnRight ? Edges.Left : Edges.Right

      implicitWidth: Math.min(label.implicitWidth + 20, 320)
      implicitHeight: label.implicitHeight + 12

      Rectangle {
        anchors.fill: parent
        color: Settings.colors.base
        border.color: Settings.colors.borderStrong
        border.width: 1

        Rectangle {
          anchors { top: parent.top; bottom: parent.bottom }
          x: Settings.barOnRight ? parent.width - width : 0
          width: 2
          color: Settings.colors.accent
        }

        StyledText {
          id: label
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
