.pragma library
.import "Toml.js" as Toml

// The pure half of the Settings module: what a Setting is (key, type, default,
// options), how one is checked, written to and read from TOML or IPC text, and
// the lists the settings window and bar are built from. No Quickshell types, so
// it runs under qmltestrunner.

// ids the bar can place, and the status capsule's own icons
const barItems = ["launcher", "workspaces", "clock", "media", "mic", "tray", "status"];
const statusItems = ["notifications", "volume", "mic", "network", "battery"];
// bar items that get a card of their own, because they only show while
// something is happening (a player, mic in use or screen share)
const loneItems = ["media", "mic"];

const itemNames = {
  launcher: "Launcher", workspaces: "Workspaces", clock: "Clock", media: "Media", mic: "Microphone", tray: "Tray",
  status: "Status capsule", notifications: "Notifications", volume: "Volume", network: "Network", battery: "Battery",
};

// page groups on the settings home, in order
const pageGroupTitles = ["Desktop", "Alerts", "Devices"];

// Sections are settings pages. `group` places the page on the settings home and
// `blurb` is its caption there (else its entries' groups). A `custom` section
// has no entries: its page is built by hand.
const schema = [
  {
    name: "general", title: "General", icon: "avatar-default-symbolic", group: "Desktop",
    entries: [
      { key: "username", group: "Profile", label: "Name", type: "string", default: "isabel" },
      { key: "profile_picture", group: "Profile", label: "Profile picture", type: "path",
        default: "", hint: "Also set as your account picture, which the login screen shows. Empty keeps the current one." },
      { key: "wallpaper", group: "Desktop", label: "Wallpaper", type: "wallpaper",
        default: "" },
    ]
  },
  {
    name: "appearance", title: "Appearance", icon: "applications-graphics-symbolic", group: "Desktop",
    entries: [
      { key: "theme", group: "Colour", label: "Theme", type: "choice", default: "dark", options: ["dark", "light"],
        hint: "Light is Catppuccin Latte." },
      { key: "accent", group: "Colour", label: "Accent colour", type: "color", default: "pink",
        options: ["rosewater", "flamingo", "pink", "mauve", "red", "maroon", "peach", "yellow",
                  "green", "teal", "sky", "sapphire", "blue", "lavender"] },
      { key: "rounding", group: "Shape and motion", label: "Corner rounding", type: "int", default: 2, min: 0, max: 14,
        hint: "0 is fully square. Bump it up for a softer look." },
      { key: "animations", group: "Shape and motion", label: "Animations", type: "bool", default: true },
      { key: "animation_speed", group: "Shape and motion", label: "Animation speed", type: "float", default: 1.0, min: 0.25, max: 2.0, step: 0.05,
        hint: "Multiplier on every transition. Lower is snappier." },
    ]
  },
  {
    name: "bar", title: "Bar", icon: "view-dual-symbolic", group: "Desktop",
    entries: [
      { key: "side", group: "Position", label: "Screen edge", type: "choice", default: "left", options: ["left", "right", "top", "bottom"] },
      { key: "style", group: "Position", label: "Style", type: "choice", default: "attached", options: ["attached", "floating"],
        hint: "Floating cards with gaps, or one strip along the edge." },
      { key: "start", group: "Layout", label: "Start", type: "items", pool: "bar", options: barItems, default: ["launcher", "workspaces"],
        hint: "Top of a side bar, left of a top or bottom one." },
      { key: "middle", group: "Layout", label: "Middle", type: "items", pool: "bar", options: barItems, default: ["clock"] },
      { key: "end", group: "Layout", label: "End", type: "items", pool: "bar", options: barItems, default: ["media", "tray", "status"],
        hint: "Media only shows while something plays. The mic can sit here too, but starts in the status capsule." },
      { key: "status", group: "Layout", label: "Status capsule", type: "items", options: statusItems,
        default: ["notifications", "volume", "mic", "network", "battery"],
        hint: "Icons in the button that opens quick settings. The mic only shows while an app records or shares the screen." },
      { key: "workspace_colours", group: "Items", label: "Colour-coded workspaces", type: "bool", default: true,
        hint: "Off uses the accent colour for every workspace." },
      { key: "clock_24h", group: "Items", label: "24-hour clock", type: "bool", default: false },
      { key: "tray_hidden", group: "Items", label: "Hidden tray icons", type: "list", default: ["Spotify"],
        hint: "Tray icons from these apps are never shown. Matches the icon's id or title." },
      { key: "battery_percent", group: "Items", label: "Battery percentage", type: "bool", default: true },
    ]
  },
  {
    name: "notifications", title: "Notifications", icon: "preferences-system-notifications-symbolic", group: "Alerts",
    entries: [
      { key: "dnd", group: "Pop-ups", label: "Do not disturb", type: "bool", default: false },
      { key: "toasts", group: "Pop-ups", label: "Pop-up toasts", type: "bool", default: true },
      { key: "toast_timeout", group: "Pop-ups", label: "Toast duration (s)", type: "int", default: 5, min: 1, max: 30 },
      { key: "blacklist", group: "Pop-ups", label: "Muted apps", type: "list", default: ["Spotify"],
        hint: "Notifications from these apps are dropped entirely." },
      { key: "media_timeout", group: "Media", label: "Hide paused media after (minutes)", type: "int", default: 5, min: 0, max: 120,
        hint: "0 keeps a paused player visible until it closes." },
    ]
  },
  {
    name: "lock", title: "Lock screen", icon: "system-lock-screen-symbolic", group: "Alerts",
    blurb: "Idle lock and what it shows",
    entries: [
      { key: "idle_minutes", label: "Lock when idle (minutes)", type: "int", default: 10, min: 0, max: 120,
        hint: "0 never locks automatically. Apps playing video or audio can hold it off." },
      { key: "notification_count", label: "Show notification count", type: "bool", default: true,
        hint: "Only the number is shown, never the content." },
    ]
  },
  {
    name: "osd", title: "On-screen display", icon: "audio-volume-high-symbolic", group: "Alerts",
    blurb: "Volume, microphone, brightness",
    entries: [
      { key: "volume", label: "Volume OSD", type: "bool", default: true },
      { key: "mic", label: "Microphone OSD", type: "bool", default: true },
      { key: "brightness", label: "Brightness OSD", type: "bool", default: true },
    ]
  },
  {
    name: "screenshot", title: "Screenshots", icon: "camera-photo-symbolic", group: "Desktop",
    blurb: "Saving and what happens after",
    entries: [
      { key: "save", group: "Saving", label: "Save to disk", type: "bool", default: true,
        hint: "Off only copies captures to the clipboard." },
      { key: "folder", group: "Saving", label: "Folder", type: "path", folder: true, default: "", placeholder: "~/Pictures/Screenshots",
        hint: "Empty uses your XDG screenshots folder." },
      { key: "editor", group: "After a capture", label: "Open in the editor", type: "choice", default: "picker",
        options: ["never", "picker", "always"], hint: "Picker opens the editor only for captures taken from the picker." },
      { key: "notify", group: "After a capture", label: "Notification", type: "bool", default: true,
        hint: "A preview of the capture and where it went." },
    ]
  },
  { name: "sound", title: "Sound", icon: "audio-speakers-symbolic", group: "Devices", custom: true,
    blurb: "Outputs, inputs and apps", entries: [] },
  { name: "network", title: "Network", icon: "network-workgroup-symbolic", group: "Devices", custom: true,
    blurb: "Connections and Wi-Fi", entries: [] },
  { name: "bluetooth", title: "Bluetooth", icon: "bluetooth-symbolic", group: "Devices", custom: true,
    blurb: "Devices and pairing", entries: [] },
  { name: "system", title: "System", icon: "computer-symbolic", group: "Devices", custom: true,
    blurb: "About this machine", entries: [] },
];

