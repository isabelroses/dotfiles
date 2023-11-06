import TopBar from "./js/bar/TopBar.js";
import ScreenCorners from "./js/screencorner/ScreenCorners.js";
import Dashboard from "./js/dashboard/Dashboard.js";
import OSD from "./js/osd/OSD.js";
import Applauncher from "./js/applauncher/Applauncher.js";
import PowerMenu from "./js/powermenu/PowerMenu.js";
import Verification from "./js/powermenu/Verification.js";
import Notifications from "./js/notifications/Notifications.js";
import QuickSettings from "./js/quicksettings/QuickSettings.js";
import options from "./js/options.js";
import * as setup from "./js/utils.js";
import { forMonitors } from "./js/utils.js";

setup.warnOnLowBattery();
setup.scssWatcher();
setup.globalServices();
setup.activePlayer();

const windows = () => [
    forMonitors(TopBar),
    forMonitors(ScreenCorners),
    forMonitors(OSD),
    forMonitors(Notifications),
    Applauncher(),
    Dashboard(),
    QuickSettings(),
    PowerMenu(),
    Verification(),
];

export default {
    windows: windows().flat(2),
    maxStreamVolume: 1.05,
    cacheNotificationActions: true,
    closeWindowDelay: {
        quicksettings: options.windowAnimationDuration,
        dashboard: options.windowAnimationDuration,
    },
};
