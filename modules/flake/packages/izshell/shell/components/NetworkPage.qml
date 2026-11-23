import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Networking as Net
import qs.data
import qs.services

// Settings page for saved NetworkManager connections: grouped by type, one
// open at a time for editing. Adding scans for what is around: Wi-Fi in
// range, wired ports with no profile and WireGuard configs on disk.
ColumnLayout {
  id: root

  spacing: 10

  property string openUuid: ""


  ErrorBanner { text: NetworkConnections.error; Layout.fillWidth: true }

  Repeater {
    model: NetworkConnections.groups

    ColumnLayout {
      required property var modelData
      required property int index
      Layout.fillWidth: true
      Layout.topMargin: index > 0 ? 10 : 0
      spacing: 6

      SectionLabel { text: modelData.title; size: 16 }

      Repeater {
        model: modelData.items

        ConnectionRow {}
      }
    }
  }

  readonly property var nearby: Networking.networks
    .filter(n => !n.known && n.name !== "")
    .sort((a, b) => b.signalStrength - a.signalStrength)
    .slice(0, 8)

  Lease {
    active: true
    onAcquire: Networking.acquireScan()
    onRelease: Networking.releaseScan()
  }

  Component.onCompleted: {
    NetworkConnections.watching = true;
    NetworkConnections.findWireguardFiles();
  }
  Component.onDestruction: NetworkConnections.watching = false

  SectionLabel { text: "Add"; size: 16; Layout.topMargin: 10 }

  SettingsBlock {
    BlockHeader {
      title: "Nearby Wi-Fi"
      status: !Networking.wifiDevice ? "No Wi-Fi adapter"
        : !Networking.wifiEnabled ? "Wi-Fi is off"
        : Networking.scanning ? (root.nearby.length === 0 ? "Searching…" : "Scanning")
        : `${root.nearby.length} found`
      button: !Networking.wifiEnabled ? "Turn on" : Networking.scanning ? "Stop" : "Scan"
      buttonVisible: Networking.wifiDevice !== null
      onClicked: {
        if (!Networking.wifiEnabled) Networking.toggleWifi();
        else Networking.scanPaused = !Networking.scanPaused;
      }
    }

    Repeater {
      model: ScriptModel { values: [...root.nearby] }

      NearbyRow {}
    }

    Rule { visible: root.nearby.length > 0 }

    AddRow {
      label: "Hidden network"
      fields: [{ placeholder: "Network name" }, { placeholder: "Password", password: true, optional: true }]
      button: "Join"
      onAdd: (v) => NetworkConnections.addHiddenWifi(v[0], v[1])
    }
  }

  SettingsBlock {
    BlockHeader {
      title: "Wired"
      status: NetworkConnections.bareDevices.length === 0 ? "Every port has a profile" : ""
    }

    Repeater {
      model: NetworkConnections.bareDevices

      FoundRow {
        required property string modelData
        icon: "network-wired-symbolic"
        text: modelData
        detail: "No profile"
        button: "Set up"
        onClicked: NetworkConnections.addForDevice(modelData)
      }
    }

    AddRow {
      label: "New profile"
      fields: [{ placeholder: "Name" }]
      onAdd: (v) => NetworkConnections.addWired(v[0])
    }
  }

  SettingsBlock {
    BlockHeader {
      title: "WireGuard"
      status: NetworkConnections.findingFiles ? "Looking…"
        : NetworkConnections.wireguardFiles.length === 0 ? "No configs in Downloads, ~ or /etc/wireguard" : ""
      button: "Look again"
      onClicked: NetworkConnections.findWireguardFiles()
    }

    Repeater {
      model: NetworkConnections.wireguardFiles

      FoundRow {
        required property string modelData
        icon: "network-vpn-symbolic"
        text: modelData.replace(/^.*\//, "").replace(/\.conf$/, "")
        detail: modelData.replace(Quickshell.env("HOME"), "~")
        button: "Import"
        onClicked: NetworkConnections.importWireguard(modelData)
      }
    }

    AddRow {
      label: "From a file"
      fields: [{ placeholder: "/path/to/wg0.conf", mono: true }]
      button: "Import"
      onAdd: (v) => NetworkConnections.importWireguard(v[0])
    }
  }

  component BlockHeader: RowLayout {
    id: header
    property string title: ""
    property string status: ""
    property string button: ""
    property bool buttonVisible: button !== ""
    signal clicked()

    Layout.fillWidth: true
    spacing: 10

    StyledText { text: header.title; font.pixelSize: 13; font.weight: Font.Medium }

    Caption { Layout.fillWidth: true; text: header.status }

    BoxButton {
      visible: header.buttonVisible
      implicitHeight: 26
      fontSize: 11
      text: header.button
      onClicked: header.clicked()
    }
  }

  component FoundRow: RowLayout {
    id: found
    property string icon: ""
    property string text: ""
    property string detail: ""
    property string button: ""
    signal clicked()

    Layout.fillWidth: true
    spacing: 12

    MyIcon { icon: found.icon; size: 14; color: Theme.colors.textMuted }

    StyledText { text: found.text; font.pixelSize: 12 }

    Caption { Layout.fillWidth: true; text: found.detail; mono: true; elide: Text.ElideMiddle }

    BoxButton {
      implicitHeight: 28
      fontSize: 11
      text: found.button
      enabled: !NetworkConnections.busy
      onClicked: found.clicked()
    }
  }

  // a network in range; joining one that needs a password asks for it in the
  // password prompt, like the quick settings list does
  component NearbyRow: RowLayout {
    id: net
    required property Net.WifiNetwork modelData
    readonly property bool locked: Networking.needsPassword(modelData)
    readonly property bool mine: Networking.joinTarget === modelData
    readonly property bool connecting: mine && Networking.joinState === "connecting"
    readonly property string failure: mine && Networking.joinState === "failed" ? Networking.joinError : ""

    Layout.fillWidth: true
    spacing: 12

    MyIcon {
      icon: Networking.networkIcon(net.modelData)
      size: 14
      color: Theme.colors.textMuted
    }

    StyledText { Layout.fillWidth: true; text: net.modelData.name; font.pixelSize: 12 }

    MyIcon {
      visible: net.locked
      icon: "system-lock-screen-symbolic"
      size: 11
      color: Theme.colors.textSubtle
    }

    StyledText {
      text: net.connecting ? "Connecting…" : net.failure !== "" ? net.failure : Math.round(net.modelData.signalStrength * 100) + "%"
      mono: !net.connecting && net.failure === ""
      font.pixelSize: 11
      color: net.failure !== "" ? Theme.colors.error : Theme.colors.textMuted
    }

    BoxButton {
      implicitHeight: 28
      fontSize: 11
      // a stuck or unwanted attempt can be called off from here too
      text: net.connecting ? "Cancel" : "Connect"
      enabled: net.connecting || Networking.joinState !== "connecting"
      onClicked: net.connecting ? Networking.cancel() : Networking.join(net.modelData)
    }
  }

  component AddRow: RowLayout {
    id: add
    property string label: ""
    property var fields: []
    property string button: "Add"
    signal add(values: list<string>)

    Layout.fillWidth: true
    spacing: 8

    StyledText {
      Layout.preferredWidth: 130
      text: add.label
      font.pixelSize: 12
      color: Theme.colors.textMuted
    }

    Repeater {
      id: inputs
      model: add.fields

      InputField {
        required property var modelData
        Layout.fillWidth: true
        implicitHeight: 30
        fontSize: 12
        placeholder: modelData.placeholder
        password: modelData.password ?? false
        mono: modelData.mono ?? false
        onAccepted: go.clicked(null)
      }
    }

    BoxButton {
      id: go
      implicitHeight: 30
      fontSize: 11
      text: add.button
      onClicked: {
        const values = [];
        for (let i = 0; i < inputs.count; i++) values.push(inputs.itemAt(i).text.trim());
        if (values.some((v, i) => v === "" && !add.fields[i].optional)) return;
        add.add(values);
        for (let i = 0; i < inputs.count; i++) inputs.itemAt(i).text = "";
      }
    }
  }

  component ConnectionRow: SettingsBlock {
    id: conn
    required property var modelData
    readonly property bool open: root.openUuid === modelData.uuid
    readonly property bool active: modelData.device !== ""
    spacing: 14

    Clickable {
      Layout.fillWidth: true
      implicitHeight: 24
      onClicked: {
        root.openUuid = conn.open ? "" : conn.modelData.uuid;
        if (!conn.open) return;
        NetworkConnections.open(conn.modelData.uuid);
      }

      RowLayout {
        anchors.fill: parent
        spacing: 10

        MyIcon {
          icon: NetworkConnections.typeIcon(conn.modelData.type)
          size: 15
          color: conn.active ? Theme.colors.accent : Theme.colors.textMuted
        }

        StyledText {
          Layout.fillWidth: true
          text: conn.modelData.name
          font.pixelSize: 13
          font.weight: Font.Medium
        }

        StyledText {
          visible: conn.active
          text: `Connected · ${conn.modelData.device}`
          color: Theme.colors.accent
          font.pixelSize: 11
          font.weight: Font.DemiBold
        }

        MyIcon {
          icon: conn.open ? "pan-up-symbolic" : "pan-down-symbolic"
          size: 12
          color: Theme.colors.textMuted
        }
      }
    }

    Loader {
      Layout.fillWidth: true
      active: conn.open && NetworkConnections.detailsUuid === conn.modelData.uuid
        && NetworkConnections.details["connection.id"] !== undefined
      visible: active
      sourceComponent: ConnectionEditor {
        uuid: conn.modelData.uuid
        active: conn.active
        onClosed: root.openUuid = ""
      }
    }
  }

  // the settings people actually change: auto-connect, addressing, DNS, MTU
  component ConnectionEditor: ColumnLayout {
    id: ed
    property string uuid: ""
    property bool active: false
    signal closed()

    readonly property var saved: NetworkConnections.details

    property bool autoconnect: saved["connection.autoconnect"] === "yes"
    property string v4method: saved["ipv4.method"] ?? "auto"
    property string v6method: saved["ipv6.method"] ?? "auto"

    // what the fields hold; one that isn't shown is null
    function form(): var {
      return {
        autoconnect, v4method, v6method,
        v4addr: v4addr.visible ? v4addr.text : null,
        v4gw: v4gw.visible ? v4gw.text : null,
        v4dns: v4dns.visible ? v4dns.text : null,
        v6addr: v6addr.visible ? v6addr.text : null,
        v6gw: v6gw.visible ? v6gw.text : null,
        v6dns: v6dns.visible ? v6dns.text : null,
        mtu: NetworkConnections.hasMtu ? mtu.text : null,
      };
    }

    spacing: 10

    Rule {}

    Field {
      label: "Connect automatically"
      ToggleSwitch { on: ed.autoconnect; onToggled: ed.autoconnect = !ed.autoconnect }
    }

    Field {
      label: "IPv4"
      ChoicePills {
        options: [{ value: "auto", label: "Automatic" }, { value: "manual", label: "Manual" }, { value: "disabled", label: "Off" }]
        value: ed.v4method
        onPicked: (v) => ed.v4method = v
      }
    }
    Field { label: "Address"; visible: ed.v4method === "manual"; Text4 { id: v4addr; placeholder: "192.168.1.20/24"; text: ed.saved["ipv4.addresses"] ?? "" } }
    Field { label: "Gateway"; visible: ed.v4method === "manual"; Text4 { id: v4gw; placeholder: "192.168.1.1"; text: ed.saved["ipv4.gateway"] ?? "" } }
    Field { label: "DNS"; visible: ed.v4method !== "disabled"; Text4 { id: v4dns; placeholder: ed.v4method === "auto" ? "From the network" : "1.1.1.1, 9.9.9.9"; text: ed.saved["ipv4.dns"] ?? "" } }

    Field {
      label: "IPv6"
      ChoicePills {
        options: [{ value: "auto", label: "Automatic" }, { value: "manual", label: "Manual" }, { value: "disabled", label: "Off" }]
        value: ed.v6method
        onPicked: (v) => ed.v6method = v
      }
    }
    Field { label: "Address"; visible: ed.v6method === "manual"; Text4 { id: v6addr; placeholder: "fd00::20/64"; text: ed.saved["ipv6.addresses"] ?? "" } }
    Field { label: "Gateway"; visible: ed.v6method === "manual"; Text4 { id: v6gw; placeholder: "fd00::1"; text: ed.saved["ipv6.gateway"] ?? "" } }
    Field { label: "DNS"; visible: ed.v6method !== "disabled"; Text4 { id: v6dns; placeholder: ed.v6method === "auto" ? "From the network" : "2606:4700:4700::1111"; text: ed.saved["ipv6.dns"] ?? "" } }

    Field {
      label: "MTU"
      visible: NetworkConnections.hasMtu
      Text4 { id: mtu; placeholder: "auto"; text: NetworkConnections.mtu === "auto" ? "" : NetworkConnections.mtu }
    }

    RowLayout {
      Layout.fillWidth: true
      Layout.topMargin: 4
      spacing: 8

      BoxButton {
        id: forget
        property bool armed: false
        implicitHeight: 30
        fontSize: 11
        text: armed ? "Sure?" : "Forget"
        filled: armed
        fillColor: Theme.colors.error
        onClicked: {
          if (!armed) return armed = true;
          NetworkConnections.remove(ed.uuid);
          ed.closed();
        }
        Timer { running: forget.armed; interval: 3000; onTriggered: forget.armed = false }
      }

      Item { Layout.fillWidth: true }

      Caption { visible: ed.active; text: "Saving reconnects" }

      BoxButton {
        implicitHeight: 30
        fontSize: 11
        text: NetworkConnections.busy ? "Saving…" : "Save"
        filled: true
        onClicked: if (!NetworkConnections.busy) NetworkConnections.saveEdits(ed.uuid, ed.form(), ed.active)
      }
    }
  }

  component Field: RowLayout {
    property string label: ""
    Layout.fillWidth: true
    spacing: 12

    StyledText {
      Layout.preferredWidth: 160
      text: parent.label
      font.pixelSize: 12
      color: Theme.colors.textMuted
    }
  }

  component Text4: InputField {
    Layout.fillWidth: true
    implicitHeight: 30
    fontSize: 12
    mono: true
  }
}
