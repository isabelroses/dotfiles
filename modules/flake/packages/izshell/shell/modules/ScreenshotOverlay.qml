import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.data
import qs.services
import qs.components

Variants {
  model: Quickshell.screens

  PanelWindow {
    id: win
    required property ShellScreen modelData
    screen: modelData

    readonly property real dpr: modelData ? modelData.devicePixelRatio : 1
    readonly property bool isPrimary: modelData && Quickshell.screens.length > 0
                                      && modelData.name === Quickshell.screens[0].name
    readonly property string freezePath: "/tmp/qs-screenshot-freeze-" + (modelData ? modelData.name : "x") + ".ppm"

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
      border.width: 2
    }

    Rectangle {
      visible: cutout.visible
      color: Settings.colors.base
      border.color: Settings.colors.borderStrong
      border.width: 1
      radius: Settings.radiusSm
      width: dimLabel.implicitWidth + 16
      height: dimLabel.implicitHeight + 8
      x: win.selX
      y: win.selY - height - 6 >= 0 ? win.selY - height - 6 : win.selY + 6

      StyledText {
        id: dimLabel
        anchors.centerIn: parent
        mono: true
        font.pixelSize: 11
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

    Item {
      id: toolbar
      visible: win.frozenReady && Screenshot.mode === "picker" && win.isPrimary
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.bottom: parent.bottom
      anchors.bottomMargin: 80
      implicitWidth: toolRow.implicitWidth + 12
      implicitHeight: 56

      CardSurface {
        raised: true
        radius: Settings.sheetRadius
      }

      Row {
        id: toolRow
        anchors.centerIn: parent
        spacing: 2

        Repeater {
          model: [
            { key: "region", label: "Region", hint: "R", icon: "selection-mode-symbolic" },
            { key: "window", label: "Window", hint: "W", icon: "focus-windows-symbolic" },
            { key: "output", label: "Screen", hint: "O", icon: "video-single-display-symbolic" },
            { key: "all", label: "All screens", hint: "A", icon: "video-joined-displays-symbolic" },
          ]

          delegate: Clickable {
            id: toolBtn
            required property var modelData
            implicitWidth: btnRow.implicitWidth + 24
            implicitHeight: 44
            radius: Settings.innerRadius
            color: hovered ? Settings.colors.surfaceRaised : "transparent"
            onClicked: win.dispatch(modelData.key)

            Behavior on color { ColorAnimation { duration: Settings.animFast } }

            Row {
              id: btnRow
              anchors.centerIn: parent
              spacing: 8

              MyIcon {
                anchors.verticalCenter: parent.verticalCenter
                icon: toolBtn.modelData.icon
                size: 16
                color: toolBtn.hovered ? Settings.colors.accent : Settings.colors.text
              }

              StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: toolBtn.modelData.label
                font.pixelSize: 13
              }

              StyledText {
                anchors.verticalCenter: parent.verticalCenter
                text: toolBtn.modelData.hint
                mono: true
                font.pixelSize: 10
                color: Settings.colors.textSubtle
              }
            }
          }
        }

        Rectangle {
          anchors.verticalCenter: parent.verticalCenter
          width: 1
          height: 24
          color: Settings.colors.border
        }

        // whether this shot goes to the editor; starts from screenshot.editor
        Clickable {
          id: editBtn
          anchors.verticalCenter: parent.verticalCenter
          implicitWidth: editRow.implicitWidth + 24
          implicitHeight: 44
          radius: Settings.innerRadius
          color: Screenshot.edit ? Settings.colors.accentSoft : hovered ? Settings.colors.surfaceRaised : "transparent"
          onClicked: Screenshot.edit = !Screenshot.edit

          Behavior on color { ColorAnimation { duration: Settings.animFast } }

          Row {
            id: editRow
            anchors.centerIn: parent
            spacing: 8

            MyIcon {
              anchors.verticalCenter: parent.verticalCenter
              icon: "document-edit-symbolic"
              size: 16
              color: Screenshot.edit ? Settings.colors.accent : Settings.colors.textMuted
            }

            StyledText {
              anchors.verticalCenter: parent.verticalCenter
              text: "Edit"
              font.pixelSize: 13
              color: Screenshot.edit ? Settings.colors.accent : Settings.colors.text
            }

            StyledText {
              anchors.verticalCenter: parent.verticalCenter
              text: "E"
              mono: true
              font.pixelSize: 10
              color: Settings.colors.textSubtle
            }
          }
        }

        IconButton {
          anchors.verticalCenter: parent.verticalCenter
          icon: "window-close-symbolic"
          size: 12
          padding: 16
          color: Settings.colors.textMuted
          onClicked: win.dispatch("cancel")
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
          case Qt.Key_E: Screenshot.edit = !Screenshot.edit; event.accepted = true; break;
        }
      }
    }
  }
}
