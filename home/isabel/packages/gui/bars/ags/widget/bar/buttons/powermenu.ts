import icons from "lib/icons";
import PanelButton from "../panelbutton";

export default () =>
  PanelButton({
    window: "powermenu",
    class_name: "colored box",
    on_clicked: () => App.toggleWindow("powermenu"),
    child: Widget.Icon(icons.powermenu.shutdown),
  });
