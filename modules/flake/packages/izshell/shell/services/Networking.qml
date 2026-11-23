// Wraps the native Quickshell.Networking singleton. Imported `as Net` because
// this singleton is itself named Networking and the names would collide.
//
// Joining a network is one attempt at a time (`join`, then `submit` if it asks
// for a password, or `cancel`); who is scanning is counted (`acquireScan` and
// `releaseScan`), so two views can't switch each other's scan off.

pragma Singleton

import Quickshell
import Quickshell.Networking as Net
import QtQuick
import "Join.js" as Join

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

    // for views: rows are added and removed as networks come and go, not rebuilt on each scan update
    readonly property ScriptModel networkModel: ScriptModel { values: [...root.networks] }

    // Scanning is expensive: it runs only while someone holds a scan (a view
    // showing the list), and not while the user has paused it.
    property int scanRequests: 0
    property bool scanPaused: false
    readonly property bool scanning: scanRequests > 0 && !scanPaused
    onScanningChanged: if (wifiDevice) wifiDevice.scannerEnabled = scanning
    onWifiDeviceChanged: if (wifiDevice) wifiDevice.scannerEnabled = scanning

    function acquireScan(): void {
        scanRequests++;
    }

    function releaseScan(): void {
        scanRequests = Math.max(0, scanRequests - 1);
        if (scanRequests === 0) scanPaused = false;
    }

    // start the scan over
    function rescan(): void {
        if (!wifiDevice) return;
        wifiDevice.scannerEnabled = false;
        wifiDevice.scannerEnabled = scanning;
    }

    // The attempt to join a network. `joinState` is "idle", "needsPassword",
    // "connecting" or "failed"; `joinError` says why the last try failed.
    property Net.WifiNetwork joinTarget: null
    property var _join: Join.initial()
    readonly property string joinState: _join.state
    readonly property string joinError: _join.error

    function join(network: Net.WifiNetwork): void {
        if (joinState === "connecting") return;
        joinTarget = network;
        advance({ type: "join", needsPassword: needsPassword(network) });
    }

    function submit(password: string): void {
        advance({ type: "submit", password });
    }

    function cancel(): void {
        advance({ type: "cancel" });
    }

    function advance(event: var): void {
        const r = Join.step(_join, event);
        _join = r.state;
        if (r.effect === "connect") joinTarget.connect();
        else if (r.effect === "connectWithPsk") joinTarget.connectWithPsk(event.password);
        if (_join.state === "idle") joinTarget = null;
    }

    // the network dropped out of the scan (its object went away) mid-attempt
    onJoinTargetChanged: if (joinTarget === null && joinState !== "idle") advance({ type: "lost" })

    // NetworkManager normally answers within seconds; never wait for ever
    Timer {
        running: root.joinState === "connecting"
        interval: 30000
        onTriggered: root.advance({ type: root.joinTarget === null ? "lost" : "timeout" })
    }

    Connections {
        target: root.joinTarget
        ignoreUnknownSignals: true
        function onConnectedChanged(): void {
            if (root.joinTarget?.connected) root.advance({ type: "connected" });
        }
        function onConnectionFailed(reason: int): void {
            root.advance({ type: "failed", reason: Net.ConnectionFailReason.toString(reason) });
        }
    }

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
