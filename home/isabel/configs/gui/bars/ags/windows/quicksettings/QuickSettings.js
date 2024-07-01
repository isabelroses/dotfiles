import Widget from "resource:///com/github/Aylur/ags/widget.js";
import { AppMixer, Microhone, SinkSelector, Volume } from "./widgets/Volume.js";
import { NetworkToggle, WifiSelection } from "./widgets/Network.js";
import { BluetoothDevices, BluetoothToggle } from "./widgets/Bluetooth.js";
import { ThemeSelector, ThemeToggle } from "./widgets/Theme.js";
import Header from "./widgets/Header.js";
import Media from "./widgets/Media.js";
import Brightness from "./widgets/Brightness.js";
import DND from "./widgets/DND.js";
import MicMute from "./widgets/MicMute.js";
import NotificationColumn from "./widgets/NotificationColumn.js";
import options from "../../options.js";
import PopupWindow from "../../misc/PopupWindow.js";

const Row = (toggles = [], menus = []) =>
  Widget.Box({
    vertical: true,
    children: [
      Widget.Box({
        class_name: "row horizontal",
        children: toggles,
      }),
      ...menus,
    ],
  });

const Homogeneous = (toggles) =>
  Widget.Box({
    homogeneous: true,
    children: toggles,
  });

export default () =>
  PopupWindow({
    name: "quicksettings",
    setup: (self) =>
      self.hook(options.bar.position, () => {
        self.anchor = ["right", options.bar.position.value];
        if (options.bar.position.value === "top")
          self.transition = "slide_down";

        if (options.bar.position.value === "bottom")
          self.transition = "slide_up";
      }),
    child: Widget.Box({
      vertical: true,
      children: [
        Header(),
        Widget.Box({
          class_name: "sliders-box vertical",
          class_name: "slider-box",
          vertical: true,
          children: [
            Row([Volume()], [SinkSelector(), AppMixer()]),
            Microhone(),
            Brightness(),
          ],
        }),
        Row(
          [Homogeneous([NetworkToggle(), BluetoothToggle()]), DND()],
          [WifiSelection(), BluetoothDevices()],
        ),
        Row([Homogeneous([ThemeToggle()]), MicMute()], [ThemeSelector()]),
        Media(),
      ],
    }),
  });
