/**
 * An object holding Options that are Variables with cached values.
 *
 * to update an option at runtime simply run
 * ags -r "options.path.to.option.setValue('value')"
 *
 * resetting:
 * ags -r "options.reset()"
 */

import { Option, resetOptions, getValues, apply } from "./settings/option.js";
import { USER } from "resource:///com/github/Aylur/ags/utils.js";
import themes from "./themes.js";

export default {
    reset: resetOptions,
    values: getValues,
    apply: apply,

    theme: {
        name: Option(themes[0].name),
        icon: Option(themes[0].icon),
    },

    spacing: Option(9),
    padding: Option(8),
    radii: Option(9),
    transition: Option(200, { unit: "ms" }),

    font: {
        font: Option("Ubuntu Nerd Font", { scss: "font" }),
        mono: Option("Mononoki Nerd Font", { scss: "mono-font" }),
        size: Option(13, { scss: "font-size", unit: "pt" }),
    },

    popover: {
        padding: { multiplier: Option(1.4, { unit: "" }) },
    },

    color: {
        red: Option("#f38ba8", { scss: "red" }),
        green: Option("#a6e3a1", { scss: "green" }),
        yellow: Option("#f9e2af", { scss: "yellow" }),
        blue: Option("#74c7ec", { scss: "blue" }),
        magenta: Option("#cba6f7", { scss: "magenta" }),
        teal: Option("#94e2d5", { scss: "teal" }),
        orange: Option("#fab387", { scss: "orange" }),

        scheme: Option("dark"),
        bg: Option("#1e1e2e", { scss: "bg-color" }),
        fg: Option("#cdd6f4", { scss: "fg-color" }),
    },

    hover_fg: Option("#cdd6f4", { scss: "hover-fg" }),
    shader_fg: Option("#fff", { scss: "shader-fg" }),

    accent: {
        accent: Option("$blue", { scss: "accent" }),
        fg: Option("$bg-color"),
        gradient: Option("to right, $accent, lighten($accent, 6%)"),
    },

    widget: {
        bg: Option("$fg_color", { scss: "_widget-bg" }),
        opacity: Option(94, { unit: "" }),
    },

    border: {
        color: Option("$fg_color", { scss: "_border-color" }),
        opacity: Option(97, { unit: "" }),
        width: Option(1),
    },

    shadow: Option("rgba(0, 0, 0, .6)"),
    drop_shadow: Option(true, { scss: "drop-shadow" }),
    avatar: Option(`/home/${USER}/media/pictures/pfps/avatar`, {
        format: (v) => `"${v}"`,
    }),

    hypr: {
        wm_gaps: Option(8, { scss: "wm-gaps" }),
    },

    applauncher: {
        width: Option(500),
        height: Option(500),
        iconSize: Option(52),
    },

    bar: {
        separators: Option(true),
        style: Option("floating"),
        flat_buttons: Option(true, { scss: "bar-flat-buttons" }),
        position: Option("top"),
        icon: Option("distro-icon"),
    },

    battery: {
        showPercentage: Option(true, { noReload: false }),
        bar: {
            width: Option(70),
            height: Option(14),
        },
        low: Option(30),
        medium: Option(50),
    },

    desktop: {
        fg_color: Option("#fff", { scss: "wallpaper-fg" }),
        wallpaper: Option(
            `/home/${USER}/media/pictures/wallpapers/catgirl.jpg`,
            { format: (v) => `"${v}"` },
        ),
        screen_corners: Option(false, { scss: "screen-corners" }),
    },

    notifications: {
        blackList: Option(["Spotify"]), // app-name | app-entry
        width: Option(450),
    },

    dashboard: {
        sys_info_size: Option(70, { scss: "sys-info-size" }),
    },

    mpris: {
        blackList: Option(["Caprine"], {
            description: "bus-name | name | identity | entry",
        }),
        preferred: Option("spotify", {
            summary: "Preferred player on the bar",
        }),
    },

    workspaces: Option(7, {
        summary: "No. workspaces on bar and overview",
        description: "Set it to 0 to make it dynamic",
    }),

    // path to read temperature from
    temperature: "/sys/class/thermal/thermal_zone0/temp",

    // at what intervals should cpu, ram, temperature refresh
    systemFetchInterval: 5000,

    // the slide down animation on quicksettings and dashboard
    windowAnimationDuration: 250,
};
