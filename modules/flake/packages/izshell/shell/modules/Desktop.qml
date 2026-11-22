import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.data
import qs.components

Variants {
  model: Quickshell.screens

  PanelWindow {
    id: win
    required property ShellScreen modelData
    screen: modelData
    color: Settings.colors.base

    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Background
    WlrLayershell.namespace: "wallpaper"

    anchors { top: true; bottom: true; left: true; right: true }

    property Image front: a
    readonly property Image back: front === a ? b : a

    function show(path: string): void {
      if (path === "") return;
      const url = Qt.resolvedUrl(path);
      if (front.source.toString() === url.toString()) return;
      const layer = front.source.toString() === "" ? front : back;
      layer.capped = false;
      layer.sourceSize = undefined;
      layer.source = url;
    }

    Component.onCompleted: show(Settings.wallpaper)

    Connections {
      target: Settings
      function onWallpaperChanged() { win.show(Settings.wallpaper); }
    }

    component Layer: Image {
      id: layer
      anchors.fill: parent
      fillMode: Image.PreserveAspectCrop
      asynchronous: true
      cache: false
      opacity: 0
      Behavior on opacity { NumberAnimation { duration: Settings.animNormal * 3; easing.type: Easing.InOutQuad } }

      // Decoded at its own size and scaled by the GPU: asking the decoder to
      // upscale a small wallpaper to the screen cost ~50 MB. Only an image
      // bigger than the screen is decoded again, down to cover it.
      property bool capped: false
      readonly property size screenPx: Qt.size(win.modelData.width * win.modelData.devicePixelRatio,
                                               win.modelData.height * win.modelData.devicePixelRatio)

      onStatusChanged: {
        if (status === Image.Error) return console.error("Failed to load wallpaper:", source);
        if (status !== Image.Ready) return;
        if (!capped && implicitWidth > screenPx.width && implicitHeight > screenPx.height) {
          capped = true;
          sourceSize = screenPx;
          return;
        }
        if (layer !== win.front) {
          win.front.z = 0;
          z = 1;
          win.front = layer;
        }
        opacity = 1;
      }

      onOpacityChanged: {
        if (opacity < 1 || layer !== win.front || win.back.source.toString() === "") return;
        win.back.opacity = 0;
        win.back.source = "";
      }
    }

    Layer { id: a }
    Layer { id: b }
  }
}
