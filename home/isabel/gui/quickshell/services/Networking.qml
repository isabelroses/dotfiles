// Network service with WiFi and Ethernet support

pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
    id: root

    // WiFi
    readonly property list<AccessPoint> networks: []
    readonly property AccessPoint activeWifi: networks.find(n => n.active) ?? null
    readonly property bool wifiEnabled: internal.wifiEnabled

    // Ethernet
    readonly property bool ethernetConnected: internal.ethernetConnected
    readonly property string ethernetDevice: internal.ethernetDevice

    // Combined state
    readonly property bool connected: ethernetConnected || activeWifi !== null
    readonly property string connectionType: ethernetConnected ? "ethernet" : (activeWifi ? "wifi" : "none")

    readonly property string icon: {
        if (ethernetConnected) return "network-wired-symbolic";
        if (activeWifi) return activeWifi.icon;
        if (!wifiEnabled) return "network-wireless-disabled-symbolic";
        return "network-wireless-offline-symbolic";
    }

    readonly property string statusText: {
        if (ethernetConnected) return ethernetDevice;
        if (activeWifi) return activeWifi.ssid;
        return "Disconnected";
    }

    reloadableId: "network"

    function toggleWifi() {
        toggleWifiProc.running = true;
    }

    function reload() {
        checkStatus.running = true;
    }

    QtObject {
        id: internal
        property bool wifiEnabled: true
        property bool ethernetConnected: false
        property string ethernetDevice: ""
    }

    // Monitor for network changes
    Process {
        running: true
        command: ["nmcli", "m"]
        stdout: SplitParser {
            onRead: checkStatus.running = true
        }
    }

    // Check overall network status
    Process {
        id: checkStatus
        running: true
        command: ["bash", "-c", `
            # Check WiFi status
            wifi_status=$(nmcli radio wifi 2>/dev/null)
            echo "WIFI:$wifi_status"
            
            # Check Ethernet
            eth_info=$(nmcli -t -f TYPE,STATE,DEVICE,CONNECTION device 2>/dev/null | grep '^ethernet:connected' | head -1)
            if [ -n "$eth_info" ]; then
                eth_name=$(echo "$eth_info" | cut -d: -f4)
                echo "ETH:connected:$eth_name"
            else
                echo "ETH:disconnected:"
            fi
        `]
        environment: ({ LANG: "C", LC_ALL: "C" })
        stdout: SplitParser {
            onRead: {
                const line = data.trim();
                if (line.startsWith("WIFI:")) {
                    internal.wifiEnabled = line.includes("enabled");
                } else if (line.startsWith("ETH:")) {
                    const parts = line.split(":");
                    internal.ethernetConnected = parts[1] === "connected";
                    internal.ethernetDevice = parts[2] || "";
                }
            }
        }
        onExited: {
            if (internal.wifiEnabled) {
                getNetworks.running = true;
            }
        }
    }

    Process {
        id: toggleWifiProc
        command: ["nmcli", "radio", "wifi", internal.wifiEnabled ? "off" : "on"]
        onExited: checkStatus.running = true
    }

    Process {
        id: getNetworks
        command: ["nmcli", "-g", "ACTIVE,SIGNAL,FREQ,SSID,BSSID", "d", "w"]
        environment: ({ LANG: "C", LC_ALL: "C" })
        stdout: StdioCollector {
            onStreamFinished: {
                const PLACEHOLDER = "STRINGWHICHHOPEFULLYWONTBEUSED";
                const rep = new RegExp("\\\\:", "g");
                const rep2 = new RegExp(PLACEHOLDER, "g");

                const networks = text.trim().split("\n").filter(l => l.length > 0).map(n => {
                    const net = n.replace(rep, PLACEHOLDER).split(":");
                    return {
                        active: net[0] === "yes",
                        strength: parseInt(net[1]) || 0,
                        frequency: parseInt(net[2]) || 0,
                        ssid: net[3] || "",
                        bssid: net[4]?.replace(rep2, ":") ?? ""
                    };
                }).filter(n => n.ssid !== "");

                const rNetworks = root.networks;

                // Remove networks that no longer exist
                const destroyed = rNetworks.filter(rn => !networks.find(n => 
                    n.frequency === rn.frequency && n.ssid === rn.ssid && n.bssid === rn.bssid
                ));
                for (const network of destroyed) {
                    const idx = rNetworks.indexOf(network);
                    if (idx >= 0) {
                        rNetworks.splice(idx, 1);
                        network.destroy();
                    }
                }

                // Update or add networks
                for (const network of networks) {
                    const match = rNetworks.find(n => 
                        n.frequency === network.frequency && n.ssid === network.ssid && n.bssid === network.bssid
                    );
                    if (match) {
                        match.lastIpcObject = network;
                    } else {
                        rNetworks.push(apComp.createObject(root, { lastIpcObject: network }));
                    }
                }
            }
        }
    }

    component AccessPoint: QtObject {
        required property var lastIpcObject
        readonly property string ssid: lastIpcObject.ssid
        readonly property string bssid: lastIpcObject.bssid
        readonly property int strength: lastIpcObject.strength
        readonly property int frequency: lastIpcObject.frequency
        readonly property bool active: lastIpcObject.active
        readonly property string icon: {
            if (strength >= 75) return "network-wireless-signal-excellent-symbolic";
            if (strength >= 50) return "network-wireless-signal-good-symbolic";
            if (strength >= 25) return "network-wireless-signal-ok-symbolic";
            if (strength > 0) return "network-wireless-signal-weak-symbolic";
            return "network-wireless-signal-none-symbolic";
        }
    }

    Component {
        id: apComp
        AccessPoint {}
    }
}

