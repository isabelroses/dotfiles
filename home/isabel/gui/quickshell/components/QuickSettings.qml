import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import "root:/data"
import "root:/services"

ColumnLayout {
  id: root

  Layout.fillWidth: true
  spacing: 12

  Process {
    id: openConfigProc
    command: ["ghostty", "-e", "nvim", "~/.config/flake"]
  }

  Text {
    text: "Quick Settings"
    color: Settings.colors.foreground
    font {
      pixelSize: 14
      weight: Font.Bold
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

    // Netoworking Toggle
    QuickSettingButton {
      icon: Networking.icon
      label: "Networking"
      active: Networking.connected
      onClicked: {
        // Do nothing if ethernet is connected
        if (Networking.ethernetConnected) return;

        // otherwise lets actually do wifi stuff
        Networking.toggleWifi()
      }
      onPressAndHold: {
        if (Networking.ethernetConnected) return;

        networkPanel.visible = !networkPanel.visible
      }
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
  StyledSlider {
    icon: Pipewire.sinkIcon
    value: Pipewire.sinkVolume
    iconClickable: true
    onIconClicked: Pipewire.toggleSinkMute()
    onMoved: (val) => Pipewire.setSinkVolume(val)
  }

  // Brightness Slider
  StyledSlider {
    visible: Brightness.available
    icon: "display-brightness-symbolic"
    value: Brightness.brightness
    from: 0.05
    accentColor: Settings.colors.warning
    onMoved: (val) => Brightness.setBrightness(val)
  }

  // User Profile Section
  Rectangle {
    Layout.fillWidth: true
    Layout.preferredHeight: 72
    radius: 8
    color: Settings.colors.backgroundLighter

    RowLayout {
      anchors {
        fill: parent
        margins: 12
      }
      spacing: 12

      // Profile Picture
      ClippingWrapperRectangle {
        Layout.preferredWidth: 48
        Layout.preferredHeight: 48
        radius: 24
        color: Settings.colors.backgroundLightest

        Image {
          id: profileImage
          anchors.fill: parent
          source: Settings.profilePicture
          mipmap: true

          onStatusChanged: {
            if (status === Image.Error) {
              console.error("Failed to load background image:", source);
            }
          }
        }
      }

      // Username and greeting
      ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Text {
          text: Settings.username
          color: Settings.colors.foreground
          font {
            pixelSize: 14
            weight: Font.Bold
          }
        }

        Text {
          text: {
            const hour = new Date().getHours();
            if (hour < 12) return "Good morning";
            if (hour < 18) return "Good afternoon";
            return "Good evening";
          }
          color: Settings.colors.foreground
          opacity: 0.7
          font.pixelSize: 12
        }
      }


        // Settings button
        IconButton {
          icon: "applications-system-symbolic"
          size: 18
          onClicked: openConfigProc.startDetached()
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
}
