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


  readonly property var groups: {
    const by = {};
    for (const c of NetworkConnections.connections) (by[c.type] = by[c.type] ?? []).push(c);
    const order = ["802-3-ethernet", "802-11-wireless", "wireguard", "vpn"];
    return Object.keys(by)
      .sort((a, b) => ((order.indexOf(a) + 1) || 99) - ((order.indexOf(b) + 1) || 99))
      .map(type => ({
        title: NetworkConnections.typeNames[type] ?? type,
        // the one in use first, then by name
        items: by[type].sort((a, b) => (b.device !== "") - (a.device !== "") || a.name.localeCompare(b.name)),
      }));
  }

  Rectangle {
    visible: NetworkConnections.error !== ""
    Layout.fillWidth: true
    implicitHeight: errText.implicitHeight + 16
    radius: Settings.radiusSm
    color: Utils.withAlpha(Settings.colors.error, 0.12)
    border.color: Settings.colors.error
    border.width: 1

    StyledText {
      id: errText
      anchors { fill: parent; margins: 8 }
      text: NetworkConnections.error
      color: Settings.colors.error
      font.pixelSize: 11
      wrapMode: Text.Wrap
    }
  }

  Repeater {
    model: root.groups

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

  Component.onCompleted: {
    NetworkConnections.watching = true;
    NetworkConnections.findWireguardFiles();
    Networking.scanning = true;
  }
  Component.onDestruction: {
    NetworkConnections.watching = false;
    Networking.scanning = false;
  }

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
        else Networking.scanning = !Networking.scanning;
      }
    }

    Repeater {
      model: root.nearby

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

    StyledText {
      text: header.title
      font.pixelSize: 13
      font.weight: Font.Medium
    }

    StyledText {
      Layout.fillWidth: true
      text: header.status
      font.pixelSize: 11
      color: Settings.colors.textMuted
      elide: Text.ElideRight
    }

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

    MyIcon {
      icon: found.icon
      size: 14
      color: Settings.colors.textMuted
    }

    StyledText {
      text: found.text
      font.pixelSize: 12
    }

    StyledText {
      Layout.fillWidth: true
      text: found.detail
      mono: true
      font.pixelSize: 11
      color: Settings.colors.textMuted
      elide: Text.ElideMiddle
    }

    BoxButton {
      implicitHeight: 28
      fontSize: 11
      text: found.button
      enabled: !NetworkConnections.busy
      onClicked: found.clicked()
    }
  }

  // a network in range: open ones join on click, the rest ask for a password inline
  component NearbyRow: ColumnLayout {
    id: net
    required property Net.WifiNetwork modelData
    readonly property bool locked: Networking.needsPassword(modelData)
    property bool asking: false
    property bool connecting: false
    property string failure: ""

    Layout.fillWidth: true
    spacing: 8

    function join(password: string): void {
      failure = "";
      connecting = true;
      if (password !== "") modelData.connectWithPsk(password);
      else modelData.connect();
    }

    Connections {
      target: net.modelData
      ignoreUnknownSignals: true
      function onConnectionFailed(reason: int) {
        net.connecting = false;
        net.failure = Net.ConnectionFailReason.toString(reason);
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 12

      MyIcon {
        icon: Networking.networkIcon(net.modelData)
        size: 14
        color: Settings.colors.textMuted
      }

      StyledText {
        Layout.fillWidth: true
        text: net.modelData.name
        font.pixelSize: 12
        elide: Text.ElideRight
      }

      MyIcon {
        visible: net.locked
        icon: "system-lock-screen-symbolic"
        size: 11
        color: Settings.colors.textSubtle
      }

      StyledText {
        text: net.connecting ? "Connecting…" : net.failure !== "" ? net.failure : Math.round(net.modelData.signalStrength * 100) + "%"
        mono: !net.connecting && net.failure === ""
        font.pixelSize: 11
        color: net.failure !== "" ? Settings.colors.error : Settings.colors.textMuted
      }

      BoxButton {
        implicitHeight: 28
        fontSize: 11
        text: net.asking ? "Cancel" : "Connect"
        enabled: !net.connecting
        onClicked: {
          if (!net.locked) net.join("");
          else net.asking = !net.asking;
        }
      }
    }

    RowLayout {
      visible: net.asking
      Layout.fillWidth: true
      Layout.leftMargin: 26
      spacing: 8

      InputField {
        id: psk
        Layout.fillWidth: true
        implicitHeight: 30
        fontSize: 12
        placeholder: "Password"
        password: true
        error: net.failure !== ""
        onAccepted: if (joinButton.enabled) joinButton.clicked(null)
      }

      BoxButton {
        id: joinButton
        implicitHeight: 30
        fontSize: 11
        filled: true
        text: "Join"
        enabled: !net.connecting && psk.text !== ""
        onClicked: {
          net.join(psk.text);
          net.asking = false;
        }
      }
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
      color: Settings.colors.textMuted
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
          icon: ({
            "802-3-ethernet": "network-wired-symbolic",
            "802-11-wireless": "network-wireless-symbolic",
            "wireguard": "network-vpn-symbolic",
            "vpn": "network-vpn-symbolic",
          })[conn.modelData.type] ?? "network-workgroup-symbolic"
          size: 15
          color: conn.active ? Settings.colors.accent : Settings.colors.textMuted
        }

        StyledText {
          Layout.fillWidth: true
          text: conn.modelData.name
          font.pixelSize: 13
          font.weight: Font.Medium
          elide: Text.ElideRight
        }

        StyledText {
          visible: conn.active
          text: `Connected · ${conn.modelData.device}`
          color: Settings.colors.accent
          font.pixelSize: 11
          font.weight: Font.DemiBold
        }

        MyIcon {
          icon: conn.open ? "pan-up-symbolic" : "pan-down-symbolic"
          size: 12
          color: Settings.colors.textMuted
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
    readonly property string mtuKey: saved["connection.type"] === "802-11-wireless" ? "802-11-wireless.mtu" : "802-3-ethernet.mtu"
    readonly property bool hasMtu: saved[mtuKey] !== undefined && saved[mtuKey] !== ""

    property bool autoconnect: saved["connection.autoconnect"] === "yes"
    property string v4method: saved["ipv4.method"] ?? "auto"
    property string v6method: saved["ipv6.method"] ?? "auto"

    // nmcli only gets the keys that differ from what is saved
    function changes(): var {
      const want = {
        "connection.autoconnect": autoconnect ? "yes" : "no",
        "ipv4.method": v4method,
        "ipv6.method": v6method,
      };
      for (const [k, field] of [["ipv4.addresses", v4addr], ["ipv4.gateway", v4gw], ["ipv4.dns", v4dns],
                                ["ipv6.addresses", v6addr], ["ipv6.gateway", v6gw], ["ipv6.dns", v6dns]]) {
        if (field.visible) want[k] = field.text.trim();
      }
      // custom DNS replaces what the network hands out rather than adding to it
      want["ipv4.ignore-auto-dns"] = v4dns.text.trim() !== "" ? "yes" : "no";
      want["ipv6.ignore-auto-dns"] = v6dns.text.trim() !== "" ? "yes" : "no";
      if (hasMtu) want[mtuKey] = mtu.text.trim() || "auto";
      return Object.fromEntries(Object.entries(want).filter(([k, v]) => (saved[k] ?? "") !== v));
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
      visible: ed.hasMtu
      Text4 { id: mtu; placeholder: "auto"; text: (ed.saved[ed.mtuKey] ?? "auto") === "auto" ? "" : ed.saved[ed.mtuKey] }
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
        fillColor: Settings.colors.error
        onClicked: {
          if (!armed) return armed = true;
          NetworkConnections.remove(ed.uuid);
          ed.closed();
        }
        Timer { running: forget.armed; interval: 3000; onTriggered: forget.armed = false }
      }

      Item { Layout.fillWidth: true }

      StyledText {
        visible: ed.active
        text: "Saving reconnects"
        color: Settings.colors.textMuted
        font.pixelSize: 11
      }

      BoxButton {
        implicitHeight: 30
        fontSize: 11
        text: NetworkConnections.busy ? "Saving…" : "Save"
        filled: true
        onClicked: if (!NetworkConnections.busy) NetworkConnections.save(ed.uuid, ed.changes(), ed.active)
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
      color: Settings.colors.textMuted
    }
  }

  component Text4: InputField {
    Layout.fillWidth: true
    implicitHeight: 30
    fontSize: 12
    mono: true
  }
}
