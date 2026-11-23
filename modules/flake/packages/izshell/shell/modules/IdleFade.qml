import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.data
import qs.services

// The idle warning: for the last stretch before the idle lock, every screen
// slowly fades to black. Touching anything ends the idle state, which drops the
// fade at once. The overlay never takes input, so it can't get in the way. When
// the warning starts and ends is Session's.
Scope {
  id: root

  readonly property bool fading: Session.warning
  // windows stay up a moment after activity so the fade out can play
  property bool shown: false
  onFadingChanged: {
    if (fading) {
      hide.stop();
      shown = true;
    } else {
      hide.restart();
    }
  }

  Timer {
    id: hide
    interval: Theme.animNormal + 50
    onTriggered: root.shown = false
  }

  LazyLoader {
    active: root.shown

    Variants {
      model: Quickshell.screens

      PanelWindow {
        required property ShellScreen modelData
        screen: modelData
        color: "transparent"
        anchors { top: true; bottom: true; left: true; right: true }
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "idle-fade"
        // click-through: an empty input region
        mask: Region {}

        Rectangle {
          anchors.fill: parent
          color: "black"
          opacity: 0
          Component.onCompleted: opacity = Qt.binding(() => root.fading ? 1 : 0)

          Behavior on opacity {
            NumberAnimation {
              // creep in over the whole fade, snap back on activity
              duration: root.fading ? Session.warnFor * 1000 : Theme.animNormal
              easing.type: root.fading ? Easing.InQuad : Easing.OutQuad
            }
          }
        }
      }
    }
  }
}
