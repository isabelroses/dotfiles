import "lib/session";
import "style/style";
import init from "lib/init";
import options from "options";
import Bar from "widget/bar/bar";
import Launcher from "widget/launcher/launcher";
import NotificationPopups from "widget/notifications/notificationpopups";
import PowerMenu from "widget/powermenu/powermenu";
import { forMonitors } from "lib/utils";
import { setupDash } from "widget/dash/dash";

App.config({
  onConfigParsed: () => {
    setupDash();
    init();
  },
  closeWindowDelay: {
    launcher: options.transition.value,
    dash: options.transition.value,
    datemenu: options.transition.value,
  },
  windows: () => [
    ...forMonitors(Bar),
    ...forMonitors(NotificationPopups),
    Launcher(),
    PowerMenu(),
  ],
});
