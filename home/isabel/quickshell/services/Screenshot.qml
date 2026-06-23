pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

// Screenshot tool with screen freezing during region selection.
//
// Entry points (also exposed over IPC as `qs ipc call screenshot <fn>`):
//   menu()    - freeze + macOS-style mode picker toolbar
//   region()  - freeze + drag-select a region
//   window()  - active window (instant grim)
//   output()  - focused monitor (instant grim)
//   all()     - whole layout (instant grim)
//
// The ScreenshotOverlay module renders the frozen overlay/picker and performs
// the region crop, then calls back into regionCaptured(). Window/output/all are
// instant single-snapshot grim calls (no freeze needed - a snapshot is already
// a frozen instant).
Singleton {
  id: root

  // Overlay state, read by ScreenshotOverlay.
  property bool active: false        // overlay shown
  property string mode: ""           // "picker" | "region" | ""
  property string pendingPath: ""    // target file for the current capture
  property string pendingKind: ""    // "window" | "output" | "all" for instant modes

  // Screenshots directory. XDG_SCREENSHOTS_DIR is not in quickshell's launch
  // environment (it's only exported into interactive shells that source
  // ~/.config/user-dirs.dirs), so Quickshell.env() can't see it. Resolve it at
  // startup by sourcing user-dirs.dirs directly. Falls back to ~/Pictures/Screenshots.
  property string dir: Quickshell.env("HOME") + "/Pictures/Screenshots"

  function newPath(): string {
    return root.dir + "/Screenshot_" + Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss") + ".png";
  }

  function shq(s: string): string {
    return "'" + ("" + s).replace(/'/g, "'\\''") + "'";
  }

  // --- Entry points -------------------------------------------------------

  function menu(): void {
    root.pendingPath = root.newPath();
    root.mode = "picker";
    root.active = true;
  }

  function region(): void {
    root.pendingPath = root.newPath();
    root.mode = "region";
    root.active = true;
  }

  function window(): void { root.startInstant("window"); }
  function output(): void { root.startInstant("output"); }
  function all(): void { root.startInstant("all"); }

  // --- Region (called back from the overlay after grabToImage) -----------

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
  }

  // --- Instant grim modes ------------------------------------------------

  function startInstant(kind: string): void {
    root.pendingKind = kind;
    if (root.pendingPath.length === 0)
      root.pendingPath = root.newPath();
    if (root.active) {
      // Came from the picker: drop the overlay first so it isn't in the shot,
      // then capture once it has cleared.
      root.active = false;
      root.mode = "";
      teardownTimer.restart();
    } else {
      root.runInstant();
    }
  }

  function runInstant(): void {
    if (root.pendingKind === "all") {
      grimProc.command = ["grim", root.pendingPath];
      grimProc.running = true;
    } else if (root.pendingKind === "output") {
      monitorsProc.running = true;
    } else if (root.pendingKind === "window") {
      activeWinProc.running = true;
    }
  }

  Timer {
    id: teardownTimer
    interval: 90
    onTriggered: root.runInstant()
  }

  // --- Shared finish: save notification + swappy annotate -> clipboard ----

  function finalize(path: string): void {
    notifyProc.command = ["notify-send", "Screenshot saved", path, "-i", path];
    notifyProc.running = true;

    // swappy reads the raw capture, writes its annotated result to stdout
    // (-> wl-copy), and its own Save button writes to swappy's configured dir.
    swappyProc.command = ["bash", "-c", "swappy -f " + root.shq(path) + " -o - | wl-copy"];
    swappyProc.running = true;

    root.pendingKind = "";
    root.pendingPath = "";
  }

  function fail(msg: string): void {
    root.active = false;
    root.mode = "";
    root.pendingPath = "";
    root.pendingKind = "";
    notifyProc.command = ["notify-send", "Screenshot failed", msg, "-u", "critical"];
    notifyProc.running = true;
  }

  // --- Processes ----------------------------------------------------------

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

  Process {
    id: grimProc
    onExited: (code, status) => {
      if (code === 0)
        root.finalize(root.pendingPath);
      else
        root.fail("grim exited with code " + code);
    }
  }

  Process {
    id: monitorsProc
    command: ["hyprctl", "monitors", "-j"]
    stdout: StdioCollector {
      onStreamFinished: {
        try {
          const mons = JSON.parse(text);
          const focused = mons.find(m => m.focused) ?? mons[0];
          if (!focused) { root.fail("No monitor found"); return; }
          grimProc.command = ["grim", "-o", focused.name, root.pendingPath];
          grimProc.running = true;
        } catch (e) {
          root.fail("Could not parse monitors");
        }
      }
    }
  }

  Process {
    id: activeWinProc
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
