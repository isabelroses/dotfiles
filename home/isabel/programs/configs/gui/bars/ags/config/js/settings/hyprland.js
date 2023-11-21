import App from "resource:///com/github/Aylur/ags/app.js";
import Hyprland from "resource:///com/github/Aylur/ags/service/hyprland.js";
import options from "../options.js";
import { readFile, writeFile } from "resource:///com/github/Aylur/ags/utils.js";

const noIgnorealpha = ["verification", "powermenu"];

/** @param {Array<string>} batch */
function sendBatch(batch) {
    const cmd = batch
        .filter((x) => !!x)
        .map((x) => `keyword ${x}`)
        .join("; ");

    Hyprland.sendMessage(`[[BATCH]]/${cmd}`)
        .then(print)
        .catch((err) => console.error(`Hyprland.sendMessage: ${err.message}`));
}

export function hyprlandInit() {
    if (readFile("/tmp/ags/hyprland-init")) return;

    sendBatch(
        Array.from(App.windows).flatMap(([name]) => [
            `layerrule blur, ${name}`,
            noIgnorealpha.some((skip) => name.includes(skip))
                ? ""
                : `layerrule ignorealpha 0.6, ${name}`,
        ]),
    );

    writeFile("init", "/tmp/ags/hyprland-init");
    setupHyprland();
}

export async function setupHyprland() {
    const wm_gaps = options.hypr.wm_gaps.value;
    const bar_style = options.bar.style.value;
    const bar_pos = options.bar.position.value;

    const batch = [];

    JSON.parse(await Hyprland.sendMessage("j/monitors")).forEach(({ name }) => {
        const v = bar_pos === "top" ? `-${wm_gaps},0,0,0` : `0,-${wm_gaps},0,0`;
        if (bar_style !== "normal")
            batch.push(`monitor ${name},addreserved,${v}`);
        else batch.push(`monitor ${name},addreserved,0,0,0,0`);
    });

    sendBatch(batch);
}
