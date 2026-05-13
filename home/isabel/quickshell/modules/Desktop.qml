import "root:/components"
import "root:/data"
import Quickshell
import Quickshell.Wayland
import QtQuick

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: backgroundPanel
        property var modelData
        screen: modelData

        WlrLayershell.exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Background

        anchors {
          top: true
          bottom: true
          left: true
          right: true
        }

        Image {
          id: backgroundImage

          anchors.fill: parent
          fillMode: Image.PreserveAspectCrop
          source: Settings.wallpaper

          onStatusChanged: {
            if (status === Image.Error) {
              console.error("Failed to load background image:", source);
            }
          }
        }
    }
}
