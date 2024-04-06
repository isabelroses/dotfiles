import App from "resource:///com/github/Aylur/ags/app.js";
import Clock from "../../../misc/Clock.js";
import PanelButton from "../PanelButton.js";

export default ({ format = "%I:%M:%S | %d/%m/%y" } = {}) =>
  PanelButton({
    class_name: "dashboard",
    window: "dashboard",
    content: Clock({ format }),
  });
