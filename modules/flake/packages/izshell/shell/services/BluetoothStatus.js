.pragma library

// What Bluetooth devices and the adapter say about themselves, and what clicking
// one does. Pure: callers describe a device as { paired, connected, pairing,
// connecting, disconnecting, battery } (battery is null, or 0 to 1).

function batteryText(battery) {
  return battery === null || battery === undefined ? "" : `${Math.round(battery * 100)}%`;
}

// a device row on the settings page
function deviceDetail(d) {
  if (d.pairing) return "Pairing…";
  if (d.connecting) return "Connecting…";
  if (d.disconnecting) return "Disconnecting…";
  if (d.connected) return "Connected" + (d.battery != null ? ` · ${batteryText(d.battery)}` : "");
  return "Not connected";
}

// a device in the quick settings list: battery, then connected or paired
function deviceBadge(d) {
  return (d.battery != null ? batteryText(d.battery) + " · " : "") + (d.connected ? "connected" : (d.paired ? "paired" : ""));
}

// what clicking a device in the list does
function primaryAction(d) {
  if (d.connected) return "disconnect";
  return d.paired ? "connect" : "pair";
}

// the adapter, as one line: a = { blocked, enabling, disabling, powered,
// connectedName, connectedBattery }
function adapterStatus(a) {
  if (a.blocked) return "Blocked";
  if (a.enabling) return "Enabling...";
  if (a.disabling) return "Disabling...";
  if (!a.powered) return "Bluetooth Off";
  if (a.connectedName != null) return a.connectedName + (a.connectedBattery != null ? ` · ${batteryText(a.connectedBattery)}` : "");
  return "Not Connected";
}

// the quick settings tile: on or off, or the connected device
function tileStatus(a) {
  if (!a.powered) return "Off";
  // "Enabling...", a device, "Blocked" and so on, but plain "On" when nothing is connected
  const status = adapterStatus(a);
  return status === "Not Connected" ? "On" : status;
}
