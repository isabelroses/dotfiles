// common
const WP = `/home/${ags.Utils.USER}/media/pictures/wallpapers/`;

const mocha_colors = {
    bg_color: "#1e1e2e",
    fg_color: "#cdd6f4",
    hover_fg: "#cdd6f4",
    red: "#f38ba8",
    green: "#a6e3a1",
    yellow: "#f9e2af",
    blue: "#74c7ec",
    magenta: "#cba6f7",
    teal: "#94e2d5",
    orange: "#fab387",
};

const latte_colors = {
    bg_color: "#eff1f5",
    fg_color: "#4c4f69",
    hover_fg: "#4c4f69",
    red: "#d20f39",
    green: "#40a02b",
    yellow: "#df8e1d",
    blue: "#209fb5",
    magenta: "#8839ef",
    teal: "#179299",
    orange: "#fe640b",
};

const settings = {
    wm_gaps: 8,
    radii: 9,
    spacing: 9,
    drop_shadow: true,
    transition: 200,
    screen_corners: false,
    bar_style: "floating",
    layout: "topbar",
    border_opacity: 97,
    border_width: 1,
    widget_opacity: 94,
    font: "Ubuntu Nerd Font",
    mono_font: "Mononoki Nerd Font",
    font_size: 16,
};

const misc_colors = {
    wallpaper_fg: "white",
    shadow: "rgba(0, 0, 0, .6)",
    accent: "$blue",
    accent_fg: "$bg_color",
    widget_bg: "$fg_color",
    active_gradient: "to right, $accent, lighten($accent, 6%)",
    border_color: "$fg_color",
};

// themes
const mocha = {
    wallpaper: WP + "tempest.png",
    name: "mocha",
    color_scheme: "dark",
    icon: "",
    ...mocha_colors,
    ...settings,
    ...misc_colors,
};

const latte = {
    wallpaper: WP + "coke.jpg",
    name: "latte",
    color_scheme: "light",
    icon: "",
    ...latte_colors,
    ...settings,
    ...misc_colors,
};

export default [mocha, latte];
