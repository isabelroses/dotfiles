import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Battery from "resource:///com/github/Aylur/ags/service/battery.js";
import App from "resource:///com/github/Aylur/ags/app.js";
import icons from "../../../icons.js";
import PowerMenu from "../../../services/powermenu.js";
import Avatar from "../../../misc/Avatar.js";
import { uptime } from "../../../variables.js";
import { openSettings } from "../../../settings/theme.js";

export default () =>
  Widget.Box({
    class_name: "header horizontal",
    children: [
      Avatar(),
      Widget.Box({
        hpack: "end",
        vpack: "center",
        hexpand: true,
        children: [
          Widget.Box({
            vertical: true,
            children: [
              Widget.Box({
                class_name: "battery horizontal",
                children: [
                  Widget.Icon({ binds: [["icon", Battery, "icon-name"]] }),
                  Widget.Label({
                    binds: [["label", Battery, "percent", (p) => `${p}%`]],
                  }),
                ],
              }),
              Widget.Label({
                class_name: "uptime",
                binds: [["label", uptime, "value", (v) => `uptime: ${v}`]],
              }),
            ],
          }),
          Widget.Box({
            vertical: true,
            children: [
              Widget.Button({
                on_clicked: openSettings,
                child: Widget.Icon(icons.ui.settings),
              }),
              Widget.Button({
                on_clicked: () => App.openWindow("powermenu"),
                child: Widget.Icon(icons.powermenu.shutdown),
              }),
            ],
          }),
        ],
      }),
    ],
  });
