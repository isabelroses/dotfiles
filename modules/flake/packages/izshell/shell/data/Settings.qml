pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  property Colors colors: Colors {}
  property Fonts fonts: Fonts {}

  component Colors: QtObject {
    readonly property bool light: Config.get("appearance.theme") === "light"
    readonly property var p: light ? latte : dark

    // catppuccin mocha text and accents over a true black base
    readonly property var dark: ({
      base: "#000000", surface: "#0b0b11", surfaceRaised: "#11111b", overlay: "#181825",
      border: "#313244", borderStrong: "#45475a",
      text: "#cdd6f4", textMuted: "#a6adc8", textSubtle: "#6c7086", textOnAccent: "#11111b",
      rosewater: "#f5e0dc", flamingo: "#f2cdcd", pink: "#f5c2e7", mauve: "#cba6f7",
      red: "#f38ba8", maroon: "#eba0ac", peach: "#fab387", yellow: "#f9e2af",
      green: "#a6e3a1", teal: "#94e2d5", sky: "#89dceb", sapphire: "#74c7ec",
      blue: "#89b4fa", lavender: "#b4befe",
      scrim: "#b0000000",
    })

    // catppuccin latte; raised surfaces step darker, mirroring how dark steps lighter
    readonly property var latte: ({
      base: "#eff1f5", surface: "#e6e9ef", surfaceRaised: "#dce0e8", overlay: "#ccd0da",
      border: "#bcc0cc", borderStrong: "#acb0be",
      text: "#4c4f69", textMuted: "#5c5f77", textSubtle: "#8c8fa1", textOnAccent: "#eff1f5",
      rosewater: "#dc8a78", flamingo: "#dd7878", pink: "#ea76cb", mauve: "#8839ef",
      red: "#d20f39", maroon: "#e64553", peach: "#fe640b", yellow: "#df8e1d",
      green: "#40a02b", teal: "#179299", sky: "#04a5e5", sapphire: "#209fb5",
      blue: "#1e66f5", lavender: "#7287fd",
      scrim: "#804c4f69",
    })

    property color base: p.base
    property color surface: p.surface
    property color surfaceRaised: p.surfaceRaised
    property color overlay: p.overlay

    property color border: p.border
    property color borderStrong: p.borderStrong

    property color text: p.text
    property color textMuted: p.textMuted
    property color textSubtle: p.textSubtle

    property color rosewater: p.rosewater
    property color flamingo: p.flamingo
    property color pink: p.pink
    property color mauve: p.mauve
    property color red: p.red
    property color maroon: p.maroon
    property color peach: p.peach
    property color yellow: p.yellow
    property color green: p.green
    property color teal: p.teal
    property color sky: p.sky
    property color sapphire: p.sapphire
    property color blue: p.blue
    property color lavender: p.lavender

    property list<color> pops: [pink, sky, green, yellow, peach, blue, mauve, teal, red, lavender]

    property color accent: ({ rosewater, flamingo, pink, mauve, red, maroon, peach, yellow,
                              green, teal, sky, sapphire, blue, lavender })[Config.get("appearance.accent")] ?? pink
    property color textOnAccent: p.textOnAccent
    property color accentSoft: Utils.withAlpha(accent, 0.14)

    property color error: red
    property color success: green

    property color scrim: p.scrim
  }

  component Fonts: QtObject {
    property string sans: "Inter"
    property string mono: "Berkeley Mono"
    property string serif: "Fraunces"
  }

  readonly property int _r: Config.get("appearance.rounding")
  property int rounding: Math.round(_r * 1.5)
  property int radiusMd: _r
  property int radiusSm: _r
  property int radiusXs: Math.ceil(_r / 2)
  property int radiusRound: _r

  // floating: cards and sheets hover with gaps; attached: one strip flush to the edge
  readonly property bool barFloating: Config.get("bar.style") === "floating"
  // reserved strip. floating: an 8px margin, the 44px card, then a gap before windows
  property int barWidth: barFloating ? 56 : 52
  readonly property int cardThickness: 44
  readonly property int cardGap: 4
  // cards are a step rounder than the controls inside them
  readonly property int cardRadius: _r > 0 ? Math.round(_r * 1.4) : 0
  // controls sitting inside a bar card, concentric with its corners
  readonly property int innerRadius: Math.max(0, cardRadius - 5)
  // floating popups (sheet, calendar, toasts, launcher) are a step rounder again
  readonly property int sheetRadius: cardRadius > 0 ? cardRadius + 4 : 0

  // radius for a thin bar, dot or pill: fully round ends, capped by the rounding setting
  function pill(size: real): real {
    return Math.min(size / 2, _r);
  }
  readonly property string barSide: Config.get("bar.side")
  readonly property bool barOnRight: barSide === "right"
  readonly property bool barOnBottom: barSide === "bottom"
  readonly property bool barVertical: barSide === "left" || barSide === "right"
  // the edge popups should open towards, away from the bar
  readonly property int barAwayEdge: ({ left: Edges.Right, right: Edges.Left, top: Edges.Bottom, bottom: Edges.Top })[barSide] ?? Edges.Right

  readonly property real _speed: Config.get("appearance.animations") ? Config.get("appearance.animation_speed") : 0
  property int animFast: 120 * _speed
  property int animNormal: 280 * _speed
  // emphasised ease: quick start, long soft landing
  readonly property list<real> curve: [0.2, 0, 0, 1, 1, 1]

  readonly property string username: Config.get("general.username")
  // unset uses the account picture
  readonly property string profilePicture: Config.get("general.profile_picture") || `/var/lib/AccountsService/icons/${username}`
  readonly property string wallpaper: Config.get("general.wallpaper")

  readonly property list<string> notificationBlacklist: Config.get("notifications.blacklist")
}
