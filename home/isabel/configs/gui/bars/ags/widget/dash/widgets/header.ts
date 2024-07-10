import icons from "lib/icons";
import options from "options";
import { Action } from "service/powermenu";

const Avatar = () =>
  Widget.Box({
    class_name: "avatar",
    css: Utils.merge(
      [options.dash.avatar.bind()],
      (img) => `
        min-width: 70px;
        min-height: 70px;
        background-image: url('${img}');
        background-size: cover;
    `,
    ),
  });

const SysButton = (action: Action) =>
  Widget.Button({
    vpack: "center",
    child: Widget.Icon(icons.powermenu[action]),
    on_clicked: () => App.toggleWindow("powermenu"),
  });

export const Header = () =>
  Widget.Box(
    { class_name: "header horizontal" },
    Avatar(),
    Widget.Box({ hexpand: true }),
    Widget.Button({
      vpack: "center",
      child: Widget.Icon(icons.ui.settings),
      on_clicked: () => {
        App.closeWindow("dash");
        App.closeWindow("settings-dialog");
        App.openWindow("settings-dialog");
      },
    }),
    SysButton("logout"),
    SysButton("shutdown"),
  );
