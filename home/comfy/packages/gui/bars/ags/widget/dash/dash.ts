import type Gtk from "gi://Gtk?version=3.0";
import { Header } from "./widgets/header";
import { Volume, Microphone, SinkSelector, AppMixer } from "./widgets/volume";
import { Brightness } from "./widgets/brightness";
import { NetworkToggle, WifiSelection } from "./widgets/network";
import { BluetoothToggle, BluetoothDevices } from "./widgets/bluetooth";
import { DND } from "./widgets/dnd";
import { DarkModeToggle } from "./widgets/darkmode";
import { Notifications } from "./widgets/notifications";
import { MicMute } from "./widgets/micmute";
import { Media } from "./widgets/media";
import PopupWindow from "widget/popupwindow";
import options from "options";

const { bar, dash } = options;
const media = (await Service.import("mpris")).bind("players");
const layout = Utils.derive(
  [bar.position, dash.position],
  (bar, dash) => `${bar}-${dash}` as const,
);

const Row = (
  toggles: Array<() => Gtk.Widget> = [],
  menus: Array<() => Gtk.Widget> = [],
) =>
  Widget.Box({
    vertical: true,
    children: [
      Widget.Box({
        homogeneous: true,
        class_name: "row horizontal",
        children: toggles.map((w) => w()),
      }),
      ...menus.map((w) => w()),
    ],
  });

const Settings = () =>
  Widget.Box({
    vertical: true,
    class_name: "dash vertical",
    css: dash.width.bind().as((w) => `min-width: ${w}px;`),
    children: [
      Header(),
      Widget.Box({
        class_name: "sliders-box vertical",
        vertical: true,
        children: [
          Row([Volume], [SinkSelector, AppMixer]),
          Microphone(),
          Brightness(),
        ],
      }),
      Row([NetworkToggle, BluetoothToggle], [WifiSelection, BluetoothDevices]),
      Row([DarkModeToggle]),
      Row([MicMute, DND]),
      Widget.Box({
        visible: media.as((l) => l.length > 0),
        child: Media(),
      }),
      Notifications(),
    ],
  });

const Dash = () =>
  PopupWindow({
    name: "dash",
    exclusivity: "exclusive",
    transition: bar.position
      .bind()
      .as((pos) => (pos === "top" ? "slide_down" : "slide_up")),
    layout: layout.value,
    child: Settings(),
  });

export function setupDash() {
  App.addWindow(Dash());
  layout.connect("changed", () => {
    App.removeWindow("dash");
    App.addWindow(Dash());
  });
}
