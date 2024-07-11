import { opt, mkOptions } from "lib/option";

const options = mkOptions(OPTIONS, {
  theme: {
    dark: {
      primary: {
        bg: opt("#74c7ec"),
        fg: opt("#11111b"),
      },
      error: {
        bg: opt("#f38ba8"),
        fg: opt("#11111b"),
      },
      bg: opt("#181825"),
      fg: opt("#cdd6f4"),
      widget: opt("#1e1e2e"),
      border: opt("#313244"),
      wallpaper: opt(
        `/home/${Utils.USER}/media/pictures/wallpapers/catgirl.jpg`,
      ),
    },
    light: {
      primary: {
        bg: opt("#209fb5"),
        fg: opt("#dce0e8"),
      },
      error: {
        bg: opt("#d20f39"),
        fg: opt("#dce0e8"),
      },
      bg: opt("#e6e9ef"),
      fg: opt("#4c4f69"),
      widget: opt("#eff1f5"),
      border: opt("#ccd0da"),
      wallpaper: opt(
        `/home/${Utils.USER}/media/pictures/wallpapers/card_after_training.png`,
      ),
    },
    scheme: opt<"dark" | "light">("dark"),
    widget: { opacity: opt(94) },
    border: {
      width: opt(1),
      opacity: opt(96),
    },

    shadows: opt(false),
    padding: opt(7),
    spacing: opt(12),
    radius: opt(11),
  },

  transition: opt(200),

  font: {
    size: opt(13),
    name: opt("Maple Mono"),
  },

  bar: {
    position: opt<"top" | "bottom">("top"),
    corners: opt(true),
    date: {
      format: opt("%I:%M:%S | %d/%m/%y"),
    },
    battery: {
      bar: opt<"hidden" | "regular" | "whole">("regular"),
      charging: opt("#a6e3a1"),
      percentage: opt(true),
      blocks: opt(7),
      width: opt(50),
      low: opt(30),
    },
    workspaces: {
      workspaces: opt(7),
    },
    systray: {
      ignore: opt(["KDE Connect Indicator", "spotify-client"]),
    },
    media: {
      monochrome: opt(true),
      preferred: opt("spotify"),
      direction: opt<"left" | "right">("right"),
      format: opt("{title} - {artists}"),
      length: opt(40),
    },
  },

  launcher: {
    width: opt(0),
    margin: opt(80),
    apps: {
      iconSize: opt(62),
      max: opt(6),
    },
  },

  powermenu: {
    sleep: opt("systemctl suspend"),
    reboot: opt("systemctl reboot"),
    logout: opt("hyprctl dispatch exit 0"),
    shutdown: opt("shutdown now"),
    layout: opt<"line" | "box">("line"),
    labels: opt(true),
  },

  dash: {
    avatar: opt(`/home/${Utils.USER}/media/pictures/pfps/avatar`),
    width: opt(380),
    position: opt<"left" | "center" | "right">("right"),
    networkSettings: opt("nm-connection-editor"),
    media: {
      monochromeIcon: opt(true),
      coverSize: opt(100),
    },
  },

  notifications: {
    position: opt<Array<"top" | "bottom" | "left" | "right">>(["top", "right"]),
    blacklist: opt(["Spotify"]),
    width: opt(440),
  },
});

globalThis["options"] = options;
export default options;
