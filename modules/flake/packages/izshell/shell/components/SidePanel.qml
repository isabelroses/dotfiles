import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.data

// Sheet beside the bar, in the same card style; it floats with gaps or sits
// flush against the bar to match the bar style. `fill` spans the
// screen height; otherwise it hugs the bar's far end (bottom of a side bar, the
// bar itself on top/bottom) and is as tall as its content. The window is always
// full height so the sheet can change size without resizing the surface; input
// is masked to the sheet and its close button. On a top/bottom bar it sits at
// the right, under the capsule. The round close button overhangs the top
// corner furthest from the bar (tucked inside it when attached).
PanelWindow {
  id: root

  property string namespace: "panel"
  property bool fill: true
  default property alias content: body.data

  signal closeRequested()

  readonly property bool fromTop: Settings.barSide === "top"
  // close button sits on the left corner unless the bar is on the left
  readonly property bool closeOnLeft: Settings.barSide !== "left"

  // breathing room around the sheet; the top leaves space for the close button
  readonly property int edge: Settings.barFloating ? 8 : 0
  readonly property int buttonRoom: Settings.barFloating ? 12 : 0

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

  implicitWidth: 380 + (Settings.barFloating ? Settings.cardGap : 0) + buttonRoom
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: namespace
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
  mask: Region { item: sheet; Region { item: close } }

  Item {
    id: sheet
    x: !Settings.barFloating ? 0 : root.closeOnLeft ? root.buttonRoom : Settings.cardGap
    width: 380
    readonly property real topY: root.buttonRoom
    readonly property real room: parent.height - topY - root.edge
    height: root.fill ? room : Math.min(room, body.implicitHeight + body.anchors.margins * 2)
    y: root.fill || root.fromTop ? topY : parent.height - root.edge - height
    focus: true
    Keys.onEscapePressed: root.closeRequested()

    // slide in from the bar
    transform: Translate {
      id: slide
      x: Settings.barVertical ? (Settings.barOnRight ? 16 : -16) : 0
      y: Settings.barVertical ? 0 : (root.fromTop ? -16 : 16)
      Behavior on x { Anim {} }
      Behavior on y { Anim {} }
    }
    opacity: 0
    Component.onCompleted: {
      slide.x = 0;
      slide.y = 0;
      opacity = 1;
    }
    Behavior on opacity { Anim {} }

    CardSurface {
      attached: !Settings.barFloating
      radius: attached ? 0 : Settings.sheetRadius
      raised: true
    }

    // attached under a top/bottom bar: close off the side facing the screen
    Rectangle {
      visible: !Settings.barFloating && !Settings.barVertical
      anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
      width: 1
      color: Settings.colors.border
    }

    Item {
      id: body
      anchors { fill: parent; margins: 16 }
      implicitHeight: children.length > 0 ? children[0].implicitHeight : 0
    }

    Clickable {
      id: close
      width: 24
      height: 24
      radius: Settings.pill(width)
      // attached sheets have no corner to hang a close button off; escape or
      // the bar capsule closes them
      visible: Settings.barFloating
      x: root.closeOnLeft ? -root.buttonRoom + 2 : parent.width - width + root.buttonRoom - 2
      y: -root.buttonRoom + 2
      color: hovered ? Settings.colors.accent : Settings.colors.overlay
      border.width: 1
      border.color: hovered ? Settings.colors.accent : Settings.colors.borderStrong
      onClicked: root.closeRequested()


      MyIcon {
        anchors.centerIn: parent
        icon: "window-close-symbolic"
        size: 10
        color: close.hovered ? Settings.colors.textOnAccent : Settings.colors.text
      }
    }
  }
}
