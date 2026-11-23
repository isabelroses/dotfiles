pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking as Net

Singleton {
  id: root

  property bool quickSettingsOpen: false
  // detail card to stack on the quick settings sheet ("network", "bluetooth",
  // "output", "audio", "input"), or ""
  property string quickPanel: ""
  onQuickSettingsOpenChanged: if (!quickSettingsOpen) quickPanel = ""
  property bool calendarOpen: false
  // when the calendar last closed; a click on the clock that also dismissed
  // it must not reopen it straight away
  property real calendarClosedAt: 0
  property bool settingsOpen: false
  property bool powerMenuOpen: false
  property bool cheatsheetOpen: false
  property bool keepAwake: false
  // The lock outlives a shell restart (a crash mid-lock must come back locked),
  // but not the compositor: the file holds the Hyprland instance that was
  // locked, so a fresh login never inherits a lock from a session that ended
  // locked (reboot/shutdown from the lock screen).
  readonly property string lockKey: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") || "1"
  property bool locked: lockState.text().trim() === lockKey
  onLockedChanged: lockState.setText(locked ? lockKey : "")

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
    cheatsheetOpen = false;
    locked = true;
  }

  // action the power menu opens with selected ("lock", "reboot", ...), or "" for the first
  property string powerMenuAction: ""

  function openPowerMenu(action: string): void {
    powerMenuAction = action;
    closePanels();
    powerMenuOpen = true;
  }

  function toggleCalendar(): void {
    if (!calendarOpen && Date.now() - calendarClosedAt < 300) return;
    const open = !calendarOpen;
    closePanels();
    calendarOpen = open;
  }

  function toggleQuickSettings(): void {
    calendarOpen = false;
    quickSettingsOpen = !quickSettingsOpen;
  }

  function toggleNotifications(): void {
    toggleQuickSettings();
  }

  function closePanels(): void {
    quickPanel = "";
    quickSettingsOpen = false;
    calendarOpen = false;
  }

  // page the settings window opens on: "home", "system" or a config section
  property string settingsPage: "home"

  function openSettings(page: string): void {
    settingsPage = page || "home";
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
    function calendar(): void { root.toggleCalendar(); }
    function panel(name: string): void {
      root.quickSettingsOpen = true;
      root.quickPanel = name;
    }
    function notifications(): void { root.toggleNotifications(); }
    function keepAwake(): string {
      root.keepAwake = !root.keepAwake;
      return root.keepAwake ? "on" : "off";
    }
    function lock(): void { root.lock(); }
    function cheatsheet(): void { root.cheatsheetOpen = !root.cheatsheetOpen; }
    function powerMenu(): void {
      if (root.powerMenuOpen) root.powerMenuOpen = false;
      else root.openPowerMenu("");
    }
    function settingsPage(page: string): void { root.openSettings(page); }
    function settings(): void {
      if (root.settingsOpen) root.settingsOpen = false;
      else root.openSettings("home");
    }
    function dnd(): string {
      const on = !Settings.notifications.dnd;
      Settings.set("notifications.dnd", on);
      return on ? "on" : "off";
    }
    function set(path: string, value: string): string { return Settings.setFromText(path, value); }
    function get(path: string): string { return Settings.getAsText(path); }
  }
}
