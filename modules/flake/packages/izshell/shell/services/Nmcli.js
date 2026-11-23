.pragma library

// What the shell knows about nmcli: how to read its terse output, which fields
// and connection types matter, and which keys an edit changes. Pure, so it runs
// under qmltestrunner against recorded output.

// fields the connection editor shows; the mtu key depends on the connection type
const fields = [
  "connection.id", "connection.type", "connection.autoconnect",
  "ipv4.method", "ipv4.addresses", "ipv4.gateway", "ipv4.dns", "ipv4.ignore-auto-dns",
  "ipv6.method", "ipv6.addresses", "ipv6.gateway", "ipv6.dns", "ipv6.ignore-auto-dns",
  "802-3-ethernet.mtu", "802-11-wireless.mtu", "802-11-wireless.ssid",
];

// connection types in the order the connections page lists them
const types = {
  "802-3-ethernet": { name: "Wired", icon: "network-wired-symbolic" },
  "802-11-wireless": { name: "Wi-Fi", icon: "network-wireless-symbolic" },
  "wireguard": { name: "WireGuard", icon: "network-vpn-symbolic" },
  "vpn": { name: "VPN", icon: "network-vpn-symbolic" },
  "bridge": { name: "Bridge", icon: "network-workgroup-symbolic" },
  "bond": { name: "Bond", icon: "network-workgroup-symbolic" },
  "vlan": { name: "VLAN", icon: "network-workgroup-symbolic" },
};
const typeOrder = ["802-3-ethernet", "802-11-wireless", "wireguard", "vpn"];

function typeName(type) {
  return types[type]?.name ?? type;
}

function typeIcon(type) {
  return types[type]?.icon ?? "network-workgroup-symbolic";
}

// nmcli -t separates fields with ":" and escapes ":" and "\" inside them
function splitTerse(line) {
  const out = [""];
  for (let i = 0; i < line.length; i++) {
    const c = line[i];
    if (c === "\\" && i + 1 < line.length) out[out.length - 1] += line[++i];
    else if (c === ":") out.push("");
    else out[out.length - 1] += c;
  }
  return out;
}

// `nmcli -t -f NAME,UUID,TYPE,DEVICE,AUTOCONNECT connection show`
function parseConnections(text) {
  return text.split("\n")
    .filter(l => l !== "")
    .map(l => {
      const [name, uuid, type, device, autoconnect] = splitTerse(l);
      return { name, uuid, type, device, autoconnect: autoconnect === "yes" };
    })
    .filter(c => c.type !== "loopback");
}

// `nmcli -t -f <fields> connection show uuid <uuid>` -> { "ipv4.method": "auto", ... }
function parseDetails(text) {
  const d = {};
  for (const l of text.split("\n")) {
    const i = l.indexOf(":");
    if (i > 0) d[l.slice(0, i)] = l.slice(i + 1).replace(/\\(.)/g, "$1");
  }
  return d;
}

// `nmcli -t -f DEVICE,TYPE,STATE device` -> ethernet ports that have no active connection
function parseBareDevices(text) {
  return text.split("\n")
    .map(l => splitTerse(l))
    .filter(([device, type, state]) => type === "ethernet" && state === "disconnected")
    .map(([device]) => device);
}

// WireGuard config paths (one per line) that are not already imported as connections
function unimportedWireguard(text, connections) {
  const imported = connections.filter(c => c.type === "wireguard").map(c => c.name);
  return text.split("\n")
    .filter(p => p !== "")
    .filter(p => !imported.includes(p.replace(/^.*\//, "").replace(/\.conf$/, "")));
}

// connections by type for the connections page: types in a fixed order, the one in use first, then by name
function groupConnections(connections) {
  const by = {};
  for (const c of connections) (by[c.type] = by[c.type] ?? []).push(c);
  return Object.keys(by)
    .sort((a, b) => ((typeOrder.indexOf(a) + 1) || 99) - ((typeOrder.indexOf(b) + 1) || 99))
    .map(type => ({
      type,
      title: typeName(type),
      items: by[type].sort((a, b) => (b.device !== "") - (a.device !== "") || a.name.localeCompare(b.name)),
    }));
}

function mtuKey(type) {
  return type === "802-11-wireless" ? "802-11-wireless.mtu" : "802-3-ethernet.mtu";
}

// whether a connection has an MTU to edit
function hasMtu(saved) {
  const v = saved[mtuKey(saved["connection.type"])];
  return v !== undefined && v !== "";
}

// What the editor changed: the nmcli keys whose wanted value differs from
// `saved`. `form` has what the fields hold; an address, gateway, dns or mtu is
// null when its field isn't shown.
function connectionChanges(saved, form) {
  const want = {
    "connection.autoconnect": form.autoconnect ? "yes" : "no",
    "ipv4.method": form.v4method,
    "ipv6.method": form.v6method,
  };
  for (const [k, v] of [["ipv4.addresses", form.v4addr], ["ipv4.gateway", form.v4gw], ["ipv4.dns", form.v4dns],
                        ["ipv6.addresses", form.v6addr], ["ipv6.gateway", form.v6gw], ["ipv6.dns", form.v6dns]]) {
    if (v !== null && v !== undefined) want[k] = v.trim();
  }
  // custom DNS replaces what the network hands out rather than adding to it
  // (only for a DNS field that is shown: a hidden one says nothing about it)
  if (form.v4dns !== null && form.v4dns !== undefined) want["ipv4.ignore-auto-dns"] = form.v4dns.trim() !== "" ? "yes" : "no";
  if (form.v6dns !== null && form.v6dns !== undefined) want["ipv6.ignore-auto-dns"] = form.v6dns.trim() !== "" ? "yes" : "no";
  if (hasMtu(saved) && form.mtu !== null && form.mtu !== undefined) want[mtuKey(saved["connection.type"])] = form.mtu.trim() || "auto";
  // (no Object.fromEntries: this engine predates it)
  const changes = {};
  for (const k of Object.keys(want))
    if ((saved[k] ?? "") !== want[k]) changes[k] = want[k];
  return changes;
}

// { key: value, ... } -> ["key", "value", ...] for `nmcli connection modify`
// (no Array.flat: this engine predates it)
function modifyArgs(changes) {
  const args = [];
  for (const k of Object.keys(changes)) args.push(k, changes[k]);
  return args;
}
