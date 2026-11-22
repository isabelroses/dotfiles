import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth as QsBluetooth
import qs.data
import qs.services

// Settings page for Bluetooth: the adapter's switches, paired devices to
// connect or forget, and a scan for new ones to pair. Scanning runs while the
// page is open.
ColumnLayout {
  id: root

  spacing: 10

  readonly property QsBluetooth.BluetoothAdapter adapter: Bluetooth.adapter
  readonly property list<QsBluetooth.BluetoothDevice> paired: Bluetooth.devices
    .filter(d => d.paired)
    .sort((a, b) => b.connected - a.connected || a.name.localeCompare(b.name))
  readonly property list<QsBluetooth.BluetoothDevice> nearby: Bluetooth.devices
    .filter(d => !d.paired && d.deviceName !== "")

  Component.onCompleted: if (Bluetooth.powered) Bluetooth.startDiscovery()
  Component.onDestruction: Bluetooth.stopDiscovery()

  StyledText {
    visible: root.adapter === null
    Layout.alignment: Qt.AlignHCenter
    Layout.topMargin: 40
    text: "No Bluetooth adapter"
    color: Settings.colors.textMuted
  }

  RowGroup {
    visible: root.adapter !== null

    SwitchRow {
      label: "Bluetooth"
      hint: root.adapter?.name ?? ""
      on: Bluetooth.powered
      onToggled: Bluetooth.toggle()
    }

    SwitchRow {
      divided: true
      enabled: Bluetooth.powered
      label: "Visible to other devices"
      hint: "So a phone or another computer can find this one to pair."
      on: root.adapter?.discoverable ?? false
      onToggled: root.adapter.discoverable = !root.adapter.discoverable
    }
  }

  SectionLabel { visible: root.adapter !== null; text: "My devices"; size: 16; Layout.topMargin: 10 }

  StyledText {
    visible: root.adapter !== null && root.paired.length === 0
    Layout.leftMargin: 2
    text: "Nothing paired yet"
    color: Settings.colors.textMuted
    font.pixelSize: 12
  }

  RowGroup {
    visible: root.paired.length > 0

    Repeater {
      model: root.paired

      DeviceRow {
        required property int index
        divided: index > 0
        detail: modelData.pairing ? "Pairing…"
          : modelData.state === QsBluetooth.BluetoothDeviceState.Connecting ? "Connecting…"
          : modelData.state === QsBluetooth.BluetoothDeviceState.Disconnecting ? "Disconnecting…"
          : modelData.connected ? "Connected" + (modelData.batteryAvailable ? ` · ${Math.round(modelData.battery * 100)}%` : "")
          : "Not connected"
        active: modelData.connected

        BoxButton {
          implicitHeight: 28
          fontSize: 11
          text: modelData.connected ? "Disconnect" : "Connect"
          enabled: Bluetooth.powered && modelData.state !== QsBluetooth.BluetoothDeviceState.Connecting
          onClicked: modelData.connected = !modelData.connected
        }

        BoxButton {
          implicitHeight: 28
          fontSize: 11
          text: "Forget"
          onClicked: modelData.forget()
        }
      }
    }
  }

  RowLayout {
    visible: root.adapter !== null
    Layout.fillWidth: true
    Layout.topMargin: 10
    spacing: 10

    SectionLabel { text: "Nearby"; size: 16 }

    Caption {
      Layout.fillWidth: true
      text: !Bluetooth.powered ? "Bluetooth is off"
        : root.adapter?.discovering ? (root.nearby.length === 0 ? "Searching…" : "Scanning")
        : `${root.nearby.length} found`
    }

    BoxButton {
      visible: Bluetooth.powered
      implicitHeight: 26
      fontSize: 11
      text: root.adapter?.discovering ? "Stop" : "Scan"
      onClicked: root.adapter.discovering ? Bluetooth.stopDiscovery() : Bluetooth.startDiscovery()
    }
  }

  RowGroup {
    visible: Bluetooth.powered && root.nearby.length > 0

    Repeater {
      model: root.nearby

      DeviceRow {
        required property int index
        divided: index > 0
        detail: modelData.pairing ? "Pairing…" : modelData.address

        BoxButton {
          implicitHeight: 28
          fontSize: 11
          text: modelData.pairing ? "Cancel" : "Pair"
          onClicked: modelData.pairing ? modelData.cancelPair() : modelData.pair()
        }
      }
    }
  }

  component SwitchRow: Item {
    id: sw
    property string label: ""
    property string hint: ""
    property bool on: false
    property bool divided: false
    signal toggled()

    Layout.fillWidth: true
    implicitHeight: swText.implicitHeight + 24
    opacity: enabled ? 1 : 0.5

    Hairline { visible: sw.divided; inset: 14 }

    RowLayout {
      anchors { fill: parent; leftMargin: 14; rightMargin: 12 }
      spacing: 12

      ColumnLayout {
        id: swText
        Layout.fillWidth: true
        spacing: 2

        StyledText { text: sw.label; font.pixelSize: 13 }

        Caption { Layout.fillWidth: true; visible: text !== ""; text: sw.hint }
      }

      ToggleSwitch { on: sw.on; onToggled: if (sw.enabled) sw.toggled() }
    }
  }

  // a device with its icon, name and state; buttons go on the right
  component DeviceRow: Item {
    id: dev
    required property QsBluetooth.BluetoothDevice modelData
    property string detail: ""
    property bool active: false
    property bool divided: false
    default property alias actions: buttons.data

    Layout.fillWidth: true
    implicitHeight: 56

    Hairline { visible: dev.divided; inset: 14 }

    RowLayout {
      anchors { fill: parent; leftMargin: 14; rightMargin: 12 }
      spacing: 12

      MyIcon {
        icon: dev.modelData.icon || "bluetooth-symbolic"
        size: 16
        color: dev.active ? Settings.colors.accent : Settings.colors.textMuted
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        StyledText {
          Layout.fillWidth: true
          text: dev.modelData.name || dev.modelData.address
          font.pixelSize: 13
        }

        StyledText {
          Layout.fillWidth: true
          text: dev.detail
          font.pixelSize: 11
          color: dev.active ? Settings.colors.accent : Settings.colors.textMuted
        }
      }

      RowLayout {
        id: buttons
        spacing: 6
      }
    }
  }
}
