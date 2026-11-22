import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.services

// Direct captures (window, screen, every screen) with nothing shown: grabToImage
// needs a mapped window, so a 1x1 click-through one holds the views. The items
// render at full size off-window; only their grab ever reaches the screen.
PanelWindow {
  id: win

  readonly property var job: Screenshot.job

  visible: job !== null
  screen: Quickshell.screens[0]
  anchors { top: true; left: true }
  implicitWidth: 1
  implicitHeight: 1
  color: "transparent"
  mask: Region {}
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: "screenshot-grab"
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

  Loader {
    // fresh views per job, so hasContent means this job's frame
    active: win.job !== null
    opacity: 0
    sourceComponent: win.job?.kind === "window" ? windowShot : win.job?.kind === "all" ? desk : screenShot
  }

  Component {
    id: screenShot

    ScreencopyView {
      id: screenView
      readonly property ShellScreen target: win.job.screen
      captureSource: target
      live: false
      width: target.width
      height: target.height
      onHasContentChanged: if (hasContent) Screenshot.saveGrab(screenView, sourceSize)
    }
  }

  Component {
    id: windowShot

    // captured from the window's own buffer: no overlap, no decorations
    ScreencopyView {
      id: windowView
      captureSource: ToplevelManager.activeToplevel
      live: false
      width: sourceSize.width
      height: sourceSize.height
      onHasContentChanged: if (hasContent) Screenshot.saveGrab(windowView, sourceSize)
      Component.onCompleted: if (!ToplevelManager.activeToplevel) Screenshot.fail("No active window")
    }
  }

  Component {
    id: desk

    // every screen laid out as Hyprland places them, at the sharpest screen's scale
    Item {
      id: layout
      readonly property var screens: Quickshell.screens
      readonly property real minX: Math.min(...screens.map(s => s.x))
      readonly property real minY: Math.min(...screens.map(s => s.y))
      readonly property real pixelScale: Math.max(...screens.map(s => s.devicePixelRatio))
      property int ready: 0

      width: Math.max(...screens.map(s => s.x + s.width)) - minX
      height: Math.max(...screens.map(s => s.y + s.height)) - minY

      Repeater {
        model: layout.screens

        ScreencopyView {
          required property ShellScreen modelData
          captureSource: modelData
          live: false
          x: modelData.x - layout.minX
          y: modelData.y - layout.minY
          width: modelData.width
          height: modelData.height
          onHasContentChanged: {
            if (hasContent && ++layout.ready === layout.screens.length)
              Screenshot.saveGrab(layout, Qt.size(Math.round(layout.width * layout.pixelScale), Math.round(layout.height * layout.pixelScale)));
          }
        }
      }
    }
  }
}
