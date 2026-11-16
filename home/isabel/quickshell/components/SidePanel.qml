import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.data

// Sheet that slides out from the bar. `fill` spans the full screen height;
// otherwise it hugs the bar's far end (bottom of a side bar, the bar itself on
// top/bottom) and is as tall as its content. The window is always full height
// so the sheet can change size without resizing the surface; input is masked
// to the sheet. On a top/bottom bar it sits at the right, under the capsule.
PanelWindow {
  id: root

  property string namespace: "panel"
  property bool fill: true
  default property alias content: body.data

  signal closeRequested()

  readonly property bool fromTop: Settings.barSide === "top"

  color: "transparent"
  anchors {
    top: true
    bottom: true
    left: Settings.barSide === "left"
    right: Settings.barSide !== "left"
  }
  margins {
    left: Settings.barSide === "left" ? Settings.barWidth : 0
    right: Settings.barSide === "right" ? Settings.barWidth : 0
    top: Settings.barSide === "top" ? Settings.barWidth : 0
    bottom: Settings.barSide === "bottom" ? Settings.barWidth : 0
  }

  implicitWidth: 380
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: namespace
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
  mask: Region { item: sheet }

  Rectangle {
    id: sheet
    width: parent.width
    height: root.fill ? parent.height : Math.min(parent.height, body.implicitHeight + body.anchors.margins * 2)
    y: root.fromTop ? 0 : parent.height - height
    color: Settings.colors.base
    focus: true
    Keys.onEscapePressed: root.closeRequested()

    // slide in from the bar
    transform: Translate {
      id: slide
      x: Settings.barVertical ? (Settings.barOnRight ? 16 : -16) : 0
      y: Settings.barVertical ? 0 : (root.fromTop ? -16 : 16)
      Behavior on x { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic } }
      Behavior on y { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic } }
    }
    opacity: 0
    Component.onCompleted: {
      slide.x = 0;
      slide.y = 0;
      opacity = 1;
    }
    Behavior on opacity { NumberAnimation { duration: Settings.animNormal } }

    // edge facing away from the bar
    Rectangle {
      visible: Settings.barVertical
      anchors { top: parent.top; bottom: parent.bottom }
      x: Settings.barOnRight ? 0 : parent.width - width
      width: 1
      color: Settings.colors.border
    }

    // left edge when attached to the right of a top/bottom bar
    Rectangle {
      visible: !Settings.barVertical
      anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
      width: 1
      color: Settings.colors.border
    }

    // open end of a content-sized sheet
    Rectangle {
      visible: !root.fill
      anchors { left: parent.left; right: parent.right }
      y: root.fromTop ? parent.height - height : 0
      height: 1
      color: Settings.colors.border
    }

    Item {
      id: body
      anchors { fill: parent; margins: 14 }
      implicitHeight: children.length > 0 ? children[0].implicitHeight : 0
    }
  }
}
