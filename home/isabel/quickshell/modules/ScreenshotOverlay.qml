import QtQuick
import Quickshell
import Quickshell.Wayland
import "root:/data"
import "root:/services"

Variants {
  model: Quickshell.screens

  PanelWindow {
    id: win
    property var modelData
    screen: modelData

    readonly property real dpr: modelData ? modelData.devicePixelRatio : 1
    readonly property bool isPrimary: modelData && Quickshell.screens.length > 0
                                      && modelData.name === Quickshell.screens[0].name
    readonly property string freezePath: "/tmp/qs-screenshot-freeze-" + (modelData ? modelData.name : "x") + ".png"

    readonly property bool frozenReady: Screenshot.active && frozen.status === Image.Ready

    property bool selecting: false
    property real selX: 0
    property real selY: 0
    property real selW: 0
    property real selH: 0
    readonly property bool hasSelection: selW > 1 && selH > 1

    visible: Screenshot.active
    color: "transparent"

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "screenshot"
    WlrLayershell.keyboardFocus: Screenshot.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    anchors {
      top: true
      bottom: true
      left: true
      right: true
    }

    function resetSelection(): void {
      selecting = false;
      selX = 0; selY = 0; selW = 0; selH = 0;
    }

    function confirmRegion(): void {
      const w = Math.round(selW * dpr);
      const h = Math.round(selH * dpr);
      if (w < 1 || h < 1) { Screenshot.cancel(); return; }
      cutout.grabToImage(function (result) {
        if (result && result.saveToFile(Screenshot.pendingPath))
          Screenshot.regionCaptured();
        else
          Screenshot.fail("Failed to save capture");
      }, Qt.size(w, h));
    }

    onVisibleChanged: if (visible) resetSelection()

    // menu -> window: grab this output's freeze cropped to the window's rect.
    Connections {
      target: Screenshot
      function onAutoGrabChanged() {
        const g = Screenshot.autoGrab;
        if (!g || g.output !== win.modelData.name) return;
        win.selX = g.x;
        win.selY = g.y;
        win.selW = g.w;
        win.selH = g.h;
        Qt.callLater(win.confirmRegion);
      }
    }

    Image {
      id: frozen
      anchors.fill: parent
      visible: win.frozenReady
      cache: false
      source: Screenshot.active ? ("file://" + win.freezePath) : ""
      sourceSize.width: win.width * win.dpr
      sourceSize.height: win.height * win.dpr
      fillMode: Image.Stretch
    }

    Rectangle {
      anchors.fill: parent
      visible: win.frozenReady
      color: "#000000"
      opacity: (Screenshot.mode === "region" && win.hasSelection) ? 0.45 : 0.30
    }

    // grabToImage source: must contain ONLY the frozen image (border/label are
    // siblings below so they stay out of the capture).
    Item {
      id: cutout
      visible: win.frozenReady && win.hasSelection
      x: win.selX
      y: win.selY
      width: win.selW
      height: win.selH
      clip: true

      Image {
        source: frozen.source
        cache: false
        sourceSize.width: win.width * win.dpr
        sourceSize.height: win.height * win.dpr
        width: win.width
        height: win.height
        x: -win.selX
        y: -win.selY
        fillMode: Image.Stretch
      }
    }

    Rectangle {
      visible: cutout.visible
      x: win.selX
      y: win.selY
      width: win.selW
      height: win.selH
      color: "transparent"
      border.color: Settings.colors.accent
      border.width: 1
    }

    Rectangle {
      visible: cutout.visible
      color: Settings.colors.background
      border.color: Settings.colors.border
      border.width: 1
      radius: 4
      width: dimLabel.implicitWidth + 12
      height: dimLabel.implicitHeight + 8
      x: win.selX
      y: win.selY - height - 6 >= 0 ? win.selY - height - 6 : win.selY + 6

      Text {
        id: dimLabel
        anchors.centerIn: parent
        color: Settings.colors.foreground
        font.pixelSize: 12
        text: Math.round(win.selW * win.dpr) + " × " + Math.round(win.selH * win.dpr)
      }
    }

    MouseArea {
      anchors.fill: parent
      visible: win.frozenReady && Screenshot.mode === "region"
      enabled: visible
      cursorShape: Qt.CrossCursor
      acceptedButtons: Qt.LeftButton | Qt.RightButton

      property real startX: 0
      property real startY: 0

      onPressed: mouse => {
        if (mouse.button === Qt.RightButton) { Screenshot.cancel(); return; }
        startX = mouse.x;
        startY = mouse.y;
        win.selX = mouse.x;
        win.selY = mouse.y;
        win.selW = 0;
        win.selH = 0;
        win.selecting = true;
      }
      onPositionChanged: mouse => {
        if (!win.selecting) return;
        win.selX = Math.min(startX, mouse.x);
        win.selY = Math.min(startY, mouse.y);
        win.selW = Math.abs(mouse.x - startX);
        win.selH = Math.abs(mouse.y - startY);
      }
      onReleased: mouse => {
        if (mouse.button !== Qt.LeftButton) return;
        win.selecting = false;
        if (win.hasSelection) win.confirmRegion();
        else Screenshot.cancel();
      }
    }

    Rectangle {
      id: toolbar
      visible: win.frozenReady && Screenshot.mode === "picker" && win.isPrimary
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 80
      radius: 16
      color: Settings.colors.background
      border.color: Settings.colors.border
      border.width: 1
      implicitWidth: toolRow.implicitWidth + 24
      implicitHeight: toolRow.implicitHeight + 16

      Row {
        id: toolRow
        anchors.centerIn: parent
        spacing: 8

        Repeater {
          model: [
            { key: "region", label: "Region (R)" },
            { key: "window", label: "Window (W)" },
            { key: "output", label: "Output (O)" },
            { key: "all", label: "All (A)" },
            { key: "cancel", label: "Cancel (Esc)" }
          ]

          delegate: Rectangle {
            required property var modelData
            radius: 10
            implicitWidth: btnText.implicitWidth + 24
            implicitHeight: 36
            color: btnArea.containsMouse ? Settings.colors.backgroundLightest
                                         : Settings.colors.backgroundLighter

            Text {
              id: btnText
              anchors.centerIn: parent
              text: modelData.label
              color: Settings.colors.foreground
              font.pixelSize: 13
            }

            MouseArea {
              id: btnArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: win.dispatch(modelData.key)
            }
          }
        }
      }
    }

    function dispatch(key: string): void {
      switch (key) {
        case "region": Screenshot.mode = "region"; break;
        case "window": Screenshot.window(); break;
        case "output": Screenshot.output(); break;
        case "all": Screenshot.all(); break;
        case "cancel": Screenshot.cancel(); break;
      }
    }

    Item {
      anchors.fill: parent
      focus: win.frozenReady

      Keys.onEscapePressed: Screenshot.cancel()
      Keys.onReturnPressed: {
        if (Screenshot.mode === "region" && win.hasSelection)
          win.confirmRegion();
      }
      Keys.onPressed: event => {
        if (Screenshot.mode !== "picker") return;
        switch (event.key) {
          case Qt.Key_R: win.dispatch("region"); event.accepted = true; break;
          case Qt.Key_W: win.dispatch("window"); event.accepted = true; break;
          case Qt.Key_O: win.dispatch("output"); event.accepted = true; break;
          case Qt.Key_A: win.dispatch("all"); event.accepted = true; break;
        }
      }
    }
  }
}
