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

  readonly property bool fromTop: Theme.barSide === "top"
  // close button sits on the left corner unless the bar is on the left
  readonly property bool closeOnLeft: Theme.barSide !== "left"

  // breathing room around the sheet; the top leaves space for the close button
  readonly property int edge: Theme.barFloating ? 8 : 0
  readonly property int buttonRoom: Theme.barFloating ? 12 : 0

  color: "transparent"
  anchors {
    top: true
    bottom: true
    left: Theme.barSide === "left"
    right: Theme.barSide !== "left"
  }
  margins {
    left: Theme.barSide === "left" ? Theme.barWidth : 0
    right: Theme.barSide === "right" ? Theme.barWidth : 0
    top: Theme.barSide === "top" ? Theme.barWidth : 0
    bottom: Theme.barSide === "bottom" ? Theme.barWidth : 0
  }

  implicitWidth: 380 + (Theme.barFloating ? Theme.cardGap : 0) + buttonRoom
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: namespace
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
  mask: Region { item: sheet; Region { item: close } }

  Item {
    id: sheet
    x: !Theme.barFloating ? 0 : root.closeOnLeft ? root.buttonRoom : Theme.cardGap
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
      x: Theme.barVertical ? (Theme.barOnRight ? 16 : -16) : 0
      y: Theme.barVertical ? 0 : (root.fromTop ? -16 : 16)
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
      attached: !Theme.barFloating
      radius: attached ? 0 : Theme.sheetRadius
      raised: true
    }

    // attached under a top/bottom bar: close off the side facing the screen
    Rectangle {
      visible: !Theme.barFloating && !Theme.barVertical
      anchors { top: parent.top; bottom: parent.bottom; left: parent.left }
      width: 1
      color: Theme.colors.border
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
      radius: Theme.pill(width)
      // attached sheets have no corner to hang a close button off; escape or
      // the bar capsule closes them
      visible: Theme.barFloating
      x: root.closeOnLeft ? -root.buttonRoom + 2 : parent.width - width + root.buttonRoom - 2
      y: -root.buttonRoom + 2
      color: hovered ? Theme.colors.accent : Theme.colors.overlay
      border.width: 1
      border.color: hovered ? Theme.colors.accent : Theme.colors.borderStrong
      onClicked: root.closeRequested()


      MyIcon {
        anchors.centerIn: parent
        icon: "window-close-symbolic"
        size: 10
        color: close.hovered ? Theme.colors.textOnAccent : Theme.colors.text
      }
    }
  }
}
