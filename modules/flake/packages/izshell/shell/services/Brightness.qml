pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick
import Izshell

// The first backlight in /sys/class/backlight: read from sysfs, set through
// logind's SetBrightness, which lets the session's user do it without udev rules.
Singleton {
    id: root

    readonly property string device: Files.list("/sys/class/backlight")[0] ?? ""
    readonly property string dir: device === "" ? "" : `/sys/class/backlight/${device}`
    readonly property int max: parseInt(maxFile.text()) || 0
    property real brightness: 1.0
    // only once the first read is in, so that read doesn't pop the OSD
    property bool available: false

    readonly property string icon: {
        if (brightness > 0.66) return "display-brightness-high-symbolic";
        if (brightness > 0.33) return "display-brightness-medium-symbolic";
        return "display-brightness-low-symbolic";
    }

    function setBrightness(value: real): void {
        if (!available) return;
        brightness = Math.max(0.05, Math.min(1, value));
        System.setBrightness(device, Math.round(brightness * max));
    }

    function adjust(delta: real): void {
        setBrightness(Math.round((brightness + delta) * 20) / 20);
    }

    FileView { id: maxFile; path: root.dir && `${root.dir}/max_brightness`; blockLoading: true; printErrors: false }

    FileView {
        path: root.max > 0 ? `${root.dir}/brightness` : ""
        printErrors: false
        onLoaded: {
            root.brightness = parseInt(text()) / root.max;
            root.available = true;
        }
    }

    IpcHandler {
        target: "brightness"

        function up(): void { root.adjust(0.05); }
        function down(): void { root.adjust(-0.05); }
        function get(): string { return root.available ? `${Math.round(root.brightness * 100)}%` : "unavailable"; }
    }

    reloadableId: "brightness"
}
