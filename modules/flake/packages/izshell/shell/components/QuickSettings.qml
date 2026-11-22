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

  // which detail card is stacked on the sheet; lives in Runtime so ipc can open one
  readonly property string openPanel: Runtime.quickPanel
  // whether a card is really showing: the wi-fi list stays shut on ethernet
  readonly property bool cardOpen: openPanel !== "" && !(openPanel === "network" && Networking.ethernetConnected)
  // where detail cards stack; set by the sheet so they can cover all of it
  property Item stackHost: null

  function togglePanel(name: string): void {
    Runtime.quickPanel = openPanel === name ? "" : name;
  }

  Binding {
    target: Networking
    property: "scanning"
    value: root.openPanel === "network" && !Networking.ethernetConnected
  }

  GridLayout {
    Layout.fillWidth: true
    columns: 2
    rowSpacing: 8
    columnSpacing: 8

    ToggleTile {
      icon: Networking.icon
      label: Networking.ethernetConnected ? "Ethernet" : "Wi-Fi"
      status: Networking.statusText
      active: Networking.connected || Networking.wifiEnabled
      expandable: !Networking.ethernetConnected
      expanded: root.openPanel === "network" && expandable
      onToggled: if (!Networking.ethernetConnected) Networking.toggleWifi()
      onExpandRequested: root.togglePanel("network")
    }

    ToggleTile {
      icon: Bluetooth.icon
      label: "Bluetooth"
      status: Bluetooth.powered ? (Bluetooth.statusText === "Not Connected" ? "On" : Bluetooth.statusText) : "Off"
      active: Bluetooth.powered
      expandable: true
      expanded: root.openPanel === "bluetooth"
      onToggled: Bluetooth.toggle()
      onExpandRequested: root.togglePanel("bluetooth")
    }

    ToggleTile {
      icon: Notifications.dndEnabled ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"
      label: "Do not disturb"
      status: Notifications.dndEnabled ? "On" : "Off"
      active: Notifications.dndEnabled
      onToggled: Notifications.setDnd(!Notifications.dndEnabled)
    }

    ToggleTile {
      icon: "view-reveal-symbolic"
      label: "Keep awake"
      status: Runtime.keepAwake ? "On" : "Off"
      active: Runtime.keepAwake
      onToggled: Runtime.keepAwake = !Runtime.keepAwake
    }
  }

  DetailPanel {
    open: root.openPanel === "network" && !Networking.ethernetConnected
    title: "Networks"
    actionIcon: "view-refresh-symbolic"

    onActionClicked: {
      Networking.scanning = false;
      Networking.scanning = true;
    }
    emptyText: !Networking.wifiEnabled ? "Wi-Fi is off"
      : Networking.networks.length === 0 ? "Searching…" : ""
    model: Networking.networks

    delegate: PanelListItem {
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

  RowGroup {
    id: levels

    LevelRow {
      icon: Pipewire.sinkIcon
      title: Pipewire.sink ? Pipewire.nodeName(Pipewire.sink) : "No output"
      value: Pipewire.sinkVolume
      muted: Pipewire.sinkMuted
      panel: "output"
      onIconClicked: Pipewire.toggleSinkMute()
      onMoved: (v) => Pipewire.setSinkVolume(v)
    }

    LevelRow {
      divided: true
      icon: Pipewire.sourceIcon
      title: Pipewire.source ? Pipewire.nodeName(Pipewire.source) : "No input"
      value: Pipewire.sourceVolume
      muted: Pipewire.sourceMuted
      panel: "input"
      onIconClicked: Pipewire.toggleSourceMute()
      onMoved: (v) => Pipewire.setSourceVolume(v)
    }

    LevelRow {
      divided: true
      visible: Brightness.available
      icon: Brightness.icon
      title: "Brightness"
      value: Brightness.brightness
      from: 0.05
      onMoved: (v) => Brightness.setBrightness(v)
    }

    Clickable {
      Layout.fillWidth: true
      implicitHeight: 40
      radius: levels.rowRadius
      color: hovered ? Settings.colors.surfaceRaised : "transparent"
      onClicked: root.togglePanel("audio")

      Hairline {}

      RowLayout {
        anchors { fill: parent; leftMargin: 18; rightMargin: 14 }
        spacing: 12

        MyIcon { icon: "view-app-grid-symbolic"; size: 14; color: Settings.colors.textMuted }

        StyledText { Layout.fillWidth: true; text: "Apps"; font.pixelSize: 12 }

        Caption {
          Layout.maximumWidth: 170
          text: Pipewire.streams.length === 0 ? "Nothing playing"
            : Pipewire.streams.length === 1 ? Pipewire.streamName(Pipewire.streams[0])
            : `${Pipewire.streams.length} playing`
        }

        MyIcon { icon: "go-next-symbolic"; size: 10; color: Settings.colors.textMuted }
      }
    }
  }

  DetailPanel {
    open: root.openPanel === "output"
    title: "Output"
    emptyText: Pipewire.sinks.length === 0 ? "No outputs" : ""
    model: Pipewire.sinks

    delegate: PanelListItem {
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
    emptyText: Pipewire.streams.length === 0 ? "Nothing is playing" : ""
    model: Pipewire.streams

    delegate: AppVolumeRow {
      required property Pw.PwNode modelData
      width: ListView.view.width
      node: modelData
    }
  }


  DetailPanel {
    open: root.openPanel === "input"
    title: "Input"
    emptyText: Pipewire.sources.length === 0 ? "No inputs" : ""
    model: Pipewire.sources

    delegate: PanelListItem {
      required property Pw.PwNode modelData
      width: ListView.view.width
      icon: Pipewire.inputIcon(modelData)
      text: Pipewire.nodeName(modelData)
      active: modelData === Pipewire.source
      badge: active ? "default" : ""
      onClicked: if (!active) Pipewire.setDefaultSource(modelData)
    }
  }

  // right-click opens an expandable tile's list too
  component ToggleTile: Clickable {
    id: tile

    property string icon: ""
    property string label: ""
    property string status: ""
    property bool active: false
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
    implicitHeight: 52
    radius: Settings.radiusMd
    color: active ? (hovered ? Utils.withAlpha(Settings.colors.accent, 0.2) : Settings.colors.accentSoft)
         : hovered ? Settings.colors.surfaceRaised : Settings.colors.surface
    border.width: 1
    border.color: active ? Utils.withAlpha(Settings.colors.accent, 0.35)
                : expanded ? Settings.colors.borderStrong : Settings.colors.border


    RowLayout {
      anchors { fill: parent; leftMargin: 14; rightMargin: tile.expandable ? 0 : 14 }
      spacing: 12

      MyIcon {
        icon: tile.icon
        size: 16
        color: tile.active ? Settings.colors.accent : Settings.colors.textMuted
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 1

        StyledText {
          Layout.fillWidth: true
          text: tile.label
          font.pixelSize: 12
          font.weight: Font.DemiBold
        }

        StyledText {
          Layout.fillWidth: true
          visible: text !== ""
          text: tile.status
          font.pixelSize: 11
          color: tile.active ? Settings.colors.accent : Settings.colors.textMuted
        }
      }

      Clickable {
        visible: tile.expandable
        Layout.fillHeight: true
        implicitWidth: 34
        radius: Settings.radiusMd
        color: hovered ? Utils.withAlpha(Settings.colors.text, 0.06) : "transparent"
        onClicked: tile.expandRequested()

        Hairline {
          vertical: true
          color: tile.active ? Utils.withAlpha(Settings.colors.accent, 0.35) : Settings.colors.border
        }

        MyIcon {
          anchors.centerIn: parent
          icon: "go-next-symbolic"
          size: 10
          color: tile.active ? Settings.colors.accent : Settings.colors.textMuted
          rotation: tile.expanded ? 90 : 0
          Behavior on rotation { Anim {} }
        }
      }
    }
  }

  // one level in the mixer box: the icon mutes, the name and chevron pick the device
  component LevelRow: Item {
    id: row

    property string icon: ""
    property string title: ""
    property real value: 0
    property real from: 0
    property bool muted: false
    property string panel: ""
    property bool divided: false

    signal iconClicked()
    signal moved(value: real)

    Layout.fillWidth: true
    implicitHeight: 54

    Hairline { visible: row.divided }

    RowLayout {
      anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
      spacing: 6

      IconButton {
        icon: row.icon
        size: 16
        padding: 8
        color: row.muted ? Settings.colors.error : Settings.colors.text
        hoverColor: Settings.colors.overlay
        enabled: row.panel !== ""
        opacity: 1
        onClicked: row.iconClicked()
      }

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 6

        RowLayout {
          Layout.fillWidth: true
          spacing: 8

          StyledText {
            Layout.fillWidth: true
            text: row.title
            font.pixelSize: 12
            color: row.muted ? Settings.colors.textMuted : Settings.colors.text
          }

          StyledText {
            text: row.muted ? "muted" : Math.round(row.value * 100) + "%"
            mono: true
            font.pixelSize: 11
            color: row.muted ? Settings.colors.error : Settings.colors.textMuted
          }
        }

        ThinSlider {
          Layout.fillWidth: true
          from: row.from
          value: row.value
          tint: row.muted ? Settings.colors.textSubtle : Settings.colors.accent
          onMoved: row.moved(value)
        }
      }

      IconButton {
        visible: row.panel !== ""
        icon: "go-next-symbolic"
        size: 10
        padding: 9
        color: root.openPanel === row.panel ? Settings.colors.accent : Settings.colors.textMuted
        hoverColor: Settings.colors.overlay
        onClicked: root.togglePanel(row.panel)
      }

      Item { visible: row.panel === ""; implicitWidth: 28 }
    }
  }

  // stacked card: rather than unfolding inline, a detail list slides
  // over the sheet as its own card (into `stackHost`), with the sheet dimmed
  // and peeking out behind it
  component DetailPanel: Item {
    id: panel

    property bool open: false
    property string title: ""
    property string actionIcon: ""
    property string emptyText: ""
    property alias model: list.model
    property alias delegate: list.delegate

    signal actionClicked()

    readonly property bool fromTop: Settings.barSide === "top"

    parent: root.stackHost
    z: 2
    width: parent?.width ?? 0
    // up to nearly the whole sheet, leaving a strip of it peeking out above
    height: Math.min(panelColumn.implicitHeight + 28, (parent?.height ?? 0) - 40)
    y: (fromTop ? 0 : (parent?.height ?? 0) - height) + (open ? 0 : (fromTop ? -24 : 24))
    opacity: open ? 1 : 0
    visible: opacity > 0

    Behavior on y { Anim {} }
    Behavior on opacity { Anim { duration: Settings.animFast } }

    CardSurface { raised: true; radius: Settings.cardRadius }

    ColumnLayout {
      id: panelColumn
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
      spacing: 8

      RowLayout {
        Layout.fillWidth: true
        Layout.leftMargin: 2

        SectionLabel { text: panel.title; tint: Settings.colors.accent }

        Item { Layout.fillWidth: true }

        IconButton {
          visible: panel.actionIcon !== ""
          icon: panel.actionIcon
          size: 14
          color: Settings.colors.textMuted
          onClicked: panel.actionClicked()
        }

        IconButton {
          icon: "window-close-symbolic"
          size: 12
          color: Settings.colors.textMuted
          onClicked: Runtime.quickPanel = ""
        }
      }

      Rule {}

      ScrollList {
        id: list
        Layout.fillWidth: true
        Layout.preferredHeight: Math.min(contentHeight, (root.stackHost?.height ?? 400) - 130)
        spacing: 2
      }

      StyledText {
        visible: panel.emptyText !== ""
        Layout.alignment: Qt.AlignHCenter
        Layout.topMargin: 6
        Layout.bottomMargin: 10
        text: panel.emptyText
        color: Settings.colors.textMuted
        font.pixelSize: 12
      }
    }
  }
}
