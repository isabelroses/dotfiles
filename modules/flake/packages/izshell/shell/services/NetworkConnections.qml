pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// Saved NetworkManager connections, read and edited through nmcli. Nothing
// runs until something sets `watching`; while it is set, `nmcli monitor`
// keeps the list fresh.
Singleton {
  id: root

  property bool watching: false
  // [{ name, uuid, type, device, autoconnect }]
  property var connections: []
  // the open connection's settings, keyed like nmcli ("ipv4.method", ...)
  property var details: ({})
  property string detailsUuid: ""
  property string error: ""
  readonly property bool busy: edit.running
  property list<string> bareDevices: []
  property list<string> wireguardFiles: []
  property bool findingFiles: false

  // fields the editor shows; the mtu key depends on the connection type
  readonly property var fields: [
    "connection.id", "connection.type", "connection.autoconnect",
    "ipv4.method", "ipv4.addresses", "ipv4.gateway", "ipv4.dns", "ipv4.ignore-auto-dns",
    "ipv6.method", "ipv6.addresses", "ipv6.gateway", "ipv6.dns", "ipv6.ignore-auto-dns",
    "802-3-ethernet.mtu", "802-11-wireless.mtu", "802-11-wireless.ssid",
  ]

  readonly property var typeNames: ({
    "802-3-ethernet": "Wired",
    "802-11-wireless": "Wi-Fi",
    "wireguard": "WireGuard",
    "vpn": "VPN",
    "bridge": "Bridge",
    "bond": "Bond",
    "vlan": "VLAN",
  })

  // nmcli -t separates fields with ":" and escapes ":" and "\" inside them
  function splitTerse(line: string): var {
    const out = [""];
    for (let i = 0; i < line.length; i++) {
      const c = line[i];
      if (c === "\\" && i + 1 < line.length) out[out.length - 1] += line[++i];
      else if (c === ":") out.push("");
      else out[out.length - 1] += c;
    }
    return out;
  }

  function refresh(): void {
    if (!watching) return;
    list.running = true;
    devices.running = true;
  }

  function open(uuid: string): void {
    detailsUuid = uuid;
    details = {};
    show.command = ["nmcli", "-t", "-f", fields.join(","), "connection", "show", "uuid", uuid];
    show.running = true;
  }

  // changes: { "ipv4.method": "manual", ... }; active connections reconnect to apply
  function save(uuid: string, changes: var, reconnect: bool): void {
    const args = Object.entries(changes).flat();
    if (args.length === 0) return;
    run(["nmcli", "connection", "modify", "uuid", uuid, ...args], reconnect ? ["nmcli", "connection", "up", "uuid", uuid] : null);
  }

  function remove(uuid: string): void {
    if (detailsUuid === uuid) { detailsUuid = ""; details = {}; }
    run(["nmcli", "connection", "delete", "uuid", uuid], null);
  }

  function addWired(name: string): void {
    run(["nmcli", "connection", "add", "type", "ethernet", "ifname", "*", "con-name", name], null);
  }

  function addHiddenWifi(ssid: string, password: string): void {
    const cmd = ["nmcli", "device", "wifi", "connect", ssid, "hidden", "yes"];
    run(password ? [...cmd, "password", password] : cmd, null);
  }

  function importWireguard(path: string): void {
    run(["nmcli", "connection", "import", "type", "wireguard", "file", path], null);
  }

  function addForDevice(device: string): void {
    run(["nmcli", "connection", "add", "type", "ethernet", "ifname", device, "con-name", device], null);
  }

  function findWireguardFiles(): void {
    findingFiles = true;
    findFiles.running = true;
  }

  function run(cmd: var, then: var): void {
    error = "";
    edit.next = then;
    edit.command = cmd;
    edit.running = true;
  }

  onWatchingChanged: refresh()

  Process {
    id: list
    command: ["nmcli", "-t", "-f", "NAME,UUID,TYPE,DEVICE,AUTOCONNECT", "connection", "show"]
    stdout: StdioCollector {
      onStreamFinished: root.connections = text.split("\n")
        .filter(l => l !== "")
        .map(l => {
          const [name, uuid, type, device, autoconnect] = root.splitTerse(l);
          return { name, uuid, type, device, autoconnect: autoconnect === "yes" };
        })
        .filter(c => c.type !== "loopback")
    }
  }

  Process {
    id: show
    stdout: StdioCollector {
      onStreamFinished: {
        const d = {};
        for (const l of text.split("\n")) {
          const i = l.indexOf(":");
          if (i > 0) d[l.slice(0, i)] = l.slice(i + 1).replace(/\\(.)/g, "$1");
        }
        root.details = d;
      }
    }
  }

  Process {
    id: edit
    property var next: null
    stderr: StdioCollector { id: editErr }
    onExited: (code) => {
      if (code !== 0) {
        root.error = editErr.text.trim().replace(/^Error: /, "") || `nmcli exited with ${code}`;
      } else if (next) {
        const n = next;
        next = null;
        command = n;
        running = true;
        return;
      }
      root.refresh();
      if (root.detailsUuid) root.open(root.detailsUuid);
    }
  }

  Process {
    id: devices
    command: ["nmcli", "-t", "-f", "DEVICE,TYPE,STATE", "device"]
    stdout: StdioCollector {
      onStreamFinished: root.bareDevices = text.split("\n")
        .map(l => root.splitTerse(l))
        .filter(([device, type, state]) => type === "ethernet" && state === "disconnected")
        .map(([device]) => device)
    }
  }

  Process {
    id: findFiles
    command: ["sh", "-c", 'grep -lsx "\\[Interface\\]" "$HOME"/Downloads/*.conf "$HOME"/*.conf "$HOME"/.config/wireguard/*.conf /etc/wireguard/*.conf']
    stdout: StdioCollector {
      onStreamFinished: {
        const imported = root.connections.filter(c => c.type === "wireguard").map(c => c.name);
        root.wireguardFiles = text.split("\n")
          .filter(p => p !== "")
          .filter(p => !imported.includes(p.replace(/^.*\//, "").replace(/\.conf$/, "")));
        root.findingFiles = false;
      }
    }
  }

  // any change NetworkManager reports, from here or elsewhere
  Process {
    running: root.watching
    command: ["nmcli", "monitor"]
    stdout: SplitParser { onRead: settle.restart() }
  }

  Timer {
    id: settle
    interval: 500
    onTriggered: root.refresh()
  }
}
