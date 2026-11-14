// Wraps the native Quickshell.Networking singleton. Imported `as Net` because
// this singleton is itself named Networking and the names would collide.

pragma Singleton

import Quickshell
import Quickshell.Networking as Net
import QtQuick

Singleton {
    id: root

    readonly property Net.WifiDevice wifiDevice: Net.Networking.devices.values.find(d => d.type === Net.DeviceType.Wifi) ?? null
    readonly property Net.WiredDevice wiredDevice: Net.Networking.devices.values.find(d => d.type === Net.DeviceType.Wired) ?? null

    readonly property bool wifiEnabled: Net.Networking.wifiEnabled
    readonly property list<Net.WifiNetwork> networks: wifiDevice?.networks?.values ?? []
    readonly property Net.WifiNetwork activeWifi: networks.find(n => n.connected) ?? null

    readonly property bool ethernetConnected: wiredDevice?.connected ?? false
    readonly property string ethernetDevice: wiredDevice?.name ?? ""

    readonly property bool connected: ethernetConnected || activeWifi !== null
    // Scanning is expensive; the UI sets this true only while showing the list.
    property bool scanning: false
    onScanningChanged: if (wifiDevice) wifiDevice.scannerEnabled = scanning
    onWifiDeviceChanged: if (wifiDevice) wifiDevice.scannerEnabled = scanning

    function networkIcon(network): string {
        const s = network?.signalStrength ?? 0;
        if (s >= 0.75) return "network-wireless-signal-excellent-symbolic";
        if (s >= 0.5) return "network-wireless-signal-good-symbolic";
        if (s >= 0.25) return "network-wireless-signal-ok-symbolic";
        if (s > 0) return "network-wireless-signal-weak-symbolic";
        return "network-wireless-signal-none-symbolic";
    }

    readonly property string icon: {
        if (ethernetConnected) return "network-wired-symbolic";
        if (activeWifi) return networkIcon(activeWifi);
        if (!wifiEnabled) return "network-wireless-disabled-symbolic";
        return "network-wireless-offline-symbolic";
    }

    readonly property string statusText: {
        if (ethernetConnected) return ethernetDevice;
        if (activeWifi) return activeWifi.name;
        if (!wifiEnabled) return "WiFi Off";
        return "Disconnected";
    }

    function toggleWifi(): void {
        Net.Networking.wifiEnabled = !Net.Networking.wifiEnabled;
    }

    // Open and OWE (enhanced open) networks join without a password.
    function needsPassword(network): bool {
        if (!network || network.known) return false;
        const s = network.security;
        return s !== Net.WifiSecurityType.Open && s !== Net.WifiSecurityType.Owe;
    }

    reloadableId: "network"
}
