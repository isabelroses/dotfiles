import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Battery from "resource:///com/github/Aylur/ags/service/battery.js";
import App from "resource:///com/github/Aylur/ags/app.js";
import icons from "../../../icons.js";
import Avatar from "../../../misc/Avatar.js";
import { uptime } from "../../../variables.js";

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
                visible: Battery.bind("available"),
                children: [
                  Widget.Icon({ icon: Battery.bind("icon_name") }),
                  Widget.Label({
                    label: Battery.bind("percent").transform((p) => `${p}%`),
                  }),
                ],
              }),
              Widget.Label({
                class_name: "uptime",
                label: uptime.bind().transform((v) => `up: ${v}`),
              }),
            ],
          }),
          Widget.Box({
            vertical: true,
            children: [
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
