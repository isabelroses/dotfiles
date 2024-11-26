import { type TrayItem } from "types/service/systemtray";
import PanelButton from "../panelbutton";
import Gdk from "gi://Gdk";
import options from "options";

const systemtray = await Service.import("systemtray");
const { ignore } = options.bar.systray;

const SysTrayItem = (item: TrayItem) =>
  PanelButton({
    class_name: "tray-item",
    child: Widget.Icon({ icon: item.bind("icon") }),
    tooltip_markup: item.bind("tooltip_markup"),
    setup: (self) => {
      const id = item.menu?.connect("popped-up", (menu) => {
        self.toggleClassName("active");
        menu.connect(
          "notify::visible",
          (menu: { visible: boolean | undefined }) => {
            self.toggleClassName("active", menu.visible);
          },
        );
        menu.disconnect(id);
      });
    },

    on_primary_click: (btn) =>
      item.menu?.popup_at_widget(
        btn,
        Gdk.Gravity.SOUTH,
        Gdk.Gravity.NORTH,
        null,
      ),

    on_secondary_click: (btn) =>
      item.menu?.popup_at_widget(
        btn,
        Gdk.Gravity.SOUTH,
        Gdk.Gravity.NORTH,
        null,
      ),
  });

export default () =>
  Widget.Box().bind("children", systemtray, "items", (i) =>
    i.filter(({ id }) => !ignore.value.includes(id)).map(SysTrayItem),
  );
