pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // Brightness state
    property real brightness: 1.0
    property bool available: false

    // Icon based on brightness level
    readonly property string icon: {
        if (brightness > 0.66) return "display-brightness-high-symbolic";
        if (brightness > 0.33) return "display-brightness-medium-symbolic";
        return "display-brightness-low-symbolic";
    }

    // Brightness percentage string
    readonly property string brightnessText: Math.round(brightness * 100) + "%"

    function setBrightness(value: real): void {
        const clampedValue = Math.max(0.05, Math.min(1, value));
        brightness = clampedValue;
        setBrightnessProc.command = ["brightnessctl", "set", Math.round(clampedValue * 100) + "%"];
        setBrightnessProc.running = true;
    }

    function increaseBrightness(step = 0.05): void {
        setBrightness(brightness + step);
    }

    function decreaseBrightness(step = 0.05): void {
        setBrightness(brightness - step);
    }

    Component.onCompleted: getBrightnessProc.running = true

    Process {
        id: getBrightnessProc
        command: ["bash", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%'"]
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

    reloadableId: "brightness"
}
