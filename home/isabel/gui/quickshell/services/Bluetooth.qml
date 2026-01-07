pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick

Singleton {
    id: root

    // Adapter state
    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.enabled ?? false
    readonly property int state: adapter?.state ?? BluetoothAdapterState.Disabled

    // Device state
    readonly property var devices: adapter?.devices ?? []
    readonly property BluetoothDevice connectedDevice: {
        if (!adapter) return null;
        for (let i = 0; i < devices.count; i++) {
            const device = devices.values[i];
            if (device.connected) return device;
        }
        return null;
    }
    readonly property bool connected: connectedDevice !== null

    // Icon based on state
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
        if (connected) return connectedDevice.name;
        return "Not Connected";
    }

    reloadableId: "bluetooth"

    function toggle() {
        if (adapter) {
            adapter.enabled = !adapter.enabled;
        }
    }

    function connectDevice(device) {
        device.connect();
    }

    function disconnectDevice(device) {
        device.disconnect();
    }

    function startDiscovery() {
        if (adapter) {
            adapter.discovering = true;
        }
    }

    function stopDiscovery() {
        if (adapter) {
            adapter.discovering = false;
        }
    }
}
