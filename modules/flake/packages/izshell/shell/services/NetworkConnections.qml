pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "Nmcli.js" as Nmcli

// Saved NetworkManager connections, read and edited through nmcli. Nothing
// runs until something sets `watching`; while it is set, `nmcli monitor`
// keeps the list fresh. What nmcli's output and keys mean is Nmcli.js's.
Singleton {
  id: root

  property bool watching: false
  // [{ name, uuid, type, device, autoconnect }]
  property var connections: []
  // by type for the connections page: [{ type, title, items }]
  readonly property var groups: Nmcli.groupConnections(connections)
  // the open connection's settings, keyed like nmcli ("ipv4.method", ...)
  property var details: ({})
  property string detailsUuid: ""
  readonly property bool hasMtu: Nmcli.hasMtu(details)
  // the open connection's MTU as nmcli reports it ("auto", a number, or "")
  readonly property string mtu: details[Nmcli.mtuKey(details["connection.type"])] ?? ""
  property string error: ""
  readonly property bool busy: edit.running
  property list<string> bareDevices: []
  property list<string> wireguardFiles: []
  property bool findingFiles: false

  function typeName(type: string): string { return Nmcli.typeName(type); }
  function typeIcon(type: string): string { return Nmcli.typeIcon(type); }

  function refresh(): void {
    if (!watching) return;
    list.running = true;
    devices.running = true;
  }

  function open(uuid: string): void {
    detailsUuid = uuid;
    details = {};
    show.command = ["nmcli", "-t", "-f", Nmcli.fields.join(","), "connection", "show", "uuid", uuid];
    show.running = true;
  }

  // `form` is what the editor holds (see Nmcli.connectionChanges); only keys
  // that differ from what is saved are sent, and an active connection can
  // reconnect to apply them
  function saveEdits(uuid: string, form: var, reconnect: bool): void {
    const args = Nmcli.modifyArgs(Nmcli.connectionChanges(details, form));
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
      onStreamFinished: root.connections = Nmcli.parseConnections(text)
    }
  }

  Process {
    id: show
    stdout: StdioCollector {
      onStreamFinished: root.details = Nmcli.parseDetails(text)
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
      onStreamFinished: root.bareDevices = Nmcli.parseBareDevices(text)
    }
  }

  Process {
    id: findFiles
    command: ["sh", "-c", 'grep -lsx "\\[Interface\\]" "$HOME"/Downloads/*.conf "$HOME"/*.conf "$HOME"/.config/wireguard/*.conf /etc/wireguard/*.conf']
    stdout: StdioCollector {
      onStreamFinished: {
        root.wireguardFiles = Nmcli.unimportedWireguard(text, root.connections);
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
