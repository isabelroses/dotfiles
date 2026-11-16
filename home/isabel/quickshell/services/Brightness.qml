pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    property real brightness: 1.0
    property bool available: false

    readonly property string icon: {
        if (brightness > 0.66) return "display-brightness-high-symbolic";
        if (brightness > 0.33) return "display-brightness-medium-symbolic";
        return "display-brightness-low-symbolic";
    }

    function setBrightness(value: real): void {
        const clampedValue = Math.max(0.05, Math.min(1, value));
        brightness = clampedValue;
        setBrightnessProc.command = ["brightnessctl", "--class=backlight", "set", Math.round(clampedValue * 100) + "%"];
        setBrightnessProc.running = true;
    }

    function adjust(delta: real): void {
        if (available) setBrightness(Math.round((brightness + delta) * 20) / 20);
    }

    Component.onCompleted: getBrightnessProc.running = true

    Process {
        id: getBrightnessProc
        command: ["bash", "-c", "brightnessctl -m --class=backlight 2>/dev/null | cut -d, -f4 | tr -d '%'"]
        stdout: SplitParser {
            onRead: data => {
                const val = parseInt(data.trim());
                if (!isNaN(val)) {
                    root.brightness = val / 100;
                    root.available = true;
                }
            }
        }
    }

    Process {
        id: setBrightnessProc
    }

    IpcHandler {
        target: "brightness"

        function up(): void { root.adjust(0.05); }
        function down(): void { root.adjust(-0.05); }
        function get(): string { return root.available ? `${Math.round(root.brightness * 100)}%` : "unavailable"; }
    }

    reloadableId: "brightness"
}