function section(name) {
  return schema.find(s => s.name === name);
}

// the settings home: pages by group
function pageGroups() {
  return pageGroupTitles.map(title => ({ title, names: schema.filter(s => s.group === title).map(s => s.name) }));
}

// caption under a page on the settings home
function blurb(name) {
  const sec = section(name);
  if (!sec) return "";
  if (sec.blurb) return sec.blurb;
  const text = [...new Set(sec.entries.map(e => e.group).filter(g => g))].join(", ").toLowerCase();
  return text.charAt(0).toUpperCase() + text.slice(1);
}

// "section.key" -> the entry, or undefined
function entry(path) {
  const [sec, key] = String(path).split(".");
  const s = section(sec);
  return s ? s.entries.find(e => e.key === key) : undefined;
}

function defaults() {
  const out = {};
  for (const sec of schema)
    for (const e of sec.entries)
      out[`${sec.name}.${e.key}`] = e.default;
  return out;
}

// the value if `raw` is a valid one for the entry, else undefined
function coerce(e, raw) {
  const inRange = n => typeof n === "number" && isFinite(n) && n >= e.min && n <= e.max;
  switch (e.type) {
  case "bool":   return typeof raw === "boolean" ? raw : undefined;
  case "int":    return inRange(raw) && Number.isInteger(raw) ? raw : undefined;
  case "float":  return inRange(raw) ? raw : undefined;
  case "choice":
  case "color":  return e.options.includes(raw) ? raw : undefined;
  case "list":   return Array.isArray(raw) && raw.every(v => typeof v === "string") ? raw : undefined;
  case "items":  return Array.isArray(raw) && raw.every((v, i) => e.options.includes(v) && raw.indexOf(v) === i) ? raw : undefined;
  default:       return typeof raw === "string" ? raw : undefined;
  }
}

