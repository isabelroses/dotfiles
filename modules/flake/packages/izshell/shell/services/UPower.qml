pragma Singleton

import Quickshell
import Quickshell.Services.UPower as QsUPower
import QtQuick

Singleton {
    id: root

    readonly property QsUPower.UPowerDevice displayDevice: QsUPower.UPower.displayDevice

    readonly property bool isPresent: displayDevice?.isPresent ?? false
    readonly property real percentage: displayDevice?.percentage ?? 0
    readonly property bool charging: displayDevice?.state === QsUPower.UPowerDeviceState.Charging

    readonly property string icon: {
        if (!isPresent) return "battery-missing-symbolic";
        const level = percentage >= 90 ? "full"
            : percentage >= 60 ? "good"
            : percentage >= 30 ? "medium"
            : percentage >= 10 ? "low"
            : "empty";
        return `battery-${level}${charging ? "-charging" : ""}-symbolic`;
    }

    reloadableId: "upower"
}
