import Quickshell
import Quickshell.Io
import qs.data

// `izshell ipc call shell <method>`: the shell's command surface for the
// Hyprland binds and scripts. Each method is one call into the module that owns
// the behaviour; the names are what config.lua uses, so they don't change.
Scope {
  IpcHandler {
    target: "shell"

    function quickSettings(): void { Surfaces.toggle("quickSettings"); }
    function calendar(): void { Surfaces.toggle("calendar"); }
    function panel(name: string): void { Surfaces.openCard(name); }
    function notifications(): void { Surfaces.toggle("quickSettings"); }
    function keepAwake(): string {
      Runtime.keepAwake = !Runtime.keepAwake;
      return Runtime.keepAwake ? "on" : "off";
    }
    function lock(): void { Runtime.lock(); }
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