// what a valid value looks like, for an error message
function expected(e) {
  switch (e.type) {
  case "bool":   return "true or false";
  case "int":    return `a whole number from ${e.min} to ${e.max}`;
  case "float":  return `a number from ${e.min} to ${e.max}`;
  case "choice":
  case "color":  return `one of ${e.options.join(", ")} (lower case)`;
  case "list":   return `a list of strings, e.g. ["Spotify"]`;
  case "items":  return `a list from ${e.options.join(", ")}, each once`;
  default:       return "a string in quotes";
  }
}

// settings.toml text -> { values, error }. Bad entries fall back to their
// default, an unreadable file to all defaults; `error` says what was wrong.
function parse(text) {
  let parsed;
  try {
    parsed = Toml.parse(text);
  } catch (err) {
    return { values: null, error: `settings.toml: ${err.message}` };
  }

  const values = defaults();
  const problems = [];
  for (const sec of schema) {
    const table = parsed[sec.name] ?? {};
    for (const e of sec.entries) {
      if (!(e.key in table)) continue;
      const v = coerce(e, table[e.key]);
      if (v === undefined) problems.push(`${sec.name}.${e.key} should be ${expected(e)}`);
      else values[`${sec.name}.${e.key}`] = v;
    }
  }
  return { values, error: problems.length ? `Using defaults for: ${problems.join("; ")}` : "" };
}

function serialize(values) {
  return Toml.stringify(
    schema.filter(sec => !sec.custom).map(sec => ({
      name: sec.name,
      entries: sec.entries.map(e => ({
        key: e.key,
        comment: e.label,
        value: values[`${sec.name}.${e.key}`],
      })),
    })),
    "Quickshell settings. Edited from the settings window (gear in quick settings),\n" +
    "but hand edits are fine too: the shell reloads this file when it changes."
  );
}

// `values` with `path` set. Settings that imply another change make it here.
function applySet(values, path, value) {
  const next = Object.assign({}, values);
  next[path] = value;
  // floating cards are meant to be soft: picking floating with near-square
  // corners rounds them, which the rounding slider can still undo
  if (path === "bar.style" && value === "floating" && next["appearance.rounding"] < 6)
    next["appearance.rounding"] = 10;
  return next;
}

// `ipc call shell set <path> <text>`: text -> { ok, value } or { ok: false, error }
function fromText(path, text) {
  const e = entry(path);
  if (!e) return { ok: false, error: `unknown setting ${path}` };
  let raw = text;
  if (text === "true" || text === "false") raw = text === "true";
  else if (text !== "" && !isNaN(Number(text))) raw = Number(text);
  const v = coerce(e, raw);
  if (v === undefined) return { ok: false, error: `${path} should be ${expected(e)}` };
  return { ok: true, value: v };
}

function toText(value) {
  return JSON.stringify(value);
}

// bar items -> cards: runs of items share a card, lone items get their own
function barCards(items) {
  const out = [];
  for (const id of items) {
    const last = out[out.length - 1];
    if (!loneItems.includes(id) && last && !loneItems.includes(last[0])) last.push(id);
    else out.push([id]);
  }
  return out;
}

// One object per section holding that section's values: accessors.osd.volume.
// Reads go through `read(path)`, so a binding that uses one re-evaluates when the
// value changes. A name that is not a setting warns and reads undefined.
function accessors(read) {
  const tree = {};
  for (const sec of schema) {
    if (sec.entries.length === 0) continue;
    const group = {};
    for (const e of sec.entries) {
      const path = `${sec.name}.${e.key}`;
      Object.defineProperty(group, e.key, { get: () => read(path), enumerable: true });
    }
    tree[sec.name] = new Proxy(group, {
      get(target, prop) {
        if (typeof prop === "string" && !(prop in target)) console.warn(`unknown setting ${sec.name}.${prop}`);
        return target[prop];
      },
    });
  }
  return new Proxy(tree, {
    get(target, prop) {
      if (typeof prop === "string" && !(prop in target)) console.warn(`unknown settings section ${prop}`);
      return target[prop];
    },
  });
}
