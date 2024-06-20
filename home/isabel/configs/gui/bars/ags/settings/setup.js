import * as Utils from "resource:///com/github/Aylur/ags/utils.js";
import Battery from "resource:///com/github/Aylur/ags/service/battery.js";
import Notifications from "resource:///com/github/Aylur/ags/service/notifications.js";
import options from "../options.js";
import icons from "../icons.js";
import { reloadScss, scssWatcher } from "./scss.js";
import { wallpaper } from "./wallpaper.js";
import { globals } from "./globals.js";
import Gtk from "gi://Gtk";

export function init() {
  notificationBlacklist();
  warnOnLowBattery();
  globals();
  gsettigsColorScheme();
  gtkFontSettings();
  scssWatcher();

  reloadScss();
  wallpaper();
}

function gsettigsColorScheme() {
  if (!Utils.exec("which gsettings")) return;

  options.theme.scheme.connect("changed", ({ value }) => {
    const gsettings = "gsettings set org.gnome.desktop.interface color-scheme";
    Utils.execAsync(`${gsettings} "prefer-${value}"`).catch((err) =>
      console.error(err.message),
    );
  });
}

function gtkFontSettings() {
  const settings = Gtk.Settings.get_default();
  if (!settings) {
    console.error(Error("Gtk.Settings unavailable"));
    return;
  }

  const callback = () => {
    const { size, font } = options.font;
    settings.gtk_font_name = `${font.value} ${size.value}`;
  };

  options.font.font.connect("notify::value", callback);
  options.font.size.connect("notify::value", callback);
}

function notificationBlacklist() {
  Notifications.connect("notified", (_, id) => {
    const n = Notifications.getNotification(id);
    options.notifications.black_list.value.forEach((item) => {
      if (n?.app_name.includes(item) || n?.app_entry?.includes(item)) n.close();
    });
  });
}

function warnOnLowBattery() {
  Battery.connect("notify::percent", () => {
    const low = options.battery.low.value;
    if (
      Battery.percent !== low ||
      Battery.percent !== low / 2 ||
      !Battery.charging
    )
      return;

    Utils.execAsync([
      "notify-send",
      `${Battery.percent}% Battery Percentage`,
      "-i",
      icons.battery.warning,
      "-u",
      "critical",
    ]);
  });
}
