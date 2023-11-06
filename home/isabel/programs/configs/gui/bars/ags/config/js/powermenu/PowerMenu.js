import icons from "../icons.js";
import PowerMenu from "../services/powermenu.js";
import PopupWindow from "../misc/PopupWindow.js";
import { Widget } from "../imports.js";

const SysButton = (action, label) =>
    Widget.Button({
        on_clicked: () => PowerMenu.action(action),
        child: Widget.Box({
            vertical: true,
            children: [
                Widget.Icon(icons.powermenu[action]),
                Widget.Label(label),
            ],
        }),
    });

export default () =>
    PopupWindow({
        name: "powermenu",
        expand: true,
        content: Widget.Box({
            class_name: "powermenu",
            homogeneous: true,
            children: [
                SysButton("sleep", "Sleep"),
                SysButton("reboot", "Reboot"),
                SysButton("logout", "Log Out"),
                SysButton("shutdown", "Shutdown"),
            ],
        }),
    });
