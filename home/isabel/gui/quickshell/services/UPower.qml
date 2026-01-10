pragma Singleton

import Quickshell
import Quickshell.Services.UPower as QsUPower
import QtQuick

Singleton {
    id: root

    // Display device represents the overall system battery
    readonly property QsUPower.UPowerDevice displayDevice: QsUPower.UPower.displayDevice

    // Battery state
    readonly property bool isPresent: displayDevice?.isPresent ?? false
    readonly property real percentage: displayDevice?.percentage ?? 0
    readonly property int state: displayDevice?.state ?? QsUPower.UPowerDeviceState.Unknown
    readonly property bool charging: state === QsUPower.UPowerDeviceState.Charging
    readonly property bool discharging: state === QsUPower.UPowerDeviceState.Discharging
    readonly property bool fullyCharged: state === QsUPower.UPowerDeviceState.FullyCharged

    // Time estimates (in seconds)
    readonly property real timeToEmpty: displayDevice?.timeToEmpty ?? 0
    readonly property real timeToFull: displayDevice?.timeToFull ?? 0

    // Energy info
    readonly property real energy: displayDevice?.energy ?? 0
    readonly property real energyFull: displayDevice?.energyFull ?? 0
    readonly property real energyRate: displayDevice?.energyRate ?? 0

    // Icon based on percentage and charging state
    readonly property string icon: {
        if (!isPresent) return "battery-missing-symbolic";

        const level = percentage;
        let iconName = "battery";

        if (level >= 90) iconName = "battery-full";
        else if (level >= 60) iconName = "battery-good";
        else if (level >= 30) iconName = "battery-medium";
        else if (level >= 10) iconName = "battery-low";
        else iconName = "battery-empty";

        if (charging) iconName += "-charging";

        return iconName + "-symbolic";
    }

    // Status text
    readonly property string statusText: {
        if (!isPresent) return "No Battery";
        if (fullyCharged) return "Fully Charged";
        if (charging) {
            const time = formatTime(timeToFull);
            return time ? `Charging (${time})` : "Charging";
        }
        if (discharging) {
            const time = formatTime(timeToEmpty);
            return time ? `${time} remaining` : "Discharging";
        }
        return `${Math.round(percentage)}%`;
    }

    // Format time in seconds to human-readable string
    function formatTime(seconds: real): string {
        if (seconds <= 0) return "";
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        if (hours > 0) {
            return `${hours}h ${minutes}m`;
        }
        return `${minutes}m`;
    }

    // All power devices (for detailed view)
    readonly property var devices: QsUPower.UPower.devices

    reloadableId: "upower"
}

