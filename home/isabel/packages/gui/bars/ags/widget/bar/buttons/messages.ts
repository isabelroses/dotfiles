import icons from "lib/icons";
import PanelButton from "../panelbutton";

const n = await Service.import("notifications");
const notifs = n.bind("notifications");

export default () =>
  PanelButton({
    class_name: "messages",
    on_clicked: () => App.toggleWindow("dash"),
    visible: notifs.as((n) => n.length > 0),
    child: Widget.Box([Widget.Icon(icons.notifications.message)]),
  });
