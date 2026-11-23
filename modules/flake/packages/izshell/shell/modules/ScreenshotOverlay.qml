import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
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
    readonly property bool frozenReady: Screenshot.active && frozenLoader.item?.hasContent === true

    // a drag has started; until then region mode snaps to the hovered window
    property bool dragging: false
    property real selX: 0
    property real selY: 0
    property real selW: 0
    property real selH: 0
    readonly property bool hasSelection: selW > 1 && selH > 1
    // the selection in the screen's own pixels
    readonly property size selPx: Qt.size(Math.round(selW * dpr), Math.round(selH * dpr))

    // windows on this screen's visible workspace as screen-local rects, floating
    // and pinned ones first since they sit on top
    readonly property var windows: {
      if (Screenshot.phase !== "region") return [];
      const ws = Hyprland.monitorFor(modelData)?.activeWorkspace;
      return Hyprland.toplevels.values
        .filter(t => t.workspace === ws && t.lastIpcObject?.at)
        .map(t => {
          const o = t.lastIpcObject;
          const x = Math.max(0, o.at[0] - modelData.x), y = Math.max(0, o.at[1] - modelData.y);
          return { x, y, w: Math.min(o.at[0] - modelData.x + o.size[0], width) - x,
                   h: Math.min(o.at[1] - modelData.y + o.size[1], height) - y, top: o.floating || o.pinned };
        })
        .sort((a, b) => b.top - a.top);
    }

    function select(r: var): void {
      selX = r?.x ?? 0; selY = r?.y ?? 0; selW = r?.w ?? 0; selH = r?.h ?? 0;
    }

    function windowAt(x: real, y: real): var {
      return windows.find(w => x >= w.x && x < w.x + w.w && y >= w.y && y < w.y + w.h) ?? null;
    }

    // Mapped while freezing too, but empty and click-through: the views only
    // receive frames in a mapped window, and an empty surface adds nothing to them.
    visible: Screenshot.active || Screenshot.freezing
    mask: Screenshot.active ? null : clickThrough
    color: "transparent"

    Region { id: clickThrough }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "screenshot"
    WlrLayershell.keyboardFocus: Screenshot.active ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Ignore

    anchors { top: true; bottom: true; left: true; right: true }

    function resetSelection(): void {
      dragging = false;
      select(null);
    }

    function confirmRegion(): void {
      if (selPx.width < 1 || selPx.height < 1) return Screenshot.cancel();
      Screenshot.grabbed(cutout, selPx);
    }

    onVisibleChanged: if (visible) resetSelection()

    Connections {
      target: Screenshot
      function onCropChanged() {
        const g = Screenshot.crop;
        if (!g || g.output !== win.modelData.name) return;
        win.select(g);
        Qt.callLater(win.confirmRegion);
      }
    }

    // A fresh view per freeze: it captures one frame while the window is still
    // hidden, and hasContent turning true is the signal that the frame is in.
    Loader {
      id: frozenLoader
      // sized from the screen: the window has no size until it is first shown
      width: win.modelData.width
      height: win.modelData.height
      active: Screenshot.freezing || Screenshot.active

      sourceComponent: ScreencopyView {
        captureSource: win.modelData
        live: false
        onHasContentChanged: if (hasContent) Screenshot.screenFrozen()
      }
    }

    Rectangle {
      anchors.fill: parent
      visible: win.frozenReady
      color: "#000000"
      opacity: (Screenshot.phase === "region" && win.hasSelection) ? 0.45 : 0.30
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
      ShaderEffectSource {
        anchors.fill: parent
        sourceItem: frozenLoader.item
        sourceRect: Qt.rect(win.selX, win.selY, win.selW, win.selH)
        textureSize: win.selPx
      }
    }

    Rectangle {
      visible: cutout.visible
      x: win.selX
      y: win.selY
      width: win.selW
      height: win.selH
      color: "transparent"
      border.color: Theme.colors.accent
      border.width: 2
    }

    Rectangle {
      visible: cutout.visible
      color: Theme.colors.base
      border.color: Theme.colors.borderStrong
      border.width: 1
      radius: Theme.radiusSm
      width: dimLabel.implicitWidth + 16
      height: dimLabel.implicitHeight + 8
      x: win.selX
      y: win.selY - height - 6 >= 0 ? win.selY - height - 6 : win.selY + 6

      StyledText {
        id: dimLabel
        anchors.centerIn: parent
        mono: true
        font.pixelSize: 11
        text: win.selPx.width + " × " + win.selPx.height
      }
    }

    MouseArea {
      anchors.fill: parent
      visible: win.frozenReady && Screenshot.phase === "region"
      enabled: visible
      cursorShape: Qt.CrossCursor
      acceptedButtons: Qt.LeftButton | Qt.RightButton
      hoverEnabled: true

      property real startX: 0
      property real startY: 0

      // hovering outlines the window underneath and a click takes it; moving a
      // few pixels with the button held starts a free selection instead
      onPressed: mouse => {
        if (mouse.button === Qt.RightButton) return Screenshot.cancel();
        startX = mouse.x;
        startY = mouse.y;
      }
      onPositionChanged: mouse => {
        if (!pressed) return win.select(win.windowAt(mouse.x, mouse.y));
        if (!win.dragging && Math.hypot(mouse.x - startX, mouse.y - startY) < 4) return;
        win.dragging = true;
        win.select({ x: Math.min(startX, mouse.x), y: Math.min(startY, mouse.y),
                     w: Math.abs(mouse.x - startX), h: Math.abs(mouse.y - startY) });
      }
      onReleased: mouse => {
        if (mouse.button !== Qt.LeftButton) return;
        win.dragging = false;
        if (win.hasSelection) win.confirmRegion();
        else Screenshot.cancel();
      }
    }

    readonly property var modes: [
      { key: "region", label: "Region", hint: "R", icon: "selection-mode-symbolic" },
      { key: "window", label: "Window", hint: "W", icon: "focus-windows-symbolic" },
      { key: "output", label: "Screen", hint: "O", icon: "video-single-display-symbolic" },
      { key: "all", label: "All screens", hint: "A", icon: "video-joined-displays-symbolic" },
      { key: "text", label: "Text", hint: "T", icon: "insert-text-symbolic" },
    ]

    function pick(key: string): void {
      Screenshot.choose(key);
    }

    FloatingToolbar {
      visible: win.frozenReady && Screenshot.phase === "picking" && win.isPrimary
      anchors.bottomMargin: 80

      Repeater {
        model: win.modes
        ToolbarButton {
          required property var modelData
          icon: modelData.icon
          label: modelData.label
          hint: modelData.hint
          onClicked: win.pick(modelData.key)
        }
      }

      FloatingToolbar.Separator {}

      // whether this shot goes to the editor; starts from screenshot.editor
      ToolbarButton {
        icon: "document-edit-symbolic"
        label: "Edit"
        hint: "E"
        active: Screenshot.edit
        onClicked: Screenshot.toggleEdit()
      }

      FloatingToolbar.Close { onClicked: Screenshot.cancel() }
    }

    Item {
      anchors.fill: parent
      focus: win.frozenReady

      Keys.onEscapePressed: Screenshot.cancel()
      Keys.onReturnPressed: if (Screenshot.phase === "region" && win.hasSelection) win.confirmRegion()
      Keys.onPressed: event => {
        if (Screenshot.phase !== "picking") return;
        const key = event.text.toUpperCase();
        const mode = win.modes.find(m => m.hint === key);
        if (mode) win.pick(mode.key);
        else if (key === "E") Screenshot.toggleEdit();
        else return;
        event.accepted = true;
      }
    }
  }
}
