import PanelButton from "../panelbutton";
import icons from "lib/icons";

export default () =>
  PanelButton({
    window: "launcher",
    on_clicked: () => App.toggleWindow("launcher"),
    child: Widget.Icon(icons.nix.nix),
  });
