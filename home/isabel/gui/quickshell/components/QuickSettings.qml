import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell.Io
import Quickshell.Services.Pipewire
import "root:/data"
import "root:/services"

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 12

    Text {
        text: "Quick Settings"
        color: Settings.colors.foreground
        font {
            pixelSize: 14
            weight: Font.Bold
        }
    }

    // Connection Status Row (Ethernet indicator)
    RowLayout {
        Layout.fillWidth: true
        spacing: 8
        visible: Networking.ethernetConnected

        MyIcon {
            icon: "network-wired-symbolic"
            size: 16
        }

        Text {
            text: "Ethernet: " + Networking.ethernetDevice
            color: Settings.colors.foreground
            font.pixelSize: 12
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            width: 8
            height: 8
            radius: 4
            color: Settings.colors.success
        }
    }

    // Network Panel (expandable)
    Rectangle {
        id: networkPanel
        Layout.fillWidth: true
        Layout.preferredHeight: visible ? Math.min(networkColumn.implicitHeight + 20, 350) : 0
        visible: false
        radius: 8
        color: Settings.colors.backgroundLighter
        clip: true

        Behavior on Layout.preferredHeight {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            id: networkColumn
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Networks"
                    color: Settings.colors.foreground
                    font {
                        pixelSize: 13
                        weight: Font.Medium
                    }
                }

                Item { Layout.fillWidth: true }

                IconButton {
                    icon: "view-refresh-symbolic"
                    size: 14
                    onClicked: Networking.reload()
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(networkListView.contentHeight, 280)
                clip: true

                ListView {
                    id: networkListView
                    width: parent.width
                    model: Networking.networks
                    spacing: 4

                    delegate: PanelListItem {
                        required property var modelData
                        width: ListView.view.width
                        icon: modelData.icon
                        text: modelData.ssid || "Unknown"
                        badge: modelData.strength + "%"
                        active: modelData.active
                        onClicked: {
                            if (!modelData.active) {
                                Networking.connectToNetwork(modelData.ssid);
                            }
                        }
                    }
                }
            }

            Text {
                text: Networking.networks?.count === 0 ? "No networks found" : ""
                color: Settings.colors.foreground
                opacity: 0.5
                font.pixelSize: 12
                visible: Networking.networks?.count === 0
                Layout.alignment: Qt.AlignHCenter
            }

            Item { Layout.fillHeight: true }
        }
    }

    // Bluetooth Panel (expandable)
    Rectangle {
        id: bluetoothPanel
        Layout.fillWidth: true
        Layout.preferredHeight: visible ? Math.min(bluetoothColumn.implicitHeight + 20, 350) : 0
        visible: false
        radius: 8
        color: Settings.colors.backgroundLighter
        clip: true

        Behavior on Layout.preferredHeight {
            NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
        }

        ColumnLayout {
            id: bluetoothColumn
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true

                Text {
                    text: "Bluetooth Devices"
                    color: Settings.colors.foreground
                    font {
                        pixelSize: 13
                        weight: Font.Medium
                    }
                }

                Item { Layout.fillWidth: true }

                // Scan button
                IconButton {
                    icon: Bluetooth.adapter?.discovering ? "process-stop-symbolic" : "view-refresh-symbolic"
                    size: 14
                    onClicked: {
                        if (Bluetooth.adapter?.discovering) {
                            Bluetooth.stopDiscovery();
                        } else {
                            Bluetooth.startDiscovery();
                        }
                    }
                }

                Text {
                    text: Bluetooth.connected ? Bluetooth.connectedDevice?.name ?? "" : ""
                    color: Settings.colors.accent
                    font.pixelSize: 11
                    visible: Bluetooth.connected
                }
            }

            ScrollView {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(bluetoothListView.contentHeight, 280)
                clip: true

                ListView {
                    id: bluetoothListView
                    width: parent.width
                    model: Bluetooth.devices
                    spacing: 8
                    clip: true

                    delegate: PanelListItem {
                        required property var modelData
                        width: ListView.view.width
                        icon: modelData.icon || "bluetooth-symbolic"
                        text: modelData.name
                        badge: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "")
                        active: modelData.connected
                        onClicked: {
                            if (modelData.connected) {
                                modelData.disconnect();
                            } else if (modelData.paired) {
                                modelData.connect();
                            } else {
                                // Pair and connect
                                modelData.pair();
                            }
                        }
                    }
                }
            }

            Text {
                text: {
                    if (!Bluetooth.adapter) return "No Bluetooth adapter";
                    if (Bluetooth.devices?.count === 0) return "No devices found";
                    return "";
                }
                color: Settings.colors.foreground
                opacity: 0.5
                font.pixelSize: 12
                visible: !Bluetooth.adapter || Bluetooth.devices?.count === 0
                Layout.alignment: Qt.AlignHCenter
            }

            Item { Layout.fillHeight: true }
        }
    }

    // Toggle Buttons Row
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        // WiFi Toggle
        QuickSettingButton {
            icon: Networking.wifiEnabled 
                ? (Networking.activeWifi?.icon ?? "network-wireless-acquiring-symbolic")
                : "network-wireless-disabled-symbolic"
            label: "WiFi"
            active: Networking.wifiEnabled
            onClicked: Networking.toggleWifi()
            onPressAndHold: networkPanel.visible = !networkPanel.visible
        }

        // Bluetooth Toggle
        QuickSettingButton {
            icon: Bluetooth.icon
            label: "Bluetooth"
            active: Bluetooth.powered
            onClicked: Bluetooth.toggle()
            onPressAndHold: bluetoothPanel.visible = !bluetoothPanel.visible
        }

        // Do Not Disturb Toggle
        QuickSettingButton {
          icon: Notifications.dndEnabled ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"
          label: "DND"
          active: Notifications.dndEnabled
          onClicked: Notifications.dndEnabled = !Notifications.dndEnabled
        }
    }

    // Volume Slider
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    StyledSlider {
        icon: {
            const muted = Pipewire.defaultAudioSink?.audio?.muted ?? false;
            const vol = Pipewire.defaultAudioSink?.audio?.volume ?? 0;
            if (muted) return "audio-volume-muted-symbolic";
            if (vol > 0.66) return "audio-volume-high-symbolic";
            if (vol > 0.33) return "audio-volume-medium-symbolic";
            if (vol > 0) return "audio-volume-low-symbolic";
            return "audio-volume-muted-symbolic";
        }
        value: Pipewire.defaultAudioSink?.audio?.volume ?? 0
        iconClickable: true
        onIconClicked: {
            if (Pipewire.defaultAudioSink?.audio) {
                Pipewire.defaultAudioSink.audio.muted = !Pipewire.defaultAudioSink.audio.muted;
            }
        }
        onMoved: (val) => {
            if (Pipewire.defaultAudioSink?.audio) {
                Pipewire.defaultAudioSink.audio.volume = val;
            }
        }
    }

    // Brightness Slider
    BrightnessHelper { id: brightnessHelper }

    StyledSlider {
        visible: brightnessHelper.available
        icon: "display-brightness-symbolic"
        value: brightnessHelper.brightness
        from: 0.05
        accentColor: Settings.colors.warning
        onMoved: (val) => brightnessHelper.setBrightness(val)
    }

    // Quick Setting Button Component
    component QuickSettingButton: Rectangle {
        id: qsButton
        Layout.fillWidth: true
        Layout.preferredHeight: 64
        radius: 8
        color: active ? Settings.colors.accent : Settings.colors.backgroundLighter

        property string icon: ""
        property string label: ""
        property bool active: false

        signal clicked()
        signal pressAndHold()

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 6

            MyIcon {
                icon: qsButton.icon
                size: 20
                Layout.alignment: Qt.AlignHCenter
                invert: active
            }

            Text {
                text: qsButton.label
                color: qsButton.active ? Settings.colors.background : Settings.colors.foreground
                font.pixelSize: 11
                Layout.alignment: Qt.AlignHCenter
            }
        }

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: qsButton.clicked()
            onPressAndHold: qsButton.pressAndHold()
        }
    }

    // Brightness Helper Component
    component BrightnessHelper: QtObject {
        id: brightnessObj
        property real brightness: 1.0
        property bool available: false

        function setBrightness(value) {
            brightness = value;
            setBrightnessProc.command = ["brightnessctl", "set", Math.round(value * 100) + "%"];
            setBrightnessProc.running = true;
        }

        Component.onCompleted: getBrightness.running = true

        property Process getBrightness: Process {
            id: getBrightness
            command: ["bash", "-c", "brightnessctl -m 2>/dev/null | cut -d, -f4 | tr -d '%'"]
            stdout: SplitParser {
                onRead: {
                    const val = parseInt(data.trim());
                    if (!isNaN(val)) {
                        brightnessObj.brightness = val / 100;
                        brightnessObj.available = true;
                    }
                }
            }
        }

        property Process setBrightnessProc: Process {
            id: setBrightnessProc
        }
      }
}

