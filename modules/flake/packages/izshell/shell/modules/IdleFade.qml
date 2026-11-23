import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.data

// A warning before the idle lock: for the last stretch before
// lock.idle_minutes runs out, every screen slowly fades to black. Touching
// anything ends the idle state, which drops the fade at once. The overlay
// never takes input, so it can't get in the way.
Scope {
  id: root

  readonly property int lockAfter: Settings.lock.idle_minutes * 60
  // fade for 20s, or the last third of a very short timeout
  readonly property int fadeFor: Math.min(20, Math.floor(lockAfter / 3))
  readonly property bool fading: idle.isIdle && idle.enabled
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

  IdleMonitor {
    id: idle
    // same conditions as the lock's own idle monitor
    enabled: root.lockAfter > 0 && !Runtime.locked && !Runtime.keepAwake
    timeout: root.lockAfter - root.fadeFor
    respectInhibitors: true
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
              duration: root.fading ? root.fadeFor * 1000 : Theme.animNormal
              easing.type: root.fading ? Easing.InQuad : Easing.OutQuad
            }
          }
        }
      }
    }
  }
}
