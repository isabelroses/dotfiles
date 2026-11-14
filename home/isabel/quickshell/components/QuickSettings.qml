import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Bluetooth as QsBluetooth
import Quickshell.Networking as Net
import Quickshell.Services.Pipewire as Pw
import qs.data
import qs.services

ColumnLayout {
  id: root

  Layout.fillWidth: true
  spacing: 10

  property string openPanel: ""

  function togglePanel(name: string): void {
    openPanel = openPanel === name ? "" : name;
  }

  Binding {
    target: Networking
    property: "scanning"
    value: root.openPanel === "network"
  }

  GridLayout {
    Layout.fillWidth: true
    columns: 2
    rowSpacing: 8
    columnSpacing: 8

    ToggleTile {
      tint: Settings.colors.sky
      icon: Networking.icon
      label: Networking.ethernetConnected ? "Ethernet" : "Wi-Fi"
      status: Networking.statusText
      active: Networking.connected || Networking.wifiEnabled
      expandable: true
      expanded: root.openPanel === "network"
      onToggled: if (!Networking.ethernetConnected) Networking.toggleWifi()
      onExpandRequested: root.togglePanel("network")
    }

    ToggleTile {
      tint: Settings.colors.blue
      icon: Bluetooth.icon
      label: "Bluetooth"
      status: Bluetooth.statusText
      active: Bluetooth.powered
      expandable: true
      expanded: root.openPanel === "bluetooth"
      onToggled: Bluetooth.toggle()
      onExpandRequested: root.togglePanel("bluetooth")
    }

    ToggleTile {
      tint: Settings.colors.peach
      icon: Notifications.dndEnabled ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"
      label: "Do not disturb"
      status: Notifications.dndEnabled ? "On" : "Off"
      active: Notifications.dndEnabled
      onToggled: Notifications.setDnd(!Notifications.dndEnabled)
    }

    ToggleTile {
      tint: Settings.colors.green
      icon: Pipewire.sourceIcon
      label: "Microphone"
      status: Pipewire.sourceMuted ? "Muted" : Pipewire.sourceVolumeText
      active: !Pipewire.sourceMuted
      onToggled: Pipewire.toggleSourceMute()
    }
  }

  DetailPanel {
    open: root.openPanel === "network"
    title: "Networks"
    tint: Settings.colors.sky
    actionIcon: "view-refresh-symbolic"

    onActionClicked: {
      Networking.scanning = false;
      Networking.scanning = true;
    }
    emptyText: !Networking.wifiEnabled ? "Wi-Fi is off"
      : Networking.networks.length === 0 ? "Searching…" : ""
    model: Networking.networks

    delegate: PanelListItem {
      tint: Settings.colors.sky
      required property Net.WifiNetwork modelData
      width: ListView.view.width
      icon: Networking.networkIcon(modelData)
      text: modelData.name || "Hidden network"
      badge: modelData.connected ? "connected"
        : modelData.known ? "saved"
        : Math.round(modelData.signalStrength * 100) + "%"
      active: modelData.connected
      onClicked: {
        if (modelData.connected) return;
        if (Networking.needsPassword(modelData)) {
          Runtime.openWifiPassword(modelData);
        } else {
          modelData.connect();
        }
      }
    }
  }

  DetailPanel {
    open: root.openPanel === "bluetooth"
    title: "Devices"
    tint: Settings.colors.blue
    actionIcon: Bluetooth.adapter?.discovering ? "process-stop-symbolic" : "view-refresh-symbolic"
    onActionClicked: {
      if (Bluetooth.adapter?.discovering) Bluetooth.stopDiscovery();
      else Bluetooth.startDiscovery();
    }
    emptyText: !Bluetooth.adapter ? "No Bluetooth adapter"
      : !Bluetooth.powered ? "Bluetooth is off"
      : Bluetooth.devices.length === 0 ? "No devices found" : ""
    model: Bluetooth.devices

    delegate: PanelListItem {
      tint: Settings.colors.blue
      required property QsBluetooth.BluetoothDevice modelData
      width: ListView.view.width
      icon: modelData.icon || "bluetooth-symbolic"
      text: modelData.name
      badge: (modelData.batteryAvailable ? Math.round(modelData.battery * 100) + "% · " : "")
        + (modelData.connected ? "connected" : (modelData.paired ? "paired" : ""))
      active: modelData.connected
      onClicked: {
        if (modelData.connected) modelData.disconnect();
        else if (modelData.paired) modelData.connect();
        else modelData.pair();
      }
    }
  }

  RowLayout {
    Layout.fillWidth: true
    Layout.topMargin: 2
    spacing: 6

    StyledSlider {
      icon: Pipewire.sinkIcon
      value: Pipewire.sinkVolume
      dimmed: Pipewire.sinkMuted
      iconClickable: true
      onIconClicked: Pipewire.toggleSinkMute()
      onMoved: Pipewire.setSinkVolume(value)
    }

    Clickable {
      onClicked: root.togglePanel("audio")
      readonly property bool expanded: root.openPanel === "audio"
      implicitWidth: 40
      implicitHeight: 40
      radius: Settings.radiusSm
      color: hovered ? Settings.colors.overlay : Settings.colors.surfaceRaised
      border.width: 1
      border.color: expanded ? Settings.colors.borderStrong : Settings.colors.border

      MyIcon {
        anchors.centerIn: parent
        icon: "go-next-symbolic"
        size: 12
        color: Settings.colors.textMuted
        rotation: parent.expanded ? 90 : 0
        Behavior on rotation { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic } }
      }
    }
  }

  DetailPanel {
    open: root.openPanel === "audio"
    title: "Output"
    tint: Settings.colors.pink
    emptyText: Pipewire.sinks.length === 0 ? "No outputs" : ""
    model: Pipewire.sinks

    delegate: PanelListItem {
      tint: Settings.colors.pink
      required property Pw.PwNode modelData
      width: ListView.view.width
      icon: Pipewire.nodeIcon(modelData)
      text: Pipewire.nodeName(modelData)
      active: modelData === Pipewire.sink
      badge: active ? "default" : ""
      onClicked: if (!active) Pipewire.setDefaultSink(modelData)
    }
  }

  DetailPanel {
    open: root.openPanel === "audio"
    title: "Apps"
    tint: Settings.colors.pink
    emptyText: Pipewire.streams.length === 0 ? "Nothing is playing" : ""
    model: Pipewire.streams

    delegate: AppVolumeRow {
      required property Pw.PwNode modelData
      width: ListView.view.width
      node: modelData
    }
  }

  StyledSlider {
    visible: Brightness.available
    icon: Brightness.icon
    value: Brightness.brightness
    from: 0.05
    accentColor: Settings.colors.yellow
    onMoved: Brightness.setBrightness(value)
  }

  component ToggleTile: Clickable {
    id: tile

    property string icon: ""
    property string label: ""
    property string status: ""
    property bool active: false
    property color tint: Settings.colors.accent
    property bool expandable: false
    property bool expanded: false

    signal toggled()
    signal expandRequested()

    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: (mouse) => {
      if (mouse.button !== Qt.RightButton) tile.toggled();
      else if (tile.expandable) tile.expandRequested();
    }

    Layout.fillWidth: true
    Layout.preferredWidth: 1
    implicitHeight: 58
    radius: Settings.radiusMd
    color: active ? tile.tint
         : hovered ? Settings.colors.surfaceRaised
         : Settings.colors.surface
    border.color: active ? tile.tint : (expanded ? Settings.colors.borderStrong : Settings.colors.border)
    border.width: 1

    Behavior on color { ColorAnimation { duration: Settings.animNormal } }

    RowLayout {
      anchors { fill: parent; leftMargin: 12; rightMargin: tile.expandable ? 4 : 12 }
      spacing: 10

      IconChip {
        radius: Settings.radiusRound
        color: tile.active ? Qt.rgba(0, 0, 0, 0.12) : Settings.colors.overlay
        size: 32
        icon: tile.icon
        iconSize: 16
        iconColor: tile.active ? Settings.colors.textOnAccent : Settings.colors.text
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 1

        StyledText {
          Layout.fillWidth: true
          text: tile.label
          font.weight: Font.DemiBold
          font.pixelSize: 12
          color: tile.active ? Settings.colors.textOnAccent : Settings.colors.text
          elide: Text.ElideRight
        }

        StyledText {
          Layout.fillWidth: true
          text: tile.status
          font.pixelSize: 11
          font.weight: tile.active ? Font.Medium : Font.Normal
          color: tile.active ? Utils.withAlpha(Settings.colors.textOnAccent, 0.85)
                             : Settings.colors.textMuted
          elide: Text.ElideRight
        }
      }

      IconButton {
        visible: tile.expandable
        icon: "go-next-symbolic"
        size: 12
        padding: 8
        color: tile.active ? Settings.colors.textOnAccent : Settings.colors.textMuted
        hoverColor: tile.active ? Qt.rgba(0, 0, 0, 0.12) : Settings.colors.overlay
        rotation: tile.expanded ? 90 : 0
        onClicked: tile.expandRequested()

        Behavior on rotation { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic } }
      }
    }
  }

  component DetailPanel: Rectangle {
    id: panel

    property bool open: false
    property string title: ""
    property string actionIcon: ""
    property string emptyText: ""
    property color tint: Settings.colors.accent
    property alias model: list.model
    property alias delegate: list.delegate

    signal actionClicked()

    Layout.fillWidth: true
    Layout.preferredHeight: open ? Math.min(panelColumn.implicitHeight + 16, 320) : 0
    visible: Layout.preferredHeight > 0
    radius: Settings.radiusMd
    color: Settings.colors.surface
    border.color: Settings.colors.border
    border.width: 1
    clip: true

    Behavior on Layout.preferredHeight {
      NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
      id: panelColumn
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 8 }
      spacing: 4

      RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 6

        SectionLabel { text: panel.title; tint: panel.tint }

        Item { Layout.fillWidth: true }

        IconButton {
          visible: panel.actionIcon !== ""
          icon: panel.actionIcon
          size: 14
          color: Settings.colors.textMuted
          onClicked: panel.actionClicked()
        }
      }

      ListView {
        id: list
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, 250)
        spacing: 2
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
      }

      StyledText {
        visible: panel.emptyText !== ""
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 6
        Layout.bottomMargin: 10
        text: panel.emptyText
        color: Settings.colors.textSubtle
        font.pixelSize: 12
      }
    }
  }
}
