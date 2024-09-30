import BatteryBar from "./buttons/batterybar";
import ColorPicker from "./buttons/colorpicker";
import Date from "./buttons/date";
import Launcher from "./buttons/launcher";
import Media from "./buttons/media";
import PowerMenu from "./buttons/powermenu";
import SysTray from "./buttons/systray";
import SystemIndicators from "./buttons/systemindicators";
import Workspaces from "./buttons/workspaces";
import Messages from "./buttons/messages";
import SubMenu from "./buttons/submenu";
import options from "options";

const { position } = options.bar;

export default (monitor: number) =>
  Widget.Window({
    monitor,
    class_name: "bar",
    name: `bar${monitor}`,
    exclusivity: "exclusive",
    margins: [8, 8, 0, 8],
    anchor: position.bind().as((pos) => [pos, "right", "left"]),
    child: Widget.CenterBox({
      css: "min-width: 2px; min-height: 2px;",
      startWidget: Widget.Box({
        hexpand: true,
        children: [
          Launcher(),
          Workspaces(),
          Widget.Box({ expand: true }),
          Messages(),
        ],
      }),
      centerWidget: Widget.Box({
        hpack: "center",
        children: [Date()],
      }),
      endWidget: Widget.Box({
        hexpand: true,
        children: [
          Media(),
          Widget.Box({ expand: true }),
          SubMenu({
            children: [SysTray(), ColorPicker()],
          }),
          SystemIndicators(),
          BatteryBar(),
          PowerMenu(),
        ],
      }),
    }),
  });
