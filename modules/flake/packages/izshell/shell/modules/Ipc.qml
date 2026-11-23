import Quickshell
import Quickshell.Io
import qs.data
import qs.services

// `izshell ipc call <target> <method>`: the shell's command surface for the
// Hyprland binds and scripts. Each method is one call into the module that owns
// the behaviour; the names are what config.lua uses, so they don't change.
Scope {
  IpcHandler {
    target: "screenshot"

    function menu(): void { Screenshot.request("menu"); }
    function region(): void { Screenshot.request("region"); }
    function window(): void { Screenshot.request("window"); }
    function output(): void { Screenshot.request("output"); }
    function all(): void { Screenshot.request("all"); }
    function text(): void { Screenshot.request("text"); }
  }

  IpcHandler {
    target: "brightness"

    function up(): void { Brightness.adjust(0.05); }
    function down(): void { Brightness.adjust(-0.05); }
    function get(): string { return Brightness.available ? `${Math.round(Brightness.brightness * 100)}%` : "unavailable"; }
  }

  IpcHandler {
    target: "notifications"

    function clear(): void { Notifications.dismissAll(); }
    // notify-send for scripts, minus the D-Bus round trip
    function send(summary: string, body: string): void { Notifications.notify({ summary: summary, body: body }); }
    function clearHistory(): void { Notifications.clearHistory(); }
  }

  IpcHandler {
    target: "shell"

    function quickSettings(): void { Surfaces.toggle("quickSettings"); }
    function calendar(): void { Surfaces.toggle("calendar"); }
    function panel(name: string): void { Surfaces.openCard(name); }
    function notifications(): void { Surfaces.toggle("quickSettings"); }
    function keepAwake(): string {
      Session.keepAwake = !Session.keepAwake;
      return Session.keepAwake ? "on" : "off";
    }
    function lock(): void { Session.lock(); }
    function cheatsheet(): void { Surfaces.toggle("cheatsheet"); }
    function powerMenu(): void {
      if (Surfaces.powerMenuOpen) Surfaces.close("powerMenu");
      else Surfaces.openPowerMenu("");
    }
    function settingsPage(page: string): void { Surfaces.openSettings(page); }
    function settings(): void {
      if (Surfaces.settingsOpen) Surfaces.close("settings");
      else Surfaces.openSettings("home");
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
