import Cairo from "cairo";
import options from "./options.js";
import icons from "./icons.js";
import Theme from "./services/theme/theme.js";
import { Utils, App, Battery, Mpris, Audio } from "./imports.js";

/** @type {function((id: number) => typeof Gtk.Widget): typeof Gtk.Widget[]}*/
export function forMonitors(widget) {
    const ws = JSON.parse(Utils.exec("hyprctl -j monitors"));
    return ws.map((/** @type {Record<string, number>} */ mon) =>
        widget(mon.id),
    );
}

export function range(length, start = 1) {
    return Array.from({ length }, (_, i) => i + start);
}

export function substitute(collection, item) {
    return collection.find(([from]) => from === item)?.[1] || item;
}

export function createSurfaceFromWidget(widget) {
    const alloc = widget.get_allocation();
    const surface = new Cairo.ImageSurface(
        Cairo.Format.ARGB32,
        alloc.width,
        alloc.height,
    );
    const cr = new Cairo.Context(surface);
    cr.setSourceRGBA(255, 255, 255, 0);
    cr.rectangle(0, 0, alloc.width, alloc.height);
    cr.fill();
    widget.draw(cr);

    return surface;
}

export function warnOnLowBattery() {
    const { low } = options.battaryBar;
    Battery.connect("notify::percent", () => {
        if (Battery.percent === low || Battery.percent === low / 2) {
            Utils.execAsync([
                "notify-send",
                `${Battery.percent}% Battery Percentage`,
                "-i",
                icons.battery.warning,
                "-u",
                "critical",
            ]);
        }
    });
}

export function getAudioTypeIcon(icon) {
    const substitues = [
        ["audio-headset-bluetooth", icons.audio.type.headset],
        ["audio-card-analog-usb", icons.audio.type.speaker],
        ["audio-card-analog-pci", icons.audio.type.card],
    ];

    for (const [from, to] of substitues) {
        if (from === icon) return to;
    }

    return icon;
}

export function scssWatcher() {
    return Utils.subprocess(
        [
            "inotifywait",
            "--recursive",
            "--event",
            "create,modify",
            "-m",
            App.configDir + "/scss",
        ],
        () => Theme.setup(),
        () => print("missing dependancy for css hotreload: inotify-tools"),
    );
}

export function activePlayer() {
    let active;
    globalThis.mpris = () => active || Mpris.players[0];
    Mpris.connect("player-added", (mpris, bus) => {
        mpris.getPlayer(bus)?.connect("changed", (player) => {
            active = player;
        });
    });
}

export async function globalServices() {
    globalThis.audio = Audio;
    globalThis.ags = await import("./imports.js");
    globalThis.brightness = (await import("./services/brightness.js")).default;
    globalThis.indicator = (
        await import("./services/onScreenIndicator.js")
    ).default;
    globalThis.theme = (await import("./services/theme/theme.js")).default;
}

export function launchApp(app) {
    Utils.execAsync(`hyprctl dispatch exec ${app.executable}`);
    app.frequency += 1;
}
