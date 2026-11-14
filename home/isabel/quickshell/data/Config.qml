pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "Toml.js" as Toml

Singleton {
  id: root

  readonly property string path: Quickshell.shellPath("settings.toml")

  readonly property var schema: [
    {
      name: "appearance", title: "Appearance", icon: "applications-graphics-symbolic",
      entries: [
        { key: "accent", label: "Accent colour", type: "color", default: "pink",
          options: ["rosewater", "flamingo", "pink", "mauve", "red", "maroon", "peach", "yellow",
                    "green", "teal", "sky", "sapphire", "blue", "lavender"] },
        { key: "rounding", label: "Corner rounding", type: "int", default: 2, min: 0, max: 14,
          hint: "0 is fully square. Bump it up for a softer look." },
        { key: "animations", label: "Animations", type: "bool", default: true },
        { key: "animation_speed", label: "Animation speed", type: "float", default: 1.0, min: 0.25, max: 2.0, step: 0.05,
          hint: "Multiplier on every transition. Lower is snappier." },
      ]
    },
    {
      name: "bar", title: "Bar", icon: "view-dual-symbolic",
      entries: [
        { key: "side", label: "Screen edge", type: "choice", default: "left", options: ["left", "right"] },
        { key: "clock_24h", label: "24-hour clock", type: "bool", default: false },
        { key: "show_tray", label: "System tray", type: "bool", default: true },
        { key: "battery_percent", label: "Battery percentage", type: "bool", default: true },
        { key: "workspace_colours", label: "Colour-coded workspaces", type: "bool", default: true,
          hint: "Off uses the accent colour for every workspace." },
      ]
    },
    {
      name: "quick_settings", title: "Quick settings", icon: "preferences-system-symbolic",
      entries: [
        { key: "show_media", label: "Media player", type: "bool", default: true },
        { key: "show_notifications", label: "Notification list", type: "bool", default: true },
      ]
    },
    {
      name: "notifications", title: "Notifications", icon: "preferences-system-notifications-symbolic",
      entries: [
        { key: "dnd", label: "Do not disturb", type: "bool", default: false },
        { key: "toasts", label: "Pop-up toasts", type: "bool", default: true },
        { key: "toast_timeout", label: "Toast duration (s)", type: "int", default: 5, min: 1, max: 30 },
        { key: "blacklist", label: "Muted apps", type: "list", default: ["Spotify"],
          hint: "Notifications from these apps are dropped entirely." },
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
      ]
    },
    {
      name: "general", title: "General", icon: "avatar-default-symbolic",
      entries: [
        { key: "username", label: "Name", type: "string", default: "isabel" },
        { key: "profile_picture", label: "Profile picture", type: "path",
          default: "/home/isabel/media/pictures/pfps/_current.png" },
        { key: "wallpaper", label: "Wallpaper", type: "wallpaper",
          default: "/home/isabel/media/pictures/wallpapers/rn.jpg" },
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
