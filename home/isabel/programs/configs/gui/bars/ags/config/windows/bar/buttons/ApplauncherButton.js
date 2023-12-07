import App from "resource:///com/github/Aylur/ags/app.js";
import PanelButton from "../PanelButton.js";
import FontIcon from "../../../misc/FontIcon.js";
import { distroIcon } from "../../../variables.js";

export default () =>
    PanelButton({
        class_name: "applauncher",
        connections: [
            [
                App,
                (btn, win, visible) => {
                    btn.toggleClassName(
                        "active",
                        win === "applauncher" && visible,
                    );
                },
            ],
        ],
        on_clicked: () => App.toggleWindow("applauncher"),
        content: FontIcon(distroIcon),
    });
