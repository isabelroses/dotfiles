import icons from "../../icons.js";
import HoverRevealer from "../../misc/HoverRevealer.js";
import { Widget, Notifications, Utils, App } from "../../imports.js";

export default ({ direction = "left" } = {}) =>
    HoverRevealer({
        class_name: "notifications panel-button",
        eventboxConnections: [
            ["button-press-event", () => App.openWindow("dashboard")],
            [
                Notifications,
                (box) =>
                    (box.visible =
                        Notifications.notifications.length > 0 ||
                        Notifications.dnd),
            ],
        ],
        connections: [
            [
                Notifications,
                (revealer) => {
                    const title = Notifications.notifications[0]?.summary;
                    if (revealer._title === title) return;

                    revealer._title = title;
                    revealer.reveal_child = true;
                    Utils.timeout(3000, () => {
                        revealer.reveal_child = false;
                    });
                },
            ],
        ],
        direction,
        indicator: Widget.Icon({
            binds: [
                [
                    "icon",
                    Notifications,
                    "dnd",
                    (dnd) =>
                        dnd
                            ? icons.notifications.silent
                            : icons.notifications.noisy,
                ],
            ],
        }),
        child: Widget.Label({
            truncate: "end",
            max_width_chars: 40,
            binds: [
                [
                    "label",
                    Notifications,
                    "notifications",
                    (n) => n[0]?.summary || "",
                ],
            ],
        }),
    });
