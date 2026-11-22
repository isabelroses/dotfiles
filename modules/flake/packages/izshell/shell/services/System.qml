pragma Singleton

import QtQuick
import Quickshell
import Izshell
import qs.data

// The system services the shell talks to over D-Bus: logind, the user's systemd
// and AccountsService. Callers say what they want; bus names, object paths and
// type signatures stay here.
Singleton {
  id: root

  // BlueZ is on the system bus
  readonly property bool bluezRunning: bluez.registered

  // "Suspend", "Reboot" or "PowerOff" through logind, interactive so polkit can
  // ask (through PolkitDialog) if it wants to. Suspend locks first and gives the
  // lock screen a moment to come up, so the machine never wakes unlocked.
  function power(action: string): void {
    if (action !== "Suspend") return login1(action);
    Runtime.lock();
    suspendTimer.restart();
  }

  // a unit of the user's systemd; `onlyIfRunning` leaves a stopped one stopped
  function restartUnit(name: string, onlyIfRunning: bool): void {
    DBus.call("session", "org.freedesktop.systemd1", "/org/freedesktop/systemd1", "org.freedesktop.systemd1.Manager",
      onlyIfRunning ? "TryRestartUnit" : "RestartUnit", "ss", [name, "replace"]);
  }

  // a backlight, in its own units (0 to its max_brightness); logind lets the
  // session's user do this without udev rules
  function setBrightness(device: string, value: int): void {
    DBus.call("system", "org.freedesktop.login1", "/org/freedesktop/login1/session/auto",
      "org.freedesktop.login1.Session", "SetBrightness", "ssu", ["backlight", device, value]);
  }

  // the account picture greeters and settings apps show
  function setAccountIcon(path: string): void {
    DBus.call("system", "org.freedesktop.Accounts", "/org/freedesktop/Accounts", "org.freedesktop.Accounts",
      "FindUserByName", "s", [Quickshell.env("USER")], (user, error) => {
        if (error) return console.warn("System: no AccountsService user:", error);
        DBus.call("system", "org.freedesktop.Accounts", user, "org.freedesktop.Accounts.User", "SetIconFile", "s", [path]);
      });
  }

  function login1(method: string): void {
    DBus.call("system", "org.freedesktop.login1", "/org/freedesktop/login1", "org.freedesktop.login1.Manager",
      method, "b", [true]);
  }

  Timer { id: suspendTimer; interval: 500; onTriggered: root.login1("Suspend") }

  DBusWatcher { id: bluez; bus: "system"; service: "org.bluez" }
}
