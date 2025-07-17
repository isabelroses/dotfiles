pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  property Colors colors: Colors {}

  component Colors: QtObject {
    property color backgroundLightest: "#313244"
    property color backgroundLighter: "#1e1e2e"
    property color background: "#181825"
    property color backgroundDarker: "#11111b"
    property color foreground: "#cdd6f4"
    property color accent: "#89b4fa"
    property color error: "#f38ba8"
    property color warning: "#fab387"
    property color success: "#a6e3a1"
    property color info: "#94e2d5"
    property color border: "#1e1e2e"
  }

  property string wallpaper: "/home/isabel/media/pictures/wallpapers/00387.webp";
}
