import App from "resource:///com/github/Aylur/ags/app.js";
import { execAsync } from "resource:///com/github/Aylur/ags/utils.js";

/** @param {Array<string>} args */
const keyword = (...args) => execAsync(["hyprctl", "keyword", ...args]);
const noAlphaignore = ["verification", "powermenu"];

export function setupHyprland() {
    try {
        for (const [name] of App.windows) {
            keyword("layerrule", `unset, ${name}`).then(() => {
                keyword("layerrule", `blur, ${name}`);
                if (!noAlphaignore.every((skip) => !name.includes(skip)))
                    return;
                keyword("layerrule", `ignorealpha 0.6, ${name}`);
            });
        }
    } catch (error) {
        console.error(error.message);
    }
}
