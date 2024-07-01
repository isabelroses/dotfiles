import Widget from "resource:///com/github/Aylur/ags/widget.js";
import { ArrowToggleButton, Menu, opened } from "../ToggleButton.js";
import themes from "../../../themes.js";
import icons from "../../../icons.js";
import options from "../../../options.js";
import { setTheme } from "../../../settings/theme.js";

export const ThemeToggle = () =>
  ArrowToggleButton({
    name: "theme",
    icon: Widget.Label().bind("label", options.theme.icon),
    label: Widget.Label().bind("label", options.theme.name),
    connection: [opened, () => opened.value === "theme"],
    activate: () => opened.setValue("theme"),
    activateOnArrow: false,
    deactivate: () => {},
  });

export const ThemeSelector = () =>
  Menu({
    name: "theme",
    icon: Widget.Label().bind("label", options.theme.icon),
    content: [
      ...themes.map(({ name, icon }) =>
        Widget.Button({
          on_clicked: () => setTheme(name),
          child: Widget.Box({
            children: [
              Widget.Label(icon),
              Widget.Label(name),
              Widget.Icon({
                icon: icons.tick,
                hexpand: true,
                hpack: "end",
                visible: options.theme.name
                  .bind("value")
                  .transform((v) => v === name),
              }),
            ],
          }),
        }),
      ),
    ],
  });
