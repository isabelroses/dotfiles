pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "Schema.js" as Schema

// The user's Settings, stored in settings.toml. Read one by name
// (`Settings.osd.volume`); a name that isn't a Setting warns. What a Setting is,
// and every rule about checking and converting one, lives in Schema.js.
Singleton {
  id: root

  // settings are edited at runtime, so they live outside the (read-only) shell
  readonly property string configHome: Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config"
  readonly property string path: Quickshell.env("IZSHELL_SETTINGS")
    || `${configHome}/izshell/settings.toml`

  // the settings window and bar are built from these
  readonly property var schema: Schema.schema
  readonly property var pageGroups: Schema.pageGroups()
  readonly property var itemNames: Schema.itemNames

  property var values: Schema.defaults()
  property string error: ""
  property bool loaded: false

  readonly property var _tree: Schema.accessors(path => root.values[path])
  readonly property var general: _tree.general
  readonly property var appearance: _tree.appearance
  readonly property var bar: _tree.bar
  readonly property var notifications: _tree.notifications
  readonly property var lock: _tree.lock
  readonly property var osd: _tree.osd
  readonly property var screenshot: _tree.screenshot

  // unset uses the account picture
  readonly property string profilePicture: general.profile_picture || `/var/lib/AccountsService/icons/${general.username}`

  function blurb(page: string): string { return Schema.blurb(page); }
  function barCards(items: var): var { return Schema.barCards(items); }
  function entry(path: string): var { return Schema.entry(path); }

  // by path, for the settings window and IPC
  function get(path: string): var {
    return values[path];
  }

  function set(path: string, value: var): void {
    values = Schema.applySet(values, path, value);
    saveTimer.restart();
  }

  function reset(path: string): void {
    set(path, entry(path).default);
  }

  function resetAll(): void {
    values = Schema.defaults();
    saveTimer.restart();
  }

  // `ipc call shell set`: "ok", or what was wrong
  function setFromText(path: string, text: string): string {
    const r = Schema.fromText(path, text);
    if (!r.ok) return r.error;
    set(path, r.value);
    return "ok";
  }

  function getAsText(path: string): string {
    return Schema.toText(values[path]);
  }

  function applyText(text: string): void {
    const r = Schema.parse(text);
    error = r.error;
    if (r.values === null) {
      console.warn(error);
      return;
    }
    values = r.values;
    loaded = true;
  }

  Timer {
    id: saveTimer
    interval: 400
    onTriggered: {
      file.setText(Schema.serialize(root.values));
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
        setText(Schema.serialize(root.values));
      } else {
        root.error = `Couldn't read settings.toml (${FileViewError.toString(err)})`;
      }
    }
  }
}
