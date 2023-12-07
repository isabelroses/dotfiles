import SystemTray from "resource:///com/github/Aylur/ags/service/systemtray.js";
import Widget from "resource:///com/github/Aylur/ags/widget.js";
import Variable from "resource:///com/github/Aylur/ags/variable.js";
import Mpris from "resource:///com/github/Aylur/ags/service/mpris.js";
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
import options from "../../options.js";

const submenuItems = Variable(1);
SystemTray.connect("changed", () => {
    submenuItems.setValue(SystemTray.items.length + 1);
});

/**
 * @template T
 * @param {T=} service
 * @param {(self: T) => boolean=} condition
 */
const SeparatorDot = (service, condition) => {
    const visibility = (self) => {
        if (!options.bar.separators.value) return (self.visible = false);

        self.visible =
            condition && service
                ? condition(service)
                : options.bar.separators.value;
    };

    const conn = service ? [[service, visibility]] : [];
    return Widget.Separator({
        connections: [["draw", visibility], ...conn],
        binds: [["visible", options.bar.separators]],
        vpack: "center",
    });
};

const Start = () =>
    Widget.Box({
        class_name: "start",
        vertical: true,
        children: [
            ApplauncherButton(),
            Workspaces(),
            Widget.Box({ hexpand: true }),
            NotificationIndicator(),
        ],
    });

const Center = () =>
    Widget.Box({
        class_name: "center",
        vertical: true,
        children: [DateButton()],
    });

const End = () =>
    Widget.Box({
        class_name: "end",
        vertical: true,
        children: [
            SeparatorDot(Mpris, (m) => m.players.length > 0),
            MediaIndicator({ vertical: true }),
            Widget.Box({ hexpand: true }),

            SubMenu({
                items: submenuItems,
                children: [SysTray({ vertical: true }), ColorPicker()],
            }),
            SystemIndicators({ vertical: true }),
            BatteryBar({ vertical: true }),
            PowerMenu({ vertical: true }),
        ],
    });

/** @param {number} monitor */
export default (monitor) =>
    Widget.Window({
        name: `bar${monitor}`,
        class_name: "transparent",
        exclusivity: "exclusive",
        monitor,
        binds: [
            [
                "anchor",
                options.bar.position,
                "value",
                (pos) => [pos, "left", "bottom"],
            ],
        ],
        child: Widget.CenterBox({
            class_name: "panel",
            vertical: true,
            start_widget: Start(),
            center_widget: Center(),
            end_widget: End(),
        }),
    });
