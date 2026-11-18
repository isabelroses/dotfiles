pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "Toml.js" as Toml

Singleton {
  id: root

  // settings are edited at runtime, so they live outside the (read-only) shell
  readonly property string path: Quickshell.env("IZSHELL_SETTINGS")
    || `${Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config"}/izshell/settings.toml`

  readonly property var barItems: ["launcher", "workspaces", "clock", "media", "tray", "status"]
  readonly property var itemNames: ({
    launcher: "Launcher", workspaces: "Workspaces", clock: "Clock", media: "Media", tray: "Tray",
    status: "Status capsule", notifications: "Notifications", volume: "Volume", network: "Network", battery: "Battery",
  })

  readonly property var pageGroups: [
    { title: "Desktop", names: ["general", "appearance", "bar", "screenshot"] },
    { title: "Alerts", names: ["notifications", "lock", "osd"] },
    { title: "Devices", names: ["sound", "network", "bluetooth", "system"] },
  ]

  readonly property var schema: [
    {
      name: "general", title: "General", icon: "avatar-default-symbolic",
      entries: [
        { key: "username", group: "Profile", label: "Name", type: "string", default: "isabel" },
        { key: "profile_picture", group: "Profile", label: "Profile picture", type: "path",
          default: "", hint: "Also set as your account picture, which the login screen shows. Empty keeps the current one." },
        { key: "wallpaper", group: "Desktop", label: "Wallpaper", type: "wallpaper",
          default: "" },
      ]
    },
    {
      name: "appearance", title: "Appearance", icon: "applications-graphics-symbolic",
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
      name: "bar", title: "Bar", icon: "view-dual-symbolic",
      entries: [
        { key: "side", group: "Position", label: "Screen edge", type: "choice", default: "left", options: ["left", "right", "top", "bottom"] },
        { key: "style", group: "Position", label: "Style", type: "choice", default: "attached", options: ["attached", "floating"],
          hint: "Floating cards with gaps, or one strip along the edge." },
        { key: "start", group: "Layout", label: "Start", type: "items", pool: "bar", options: root.barItems, default: ["launcher", "workspaces"],
          hint: "Top of a side bar, left of a top or bottom one." },
        { key: "middle", group: "Layout", label: "Middle", type: "items", pool: "bar", options: root.barItems, default: ["clock"] },
        { key: "end", group: "Layout", label: "End", type: "items", pool: "bar", options: root.barItems, default: ["media", "tray", "status"],
          hint: "Media only shows while something plays, records or shares the screen." },
        { key: "status", group: "Layout", label: "Status capsule", type: "items", options: ["notifications", "volume", "network", "battery"],
          default: ["notifications", "volume", "network", "battery"], hint: "Icons in the button that opens quick settings." },
        { key: "workspace_colours", group: "Items", label: "Colour-coded workspaces", type: "bool", default: true,
          hint: "Off uses the accent colour for every workspace." },
        { key: "clock_24h", group: "Items", label: "24-hour clock", type: "bool", default: false },
        { key: "tray_hidden", group: "Items", label: "Hidden tray icons", type: "list", default: ["Spotify"],
          hint: "Tray icons from these apps are never shown. Matches the icon's id or title." },
        { key: "battery_percent", group: "Items", label: "Battery percentage", type: "bool", default: true },
      ]
    },
    {
      name: "notifications", title: "Notifications", icon: "preferences-system-notifications-symbolic",
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
      name: "lock", title: "Lock screen", icon: "system-lock-screen-symbolic",
      entries: [
        { key: "idle_minutes", label: "Lock when idle (minutes)", type: "int", default: 10, min: 0, max: 120,
          hint: "0 never locks automatically. Apps playing video or audio can hold it off." },
        { key: "notification_count", label: "Show notification count", type: "bool", default: true,
          hint: "Only the number is shown, never the content." },
      ]
    },
    {
      name: "osd", title: "On-screen display", icon: "audio-volume-high-symbolic",
      entries: [
        { key: "volume", label: "Volume OSD", type: "bool", default: true },
        { key: "mic", label: "Microphone OSD", type: "bool", default: true },
        { key: "brightness", label: "Brightness OSD", type: "bool", default: true },
      ]
    },
    {
      name: "screenshot", title: "Screenshots", icon: "camera-photo-symbolic",
      entries: [
        { key: "save", group: "Saving", label: "Save to disk", type: "bool", default: true,
          hint: "Off only copies captures to the clipboard." },
        { key: "folder", group: "Saving", label: "Folder", type: "path", folder: true, default: "", placeholder: "~/Pictures/Screenshots",
          hint: "Empty uses your XDG screenshots folder." },
        { key: "editor", group: "After a capture", label: "Open in the editor", type: "choice", default: "picker",
          options: ["never", "picker", "always"], hint: "Picker opens swappy only for captures taken from the picker." },
        { key: "notify", group: "After a capture", label: "Notification", type: "bool", default: true,
          hint: "A preview of the capture and where it went." },
      ]
    },
  ]

  property var values: defaults()
  property string error: ""
  property bool loaded: false

  function get(path: string): var {
    return values[path];
  }

  function set(path: string, value: var): void {
    const next = Object.assign({}, values);
    next[path] = value;
    // floating cards are meant to be soft: picking floating with near-square
    // corners rounds them, which the rounding slider can still undo
    if (path === "bar.style" && value === "floating" && next["appearance.rounding"] < 6)
      next["appearance.rounding"] = 10;
    values = next;
    saveTimer.restart();
  }

  function reset(path: string): void {
    set(path, entry(path).default);
  }

  function resetAll(): void {
    values = defaults();
    saveTimer.restart();
  }

  function entry(path: string): var {
    const [section, key] = path.split(".");
    const sec = schema.find(s => s.name === section);
    return sec ? sec.entries.find(e => e.key === key) : undefined;
  }

  function defaults(): var {
    const out = {};
    for (const sec of schema)
      for (const e of sec.entries)
        out[`${sec.name}.${e.key}`] = e.default;
    return out;
  }

  function coerce(e: var, raw: var): var {
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

  function expected(e: var): string {
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

  function applyText(text: string): void {
    let parsed;
    try {
      parsed = Toml.parse(text);
    } catch (err) {
      error = `settings.toml: ${err.message}`;
      console.warn(error);
      return;
    }

    const next = defaults();
    const problems = [];
    for (const sec of schema) {
      const table = parsed[sec.name] ?? {};
      for (const e of sec.entries) {
        if (!(e.key in table)) continue;
        const v = coerce(e, table[e.key]);
        if (v === undefined) problems.push(`${sec.name}.${e.key} should be ${expected(e)}`);
        else next[`${sec.name}.${e.key}`] = v;
      }
    }

    error = problems.length ? `Using defaults for: ${problems.join("; ")}` : "";
    values = next;
    loaded = true;
  }

  function serialize(): string {
    return Toml.stringify(
      schema.map(sec => ({
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

  Timer {
    id: saveTimer
    interval: 400
    onTriggered: {
      file.setText(root.serialize());
      root.error = "";
    }
  }

  FileView {
    id: file
    path: root.path
    watchChanges: true
    printErrors: false

    onLoaded: root.applyText(text())
    onFileChanged: reload()
    onLoadFailed: (err) => {
      if (err === FileViewError.FileNotFound) {
        root.loaded = true;
        setText(root.serialize());
      } else {
        root.error = `Couldn't read settings.toml (${FileViewError.toString(err)})`;
      }
    }
  }
}
