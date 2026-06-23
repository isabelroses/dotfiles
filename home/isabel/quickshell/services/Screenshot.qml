pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property bool active: false
  property string mode: ""
  property string pendingMode: ""
  property string pendingPath: ""
  property string pendingKind: ""
  property var autoGrab: null

  readonly property string freezeAll: "/tmp/qs-screenshot-freeze-all.png"
  function freezeOut(name: string): string { return "/tmp/qs-screenshot-freeze-" + name + ".png"; }

  // XDG_SCREENSHOTS_DIR is not in quickshell's launch environment (only
  // interactive shells that source ~/.config/user-dirs.dirs export it), so
  // Quickshell.env() can't see it; resolve it by sourcing that file at startup.
  property string dir: Quickshell.env("HOME") + "/Pictures/Screenshots"

  function newPath(): string {
    return root.dir + "/Screenshot_" + Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss") + ".png";
  }

  function shq(s: string): string {
    return "'" + ("" + s).replace(/'/g, "'\\''") + "'";
  }

  function menu(): void { root.openOverlay("picker"); }
  function region(): void { root.openOverlay("region"); }

  function openOverlay(m: string): void {
    // Re-triggering while up would rewrite the freeze temps under the live Image.
    if (root.active || freezeProc.running)
      return;
    root.pendingPath = root.newPath();
    root.pendingMode = m;
    // Freeze before the overlay is shown so the overlay can never be in a capture.
    let parts = [];
    for (const s of Quickshell.screens)
      parts.push("grim -o " + root.shq(s.name) + " " + root.shq(root.freezeOut(s.name)));
    parts.push("grim " + root.shq(root.freezeAll));
    freezeProc.command = ["bash", "-c", parts.join(" & ") + " & wait"];
    freezeProc.running = true;
  }

  Process {
    id: freezeProc
    onExited: (code, status) => {
      root.mode = root.pendingMode;
      root.active = true;
    }
  }

  function regionCaptured(): void {
    const p = root.pendingPath;
    root.active = false;
    root.mode = "";
    root.finalize(p);
  }

  function cancel(): void {
    root.active = false;
    root.mode = "";
    root.pendingPath = "";
    root.pendingKind = "";
    root.autoGrab = null;
  }

  function window(): void { root.startInstant("window"); }
  function output(): void { root.startInstant("output"); }
  function all(): void { root.startInstant("all"); }

  function startInstant(kind: string): void {
    root.pendingKind = kind;
    if (root.pendingPath.length === 0)
      root.pendingPath = root.newPath();
    if (root.active)
      root.captureFromFreeze(kind);
    else
      root.runLive();
  }

  // From the menu: crop/copy the clean freeze instead of grabbing live, so the
  // overlay can't appear in the shot (no teardown race with a live grim).
  function captureFromFreeze(kind: string): void {
    if (kind === "all") {
      root.active = false;
      root.mode = "";
      root.copyThenFinalize(root.freezeAll);
    } else if (kind === "output") {
      outputResolveProc.running = true;
    } else if (kind === "window") {
      windowResolveProc.running = true;
    }
  }

  function copyThenFinalize(src: string): void {
    cpProc.command = ["cp", src, root.pendingPath];
    cpProc.running = true;
  }

  Process {
    id: cpProc
    onExited: (code, status) => {
      if (code === 0) root.finalize(root.pendingPath);
      else root.fail("Could not copy capture");
    }
  }

  Process {
    id: outputResolveProc
    command: ["hyprctl", "monitors", "-j"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const mons = JSON.parse(text);
          const f = mons.find(m => m.focused) ?? mons[0];
          root.active = false;
          root.mode = "";
          root.copyThenFinalize(root.freezeOut(f.name));
        } catch (e) {
          root.fail("Could not determine monitor");
        }
      }
    }
  }

  Process {
    id: windowResolveProc
    command: ["hyprctl", "activewindow", "-j"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const w = JSON.parse(text);
          if (!w || !w.at || !w.size || w.size[0] <= 0) { root.fail("No active window"); return; }
          const cx = w.at[0] + w.size[0] / 2;
          const cy = w.at[1] + w.size[1] / 2;
          let target = Quickshell.screens[0];
          for (const s of Quickshell.screens)
            if (cx >= s.x && cx < s.x + s.width && cy >= s.y && cy < s.y + s.height) { target = s; break; }
          const lx = Math.max(0, w.at[0] - target.x);
          const ly = Math.max(0, w.at[1] - target.y);
          root.autoGrab = {
            output: target.name,
            x: lx,
            y: ly,
            w: Math.min(w.size[0], target.width - lx),
            h: Math.min(w.size[1], target.height - ly)
          };
        } catch (e) {
          root.fail("No active window");
        }
      }
    }
  }

  function runLive(): void {
    if (root.pendingKind === "all") {
      grimProc.command = ["grim", root.pendingPath];
      grimProc.running = true;
    } else if (root.pendingKind === "output") {
      liveMonitorsProc.running = true;
    } else if (root.pendingKind === "window") {
      liveWindowProc.running = true;
    }
  }

  Process {
    id: grimProc
    onExited: (code, status) => {
      if (code === 0) root.finalize(root.pendingPath);
      else root.fail("grim exited with code " + code);
    }
  }

  Process {
    id: liveMonitorsProc
    command: ["hyprctl", "monitors", "-j"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const mons = JSON.parse(text);
          const f = mons.find(m => m.focused) ?? mons[0];
          grimProc.command = ["grim", "-o", f.name, root.pendingPath];
          grimProc.running = true;
        } catch (e) {
          root.fail("Could not determine monitor");
        }
      }
    }
  }

  Process {
    id: liveWindowProc
    command: ["hyprctl", "activewindow", "-j"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const w = JSON.parse(text);
          if (!w || !w.at || !w.size || w.size[0] <= 0) { root.fail("No active window"); return; }
          const geom = w.at[0] + "," + w.at[1] + " " + w.size[0] + "x" + w.size[1];
          grimProc.command = ["grim", "-g", geom, root.pendingPath];
          grimProc.running = true;
        } catch (e) {
          root.fail("No active window");
        }
      }
    }
  }

  function finalize(path: string): void {
    // swappy's -o - writes its annotated result to stdout (-> wl-copy); its own
    // Save button additionally writes to swappy's configured dir.
    swappyProc.command = ["bash", "-c", "swappy -f " + root.shq(path) + " -o - | wl-copy"];
    swappyProc.running = true;
    root.pendingKind = "";
    root.pendingPath = "";
    root.autoGrab = null;
  }

  function fail(msg: string): void {
    root.active = false;
    root.mode = "";
    root.pendingPath = "";
    root.pendingKind = "";
    root.autoGrab = null;
    notifyProc.command = ["notify-send", "Screenshot failed", msg, "-u", "critical"];
    notifyProc.running = true;
  }

  Component.onCompleted: dirProc.running = true

  Process {
    id: dirProc
    command: ["bash", "-c", 'd="${XDG_CONFIG_HOME:-$HOME/.config}/user-dirs.dirs"; [ -f "$d" ] && . "$d"; echo -n "${XDG_SCREENSHOTS_DIR:-$HOME/Pictures/Screenshots}"']
    stdout: StdioCollector {
      onStreamFinished: {
        const d = text.trim();
        if (d.length > 0)
          root.dir = d;
        mkdirProc.command = ["mkdir", "-p", root.dir];
        mkdirProc.running = true;
      }
    }
  }

  Process { id: mkdirProc }
  Process { id: notifyProc }
  Process { id: swappyProc }

  IpcHandler {
    target: "screenshot"
    function menu(): void { root.menu(); }
    function region(): void { root.region(); }
    function window(): void { root.window(); }
    function output(): void { root.output(); }
    function all(): void { root.all(); }
  }

  reloadableId: "screenshot"
}
