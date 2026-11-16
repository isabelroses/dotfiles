pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking as Net

Singleton {
  id: root

  property bool quickSettingsOpen: false
  // notifications live in the quick settings sheet
  readonly property bool notificationsOpen: quickSettingsOpen
  property bool settingsOpen: false
  property bool powerMenuOpen: false
  property bool keepAwake: false
  property bool locked: lockState.text().trim() === "1"
  onLockedChanged: lockState.setText(locked ? "1" : "0")

  FileView {
    id: lockState
    path: Quickshell.statePath("locked")
    blockLoading: true
    blockWrites: true
    printErrors: false
  }

  Binding {
    target: Quickshell
    property: "watchFiles"
    value: !root.locked
  }

  function lock(): void {
    closePanels();
    powerMenuOpen = false;
    settingsOpen = false;
    locked = true;
  }

  function openPowerMenu(): void {
    closePanels();
    powerMenuOpen = true;
  }

  function toggleQuickSettings(): void {
    quickSettingsOpen = !quickSettingsOpen;
  }

  function toggleNotifications(): void {
    toggleQuickSettings();
  }

  function closePanels(): void {
    quickSettingsOpen = false;
  }

  function openSettings(): void {
    closePanels();
    settingsOpen = true;
  }

  property Net.WifiNetwork wifiPasswordTarget: null
  property string wifiPasswordError: ""

  function openWifiPassword(net: Net.WifiNetwork): void {
    wifiPasswordError = "";
    wifiPasswordTarget = net;
  }

  function closeWifiPassword(): void {
    wifiPasswordTarget = null;
    wifiPasswordError = "";
  }

  IpcHandler {
    target: "shell"

    function quickSettings(): void { root.toggleQuickSettings(); }
    function notifications(): void { root.toggleNotifications(); }
    function keepAwake(): string {
      root.keepAwake = !root.keepAwake;
      return root.keepAwake ? "on" : "off";
    }
    function lock(): void { root.lock(); }
    function powerMenu(): void {
      if (root.powerMenuOpen) root.powerMenuOpen = false;
      else root.openPowerMenu();
    }
    function settings(): void {
      if (root.settingsOpen) root.settingsOpen = false;
      else root.openSettings();
    }
    function dnd(): string {
      const on = !Config.get("notifications.dnd");
      Config.set("notifications.dnd", on);
      return on ? "on" : "off";
    }
    function set(path: string, value: string): string {
      const e = Config.entry(path);
      if (!e) return `unknown setting ${path}`;
      let raw = value;
      if (value === "true" || value === "false") raw = value === "true";
      else if (value !== "" && !isNaN(Number(value))) raw = Number(value);
      const v = Config.coerce(e, raw);
      if (v === undefined) return `${path} should be ${Config.expected(e)}`;
      Config.set(path, v);
      return "ok";
    }
    function get(path: string): string {
      return JSON.stringify(Config.get(path));
    }
  }
}
