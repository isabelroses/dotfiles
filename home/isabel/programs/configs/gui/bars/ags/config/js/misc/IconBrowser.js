import RegularWindow from "./RegularWindow.js";
import { Widget } from "../imports.js";
import Gtk from "gi://Gtk";

export default () => {
    const selected = Widget.Label({
        css: "font-size: 1.2em;",
    });

    const flowbox = Widget.FlowBox({
        min_children_per_line: 10,
        connections: [
            [
                "child-activated",
                (_, { child }) => {
                    selected.label = child.icon_name;
                },
            ],
        ],
        setup: (self) => {
            Gtk.IconTheme.get_default()
                .list_icons(null)
                .sort()
                .map((icon) => {
                    !icon.endsWith(".symbolic") &&
                        self.insert(
                            Widget.Icon({
                                icon,
                                size: 38,
                            }),
                            -1,
                        );
                });

            self.show_all();
        },
    });

    const entry = Widget.Entry({
        on_change: ({ text }) =>
            flowbox.get_children().forEach((child) => {
                child.visible = child.child.icon_name.includes(text);
            }),
    });

    return RegularWindow({
        name: "icons",
        visible: true,
        child: Widget.Box({
            css: "padding: 30px;",
            spacing: 20,
            vertical: true,
            children: [
                entry,
                Widget.Scrollable({
                    hscroll: "never",
                    vscroll: "always",
                    hexpand: true,
                    vexpand: true,
                    css: "min-width: 500px;" + "min-height: 500px;",
                    child: flowbox,
                }),
                selected,
            ],
        }),
    });
};
