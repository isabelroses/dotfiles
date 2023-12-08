import Applauncher from "./windows/applauncher/Applauncher.js";
import Dashboard from "./windows/dashboard/Dashboard.js";
import Notifications from "./windows/notifications/Notifications.js";
import PowerMenu from "./windows/powermenu/PowerMenu.js";
import QuickSettings from "./windows/quicksettings/QuickSettings.js";
import TopBar from "./windows/bar/TopBar.js";
// import LeftBar from "./windows/bar/LeftBar.js";
import OSD from "./misc/OSD.js";
import { init } from "./settings/setup.js";
import { initWallpaper } from "./settings/wallpaper.js";
import { forMonitors } from "./utils.js";
import options from "./options.js";

initWallpaper();

const windows = () => [
  forMonitors(TopBar),
  // forMonitors(LeftBar),
  forMonitors(OSD),
  forMonitors(Notifications),
  Applauncher(),
  Dashboard(),
  QuickSettings(),
  PowerMenu(),
];

export default {
  onConfigParsed: init,
  windows: windows().flat(1),
  maxStreamVolume: 1.05,
  cacheNotificationActions: true,
  closeWindowDelay: {
    quicksettings: options.transition.value,
    dashboard: options.transition.value,
  },
};
