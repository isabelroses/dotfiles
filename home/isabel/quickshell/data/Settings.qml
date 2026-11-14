pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  property Colors colors: Colors {}
  property Fonts fonts: Fonts {}

  component Colors: QtObject {
    property color base: "#000000"
    property color surface: "#0b0b11"
    property color surfaceRaised: "#11111b"
    property color overlay: "#181825"

    property color border: "#313244"
    property color borderStrong: "#45475a"

    property color text: "#cdd6f4"
    property color textMuted: "#a6adc8"
    property color textSubtle: "#6c7086"

    property color rosewater: "#f5e0dc"
    property color flamingo: "#f2cdcd"
    property color pink: "#f5c2e7"
    property color mauve: "#cba6f7"
    property color red: "#f38ba8"
    property color maroon: "#eba0ac"
    property color peach: "#fab387"
    property color yellow: "#f9e2af"
    property color green: "#a6e3a1"
    property color teal: "#94e2d5"
    property color sky: "#89dceb"
    property color sapphire: "#74c7ec"
    property color blue: "#89b4fa"
    property color lavender: "#b4befe"

    property list<color> pops: [pink, sky, green, yellow, peach, blue, mauve, teal, red, lavender]

    property color accent: ({ rosewater, flamingo, pink, mauve, red, maroon, peach, yellow,
                              green, teal, sky, sapphire, blue, lavender })[Config.get("appearance.accent")] ?? pink
    property color textOnAccent: "#11111b"
    property color accentSoft: Utils.withAlpha(accent, 0.14)

    property color error: red
    property color success: green

    property color scrim: "#b0000000"
  }

  component Fonts: QtObject {
    property string sans: "Inter"
    property string mono: "Berkeley Mono"
  }

  readonly property int _r: Config.get("appearance.rounding")
  property int rounding: Math.round(_r * 1.5)
  property int radiusMd: _r
  property int radiusSm: _r
  property int radiusXs: Math.ceil(_r / 2)
  property int radiusRound: _r

  property int barWidth: 52
  readonly property string barSide: Config.get("bar.side")
  readonly property bool barOnRight: barSide === "right"

  readonly property real _speed: Config.get("appearance.animations") ? Config.get("appearance.animation_speed") : 0
  property int animFast: 120 * _speed
  property int animNormal: 220 * _speed

  readonly property string username: Config.get("general.username")
  readonly property string profilePicture: Config.get("general.profile_picture")
  readonly property string wallpaper: Config.get("general.wallpaper")

  readonly property list<string> notificationBlacklist: Config.get("notifications.blacklist")
}
