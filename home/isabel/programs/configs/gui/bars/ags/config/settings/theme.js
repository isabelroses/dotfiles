import { USER } from "resource:///com/github/Aylur/ags/utils.js";
import options from "../options.js";
import themes from "../themes.js";
import { reloadScss } from "./scss.js";
import { setupHyprland } from "./hyprland.js";
import { wallpaper } from "./wallpaper.js";

/** @param {string} name */
export function setTheme(name) {
  options.reset();
  const theme = themes.find((t) => t.name === name);
  if (!theme) return print("No theme named " + name);

  options.apply(theme.options);
  reloadScss();
  setupHyprland();
  wallpaper();
}

export const WP = `/home/${USER}/media/pictures/wallpapers/`;

export const lightColors = {
  "theme.scheme": "light",
  "color.red": "#d20f39",
  "color.green": "#40a02b",
  "color.yellow": "#df8e1d",
  "color.blue": "#209fb5",
  "color.magenta": "#8839ef",
  "color.teal": "#179299",
  "color.orange": "#fe640b",
  "theme.bg": "#eff1f5",
  "theme.fg": "#4c4f69",
};

export const Theme = ({ name, icon = " ", ...options }) => ({
  name,
  icon,
  options: {
    "theme.name": name,
    "theme.icon": icon,
    ...options,
  },
});

let settingsDialog;
export async function openSettings() {
  if (settingsDialog) return settingsDialog.present();

  try {
    settingsDialog = (await import("./SettingsDialog.js")).default;
    settingsDialog.present();
  } catch (error) {
    if (error instanceof Error) console.error(error.message);
  }
}
