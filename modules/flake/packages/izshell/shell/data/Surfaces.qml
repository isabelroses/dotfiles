pragma Singleton

import QtQuick
import Quickshell
import "Surfaces.js" as Rules

// Which Surfaces are open. Callers ask to open, close or toggle one by id
// ("quickSettings", "calendar", "settings", "powerMenu", "cheatsheet",
// "wifiPassword") and read the outputs below; which ones exclude each other, the
// order escape peels them off in and the reopen guard are Surfaces.js's.
Singleton {
  id: root

  property var _state: Rules.initial()

  readonly property bool quickSettingsOpen: Rules.isOpen(_state, "quickSettings")
  readonly property bool calendarOpen: Rules.isOpen(_state, "calendar")
  readonly property bool settingsOpen: _state.settings
  readonly property bool powerMenuOpen: _state.powerMenu
  readonly property bool cheatsheetOpen: _state.cheatsheet
  readonly property bool wifiPasswordOpen: _state.wifiPassword
  // detail card stacked on the quick settings sheet, or ""
  readonly property string quickPanel: _state.card

  // page the settings window opens on: "home", a custom page or a Settings section
  property string settingsPage: "home"
  // action the power menu opens with selected ("lock", "reboot", ...), or "" for the first
  property string powerMenuAction: ""

  function isOpen(id: string): bool { return Rules.isOpen(_state, id); }
  function open(id: string): void { _state = Rules.open(_state, id); }
  function close(id: string): void { _state = Rules.close(_state, id); }
  function toggle(id: string): void { _state = Rules.toggle(_state, id, Date.now()); }

  // a popup that closed because focus went elsewhere; a click that also
  // dismissed it won't reopen it straight away
  function dismissedByFocusLoss(id: string): void { _state = Rules.dismissedByFocusLoss(_state, id, Date.now()); }

  // escape: the top layer comes off first (prompt, then detail card, then sheet)
  function dismiss(): void { _state = Rules.dismiss(_state); }
  function closePopups(): void { _state = Rules.closePopups(_state); }
  // before the lock covers the screen
  function closeAll(): void { _state = Rules.closeAll(_state); }

  function setCard(name: string): void { _state = Rules.setCard(_state, name); }
  function toggleCard(name: string): void { _state = Rules.toggleCard(_state, name); }
  // the sheet, open on a detail card
  function openCard(name: string): void { _state = Rules.setCard(Rules.open(_state, "quickSettings"), name); }

  function openSettings(page: string): void {
    settingsPage = page || "home";
    open("settings");
  }

  function openPowerMenu(action: string): void {
    powerMenuAction = action;
    open("powerMenu");
  }
}
