import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.data

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
      const url = Qt.resolvedUrl(path);
      if (front.source.toString() === url.toString()) return;
      (front.source.toString() === "" ? front : back).source = url;
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
      sourceSize: Qt.size(win.modelData.width * win.modelData.devicePixelRatio, win.modelData.height * win.modelData.devicePixelRatio)
      opacity: 0
      Behavior on opacity { NumberAnimation { duration: Settings.animNormal * 3; easing.type: Easing.InOutQuad } }

      onStatusChanged: {
        if (status === Image.Error) return console.error("Failed to load wallpaper:", source);
        if (status !== Image.Ready) return;
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
