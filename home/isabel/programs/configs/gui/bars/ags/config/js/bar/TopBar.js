import ApplauncherButton from "./buttons/ApplauncherButton.js";
import Workspaces from "./buttons/Workspaces.js";
import MediaIndicator from "./buttons/MediaIndicator.js";
import DateButton from "./buttons/DateButton.js";
import NotificationIndicator from "./buttons/NotificationIndicator.js";
import SysTray from "./buttons/SysTray.js";
import ColorPicker from "./buttons/ColorPicker.js";
import SystemIndicators from "./buttons/SystemIndicators.js";
import PowerMenu from "./buttons/PowerMenu.js";
import BatteryBar from "./buttons/BatteryBar.js";
import SubMenu from "./buttons/SubMenu.js";
import { SystemTray, Widget, Variable } from "../imports.js";
import { Notifications, Mpris, Battery } from "../imports.js";

const submenuItems = Variable(1);
SystemTray.connect("changed", () => {
    submenuItems.setValue(SystemTray.items.length + 1);
});

const SeparatorDot = (service, condition) =>
    Widget.Separator({
        orientation: 0,
        vpack: "center",
        connections: !service
            ? []
            : [
                  [
                      service,
                      (dot) => {
                          dot.visible = condition(service);
                      },
                  ],
              ],
    });

const Start = () =>
    Widget.Box({
        class_name: "start",
        children: [
            ApplauncherButton(),
            SeparatorDot(),
            Workspaces(),
            SeparatorDot(),
            Widget.Box({ hexpand: true }),
            NotificationIndicator(),
            SeparatorDot(
                Notifications,
                (n) => n.notifications.length > 0 || n.dnd,
            ),
        ],
    });

const Center = () =>
    Widget.Box({
        class_name: "center",
        children: [DateButton()],
    });

const End = () =>
    Widget.Box({
        class_name: "end",
        children: [
            SeparatorDot(Mpris, (m) => m.players.length > 0),
            MediaIndicator(),
            Widget.Box({ hexpand: true }),

            SubMenu({
                items: submenuItems,
                children: [SysTray(), ColorPicker()],
            }),
            SeparatorDot(),
            SystemIndicators(),
            SeparatorDot(Battery, (b) => b.available),
            BatteryBar(),
            SeparatorDot(),
            PowerMenu(),
        ],
    });

export default (monitor) =>
    Widget.Window({
        name: `bar${monitor}`,
        exclusive: true,
        monitor,
        anchor: ["top", "left", "right"],
        child: Widget.CenterBox({
            class_name: "panel",
            start_widget: Start(),
            center_widget: Center(),
            end_widget: End(),
        }),
    });
