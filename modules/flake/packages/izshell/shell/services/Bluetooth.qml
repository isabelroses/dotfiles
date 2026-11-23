pragma Singleton

import Quickshell
import Quickshell.Bluetooth
import QtQuick
import "BluetoothStatus.js" as Status

// The Bluetooth adapter and its devices. What a device or the adapter reads out
// as, and what clicking a device does, are decided here (BluetoothStatus.js);
// views show them.
Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.enabled ?? false
    readonly property int state: adapter?.state ?? BluetoothAdapterState.Disabled
    readonly property bool discoverable: adapter?.discoverable ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    readonly property list<BluetoothDevice> devices: adapter?.devices?.values ?? []
    readonly property BluetoothDevice connectedDevice: devices.find(d => d.connected) ?? null
    readonly property bool connected: connectedDevice !== null
    // for views: rows are added and removed as devices come and go, not rebuilt when one connects
    readonly property ScriptModel deviceModel: ScriptModel { values: [...root.devices] }

    readonly property string icon: {
        if (state === BluetoothAdapterState.Blocked) return "bluetooth-disabled-symbolic";
        if (!powered) return "bluetooth-disabled-symbolic";
        if (connected) return "bluetooth-active-symbolic";
        return "bluetooth-symbolic";
    }

    readonly property var _adapterInfo: ({
        blocked: state === BluetoothAdapterState.Blocked,
        enabling: state === BluetoothAdapterState.Enabling,
        disabling: state === BluetoothAdapterState.Disabling,
        powered: powered,
        connectedName: connectedDevice?.name ?? null,
        connectedBattery: connectedDevice?.batteryAvailable ? connectedDevice.battery : null,
    })

    readonly property string statusText: Status.adapterStatus(_adapterInfo)
    // on or off, or the connected device
    readonly property string tileStatus: Status.tileStatus(_adapterInfo)

    reloadableId: "bluetooth"

    function describe(device: BluetoothDevice): var {
        return {
            paired: device.paired,
            connected: device.connected,
            pairing: device.pairing,
            connecting: device.state === BluetoothDeviceState.Connecting,
            disconnecting: device.state === BluetoothDeviceState.Disconnecting,
            battery: device.batteryAvailable ? device.battery : null,
        };
    }

    // a device's state as a settings page row ("Connected · 80%")
    function deviceDetail(device: BluetoothDevice): string {
        return Status.deviceDetail(describe(device));
    }

    // a device's state as a short badge in the quick settings list
    function deviceBadge(device: BluetoothDevice): string {
        return Status.deviceBadge(describe(device));
    }

    // what clicking a device does: disconnect it, connect it, or pair it
    function activate(device: BluetoothDevice): void {
        const action = Status.primaryAction(describe(device));
        if (action === "disconnect") device.disconnect();
        else if (action === "connect") device.connect();
        else device.pair();
    }

    function setConnected(device: BluetoothDevice, on: bool): void {
        device.connected = on;
    }

    function setDiscoverable(on: bool): void {
        if (adapter) adapter.discoverable = on;
    }

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
