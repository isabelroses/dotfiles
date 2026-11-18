pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.enabled ?? false
    readonly property int state: adapter?.state ?? BluetoothAdapterState.Disabled

    readonly property list<BluetoothDevice> devices: adapter?.devices?.values ?? []
    readonly property BluetoothDevice connectedDevice: devices.find(d => d.connected) ?? null
    readonly property bool connected: connectedDevice !== null

    readonly property string icon: {
        if (state === BluetoothAdapterState.Blocked) return "bluetooth-disabled-symbolic";
        if (!powered) return "bluetooth-disabled-symbolic";
        if (connected) return "bluetooth-active-symbolic";
        return "bluetooth-symbolic";
    }

    readonly property string statusText: {
        if (state === BluetoothAdapterState.Blocked) return "Blocked";
        if (state === BluetoothAdapterState.Enabling) return "Enabling...";
        if (state === BluetoothAdapterState.Disabling) return "Disabling...";
        if (!powered) return "Bluetooth Off";
        if (connected) return connectedDevice.name + (connectedDevice.batteryAvailable ? ` · ${Math.round(connectedDevice.battery * 100)}%` : "");
        return "Not Connected";
    }

    reloadableId: "bluetooth"

    function toggle(): void {
        if (adapter) {
            adapter.enabled = !adapter.enabled;
        }
    }

    function startDiscovery(): void {
        if (adapter) {
            adapter.discovering = true;
        }
    }

    function stopDiscovery(): void {
        if (adapter) {
            adapter.discovering = false;
        }
    }
}
