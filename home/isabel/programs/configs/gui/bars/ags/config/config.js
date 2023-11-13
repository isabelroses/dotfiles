import Applauncher from "./js/applauncher/Applauncher.js";
import Dashboard from "./js/dashboard/Dashboard.js";
import Notifications from "./js/notifications/Notifications.js";
import OSD from "./js/osd/OSD.js";
import PowerMenu from "./js/powermenu/PowerMenu.js";
import QuickSettings from "./js/quicksettings/QuickSettings.js";
import ScreenCorners from "./js/screencorner/ScreenCorners.js";
import SettingsDialog from "./js/settings/SettingsDialog.js";
import TopBar from "./js/bar/TopBar.js";
import Verification from "./js/powermenu/Verification.js";
import options from "./js/options.js";
import { init } from "./js/settings/setup.js";
import { forMonitors } from "./js/utils.js";

init();

const windows = () => [
    forMonitors(TopBar),
    forMonitors(ScreenCorners),
    forMonitors(OSD),
    forMonitors(Notifications),
    SettingsDialog(),
    Applauncher(),
    Dashboard(),
    QuickSettings(),
    PowerMenu(),
    Verification(),
];

export default {
    windows: windows().flat(1),
    maxStreamVolume: 1.05,
    cacheNotificationActions: true,
    closeWindowDelay: {
        quicksettings: options.transition.value,
        dashboard: options.transition.value,
    },
};
