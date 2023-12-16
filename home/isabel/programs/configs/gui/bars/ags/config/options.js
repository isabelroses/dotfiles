/**
 * An object holding Options that are Variables with cached values.
 *
 * to update an option at runtime simply run
 * ags -r "options.path.to.option.setValue('value')"
 *
 * resetting:
 * ags -r "options.reset()"
 */

import { apply, getValues, Option, resetOptions } from "./settings/option.js";
import { USER } from "resource:///com/github/Aylur/ags/utils.js";
import themes from "./themes.js";

export default {
  reset: resetOptions,
  values: getValues,
  apply: apply,

  spacing: Option(9),
  padding: Option(8),
  radii: Option(15),

  popover_padding_multiplier: Option(1.4, {
    category: "General",
    note: "popover-padding: padding x this",
    type: "float",
    unit: "",
  }),

  font: {
    font: Option("Ubuntu Nerd Font", {
      type: "font",
      title: "Font",
      scss: "font",
    }),
    mono: Option("Mononoki Nerd Font", {
      title: "Monospaced Font",
      scss: "mono-font",
    }),
    size: Option(13, {
      scss: "font-size",
      unit: "pt",
    }),
  },

  color: {
    red: Option("#f38ba8", { scss: "red" }),
    green: Option("#a6e3a1", { scss: "green" }),
    yellow: Option("#f9e2af", { scss: "yellow" }),
    blue: Option("#74c7ec", { scss: "blue" }),
    magenta: Option("#cba6f7", { scss: "magenta" }),
    teal: Option("#94e2d5", { scss: "teal" }),
    orange: Option("#fab387", { scss: "orange" }),
  },

  theme: {
    name: Option(themes[0].name, {
      category: "exclude",
      note: "Name to show as active in quicktoggles",
    }),

    icon: Option(themes[0].icon, {
      category: "exclude",
      note: "Icon to show as active in quicktoggles",
    }),

    scheme: Option("dark", {
      enums: ["dark", "light"],
      type: "enum",
      note: "Color scheme to set on Gtk apps: 'ligth' or 'dark'",
      title: "Color Scheme",
      scss: "color-scheme",
    }),

    bg: Option("#1e1e2e", {
      title: "Background Color",
      scss: "bg-color",
    }),
    fg: Option("#cdd6f4", {
      title: "Foreground Color",
      scss: "fg-color",
    }),

    accent: {
      accent: Option("$blue", {
        category: "Theme",
        title: "Accent Color",
        scss: "accent",
      }),
      fg: Option("$bg-color", {
        category: "Theme",
        title: "Accent Foreground Color",
        scss: "accent-fg",
      }),
      gradient: Option("to right, $accent, lighten($accent, 6%)", {
        category: "Theme",
        title: "Accent Linear Gradient",
        scss: "accent-gradient",
      }),
    },

    widget: {
      bg: Option("$fg_color", {
        category: "Theme",
        title: "Widget Background Color",
        scss: "_widget-bg",
      }),
      opacity: Option(94, {
        category: "Theme",
        title: "Widget Background Opacity",
        unit: "",
        scss: "widget-opacity",
      }),
    },
  },

  border: {
    color: Option("$fg_color", {
      category: "Border",
      title: "Border Color",
      scss: "_border-color",
    }),
    opacity: Option(97, {
      category: "Border",
      title: "Border Opacity",
      unit: "",
    }),
    width: Option(1, {
      category: "Border",
      title: "Border Width",
    }),
  },

  shadow: Option("rgba(0, 0, 0, .6)"),
  drop_shadow: Option(true, { scss: "drop-shadow" }),

  hypr: {
    wm_gaps: Option(8, {
      category: "General",
      scss: "wm-gaps",
      note: "wm-gaps",
      type: "float",
      unit: "",
    }),
  },

  transition: Option(200, {
    category: "exclude",
    note: "Transition time on aminations in ms, e.g on hover",
    unit: "ms",
  }),

  applauncher: {
    width: Option(500),
    height: Option(500),
    icon_size: Option(52),
  },

  bar: {
    position: Option("top", {
      enums: ["top", "bottom"],
      type: "enum",
    }),
    style: Option("floating", {
      enums: ["floating", "normal", "separated"],
      type: "enum",
    }),
    flat_buttons: Option(true, { scss: "bar-flat-buttons" }),
    separators: Option(true),
    icon: Option("distro-icon", {
      note: '"distro-icon" or a single font',
    }),
  },

  battery: {
    show_percentage: Option(true, { noReload: false, category: "exclude" }),
    bar: {
      width: Option(70, { category: "Bar" }),
      height: Option(14, { category: "Bar" }),
      full: Option(false, { category: "Bar" }),
    },
    low: Option(25, { category: "Bar" }),
    medium: Option(50, { category: "Bar" }),
  },

  desktop: {
    avatar: Option(``, {
      format: (v) => `"${v}"`,
    }),
    wallpaper: {
      fg: Option("#fff", { scss: "wallpaper-fg" }),
      img: Option(themes[0].options["desktop.wallpaper.img"], {
        scssFormat: (v) => `"${v}"`,
        type: "img",
      }),
    },
    avatar: Option(`/home/${USER}/media/pictures/pfps/avatar`, {
      scssFormat: (v) => `"${v}"`,
      type: "img",
      note: "displayed in quicksettings and locksreen",
    }),
    drop_shadow: Option(true, { scss: "drop-shadow" }),
    shadow: Option("rgba(0, 0, 0, .6)", { scss: "shadow" }),
  },

  notifications: {
    black_list: Option(["Spotify"], { note: "app-name | entry" }),
    position: Option(["top"], { note: "anchor" }),
    width: Option(450),
  },

  dashboard: {
    sys_info_size: Option(70, {
      category: "Desktop",
      scss: "sys-info-size",
    }),
  },

  mpris: {
    black_list: Option(["Caprine"], {
      category: "Bar",
      title: "List of blacklisted mpris players",
      note: "filters for bus-name, name, identity, entry",
    }),
    preferred: Option("spotify", {
      category: "Bar",
      title: "Preferred player",
    }),
  },

  workspaces: Option(7, {
    category: "Bar",
    title: "No. workspaces on bar and overview",
    note: "Set it to 0 to make it dynamic",
  }),

  // path to read temperature from
  temperature: "/sys/class/thermal/thermal_zone0/temp",

  // at what intervals should cpu, ram, temperature refresh
  systemFetchInterval: 5000,
};
