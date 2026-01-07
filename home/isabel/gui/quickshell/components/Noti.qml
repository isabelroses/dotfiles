import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Widgets
import Quickshell.Io
import Quickshell.Services.Notifications
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import "root:/data"
import "root:/services"

Item {
    id: root

    property bool hasNotifications: Notifications.list.length > 0

    // Expose function to toggle popup (for Clock)
    function togglePopup() {
        notificationLoader.item.visible = !notificationLoader.item.visible;
    }

    visible: hasNotifications

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 24
    implicitHeight: 24

    IconButton {
        anchors.centerIn: parent
        icon: "preferences-system-notifications-symbolic"
        size: 18
        onClicked: root.togglePopup()
    }

    LazyLoader {
        id: notificationLoader
        loading: true

        PopupWindow {
            id: popup
            anchor.window: root.QsWindow.window
            anchor.rect.x: parentWindow.width * 1.2
            visible: false
            color: "transparent"

            implicitWidth: 400
            implicitHeight: root.QsWindow.window.height

            Rectangle {
                anchors.fill: parent
                radius: 12
                color: Settings.colors.background

                ColumnLayout {
                    spacing: 12
                    anchors {
                        fill: parent
                        margins: 16
                    }

                    // Header
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Text {
                            text: "Notifications"
                            color: Settings.colors.foreground
                            font {
                                pixelSize: 18
                                weight: Font.Bold
                            }
                        }

                        Item { Layout.fillWidth: true }

                        IconButton {
                            icon: "edit-clear-all-symbolic"
                            size: 16
                            onClicked: {
                                for (const n of Notifications.list) {
                                    n.dismiss();
                                }
                                popup.visible = false;
                            }
                        }
                    }

                    // Notifications List
                    ListView {
                        id: notiList
                        model: Notifications.list
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 8
                        clip: true

                        ScrollBar.vertical: ScrollBar {
                            policy: ScrollBar.AsNeeded
                        }

                        delegate: Rectangle {
                            required property Notification modelData
                            width: ListView.view.width
                            height: 72
                            radius: 8
                            color: Settings.colors.backgroundLighter

                            RowLayout {
                                anchors {
                                    fill: parent
                                    margins: 10
                                }
                                spacing: 10

                                IconImage {
                                    source: Quickshell.iconPath(modelData.appIcon)
                                    implicitSize: 40
                                    Layout.alignment: Qt.AlignVCenter
                                }

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    spacing: 2

                                    Text {
                                        text: modelData.appName
                                        color: Settings.colors.foreground
                                        font {
                                            pixelSize: 13
                                            weight: Font.Medium
                                        }
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }

                                    Text {
                                        text: modelData.body
                                        color: Settings.colors.foreground
                                        opacity: 0.8
                                        font.pixelSize: 12
                                        elide: Text.ElideRight
                                        maximumLineCount: 2
                                        wrapMode: Text.WordWrap
                                        Layout.fillWidth: true
                                    }
                                }

                                IconButton {
                                    icon: "window-close-symbolic"
                                    size: 14
                                    Layout.alignment: Qt.AlignTop
                                    onClicked: {
                                        modelData.dismiss();
                                        if (Notifications.list.length <= 0) {
                                            popup.visible = false;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Separator before Media
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Settings.colors.backgroundLightest
                        visible: Media.players.length > 0
                    }

                    // Media Players Section (Multiple Players)
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 8
                        visible: Media.players.length > 0

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Text {
                                text: "Now Playing"
                                color: Settings.colors.foreground
                                font {
                                    pixelSize: 14
                                    weight: Font.Bold
                                }
                            }

                            Item { Layout.fillWidth: true }

                            // Player selector (if multiple players)
                            Row {
                                spacing: 4
                                visible: Media.players.length > 1

                                Repeater {
                                    model: Media.players

                                    Rectangle {
                                        required property MprisPlayer modelData
                                        required property int index
                                        width: 8
                                        height: 8
                                        radius: 4
                                        color: Media.selectedPlayer === modelData ? Settings.colors.accent : Settings.colors.backgroundLightest

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: Media.selectedPlayer = modelData
                                        }
                                    }
                                }
                            }
                        }

                        // Current Player
                        ListView {
                            id: mediaPlayerList
                            Layout.fillWidth: true
                            Layout.preferredHeight: contentHeight
                            model: Media.players
                            spacing: 8
                            clip: true
                            interactive: false

                            delegate: Rectangle {
                                required property MprisPlayer modelData
                                required property int index
                                width: ListView.view.width
                                height: 90
                                radius: 8
                                color: Settings.colors.backgroundLighter
                                opacity: Media.selectedPlayer === modelData ? 1.0 : 0.6

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: Media.selectedPlayer = modelData
                                }

                                RowLayout {
                                    anchors {
                                        fill: parent
                                        margins: 10
                                    }
                                    spacing: 10

                                    // Album Art
                                    ClippingWrapperRectangle {
                                        radius: 6
                                        Layout.preferredWidth: 70
                                        Layout.preferredHeight: 70

                                        Image {
                                            anchors.fill: parent
                                            source: modelData.trackArtUrl
                                            fillMode: Image.PreserveAspectCrop
                                        }
                                    }

                                    // Track Info & Controls
                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.fillHeight: true
                                        spacing: 2

                                        RowLayout {
                                            Layout.fillWidth: true
                                            spacing: 4

                                            Text {
                                                text: modelData.trackTitle ?? "Unknown"
                                                color: Settings.colors.foreground
                                                font {
                                                    pixelSize: 13
                                                    weight: Font.Medium
                                                }
                                                elide: Text.ElideRight
                                                Layout.fillWidth: true
                                            }

                                            // Player app name badge
                                            Rectangle {
                                                visible: Media.players.length > 1
                                                Layout.preferredHeight: 16
                                                Layout.preferredWidth: appNameText.width + 8
                                                radius: 4
                                                color: Settings.colors.backgroundLightest

                                                Text {
                                                    id: appNameText
                                                    anchors.centerIn: parent
                                                    text: modelData.identity ?? ""
                                                    color: Settings.colors.foreground
                                                    opacity: 0.7
                                                    font.pixelSize: 9
                                                }
                                            }
                                        }

                                        Text {
                                            text: modelData.trackArtist ?? ""
                                            color: Settings.colors.foreground
                                            opacity: 0.7
                                            font.pixelSize: 11
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }

                                        Item { Layout.fillHeight: true }

                                        // Playback Controls
                                        RowLayout {
                                            spacing: 14
                                            Layout.alignment: Qt.AlignLeft

                                            IconButton {
                                                icon: "media-skip-backward-symbolic"
                                                size: 14
                                                onClicked: modelData.previous()
                                            }

                                            IconButton {
                                                icon: modelData.playbackState === MprisPlaybackState.Playing
                                                    ? "media-playback-pause-symbolic"
                                                    : "media-playback-start-symbolic"
                                                size: 18
                                                onClicked: {
                                                    if (modelData.playbackState === MprisPlaybackState.Playing) {
                                                        modelData.pause();
                                                    } else {
                                                        modelData.play();
                                                    }
                                                }
                                            }

                                            IconButton {
                                                icon: "media-skip-forward-symbolic"
                                                size: 14
                                                onClicked: modelData.next()
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Separator
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 1
                        color: Settings.colors.backgroundLightest
                    }

                    // Quick Settings Section
                    ColumnLayout {
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
                                id: dndButton
                                property bool dndEnabled: false
                                icon: dndEnabled ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"
                                label: "DND"
                                active: dndEnabled
                                onClicked: dndEnabled = !dndEnabled
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

                        // Network Panel (expandable)
                        Rectangle {
                            id: networkPanel
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? networkListView.contentHeight + 48 : 0
                            visible: false
                            radius: 8
                            color: Settings.colors.backgroundLighter
                            clip: true

                            Behavior on Layout.preferredHeight {
                                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                            }

                            ColumnLayout {
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

                                ListView {
                                    id: networkListView
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.min(contentHeight, 150)
                                    model: Networking.networks
                                    spacing: 4
                                    clip: true

                                    delegate: PanelListItem {
                                        required property var modelData
                                        icon: modelData.icon
                                        text: modelData.ssid || "Unknown"
                                        badge: modelData.strength + "%"
                                        active: modelData.active
                                    }
                                }
                            }
                        }

                        // Bluetooth Panel (expandable)
                        Rectangle {
                            id: bluetoothPanel
                            Layout.fillWidth: true
                            Layout.preferredHeight: visible ? bluetoothListView.contentHeight + 64 : 0
                            visible: false
                            radius: 8
                            color: Settings.colors.backgroundLighter
                            clip: true

                            Behavior on Layout.preferredHeight {
                                NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
                            }

                            ColumnLayout {
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

                                ListView {
                                    id: bluetoothListView
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: Math.min(contentHeight, 150)
                                    model: Bluetooth.devices
                                    spacing: 4
                                    clip: true

                                    delegate: PanelListItem {
                                        required property var modelData
                                        icon: modelData.icon || "bluetooth-symbolic"
                                        text: modelData.name
                                        badge: modelData.connected ? "Connected" : (modelData.paired ? "Paired" : "")
                                        active: modelData.connected
                                        onClicked: {
                                            if (modelData.connected) {
                                                modelData.disconnect();
                                            } else {
                                                modelData.connect();
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
                            }
                        }
                    }
                }
            }
        }
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
