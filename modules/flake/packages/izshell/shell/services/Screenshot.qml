pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick
import qs.data
import Izshell
import "Capture.js" as Capture

// Screenshots. Capturing is all screencopy inside the shell: ScreenshotOverlay
// freezes every screen for the picker/region modes, ScreenshotGrabber takes
// direct shots without showing anything, and ScreenshotEditor annotates. The
// clipboard and file handling are the Izshell plugin's; only tesseract runs
// outside the shell.
//
// What happens when is Capture.js's: this holds its state, feeds it events (the
// windows call the intents below) and carries out the effects it asks for. The
// windows only read `phase` and the requests below, and say what happened.
Singleton {
  id: root

  property var _state: Capture.initial()

  // "idle", "freezing", "picking", "region", "settling", "grabbing",
  // "recognising" or "editing" (see Capture.js)
  readonly property string phase: _state.phase
  readonly property bool busy: Capture.busy(_state)
  // the overlay is up: the picker, or choosing a region
  readonly property bool active: Capture.overlayShown(_state)
  // overlays are capturing their screens; the overlay shows once all have a frame
  readonly property bool freezing: phase === "freezing"
  // open the capture in the editor rather than copying it straight away; the picker can flip it per shot
  readonly property bool edit: _state.edit
  // crop request for the overlay of one output's freeze: { output, x, y, w, h } in logical px
  readonly property var crop: _state.crop
  // direct capture for ScreenshotGrabber: { kind: "output" | "all" | "window", screen? (output name) }
  readonly property var job: _state.job
  // the capture open in the editor, or ""
  readonly property string editing: _state.editing

  readonly property string home: Quickshell.env("HOME")
  // XDG_SCREENSHOTS_DIR is not in quickshell's launch environment (only
  // interactive shells source user-dirs.dirs), so read it from the file
  readonly property string xdgDir: {
    const m = userDirs.text().match(/^XDG_SCREENSHOTS_DIR="(.*)"/m);
    return m ? m[1].replace(/^\$HOME/, home) : home + "/Pictures/Screenshots";
  }
  readonly property string dir: Settings.screenshot.folder.replace(/^~/, home) || xdgDir
  onDirChanged: Files.mkdir(dir)
  Component.onCompleted: Files.mkdir(dir)

  FileView {
    id: userDirs
    path: Settings.configHome + "/user-dirs.dirs"
    blockLoading: true
    printErrors: false
  }

  function focusedScreen(): var {
    const name = Hyprland.focusedMonitor?.name;
    return Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0];
  }

  // ---- what the windows and the shell's commands say

  // "menu" (the picker), "region", "window", "output", "all" or "text"
  function request(kind: string): void { dispatch({ type: "request", kind }); }

  // a picker button or key: "region", "text", "window", "output" or "all"
  function choose(key: string): void { dispatch({ type: "choose", key }); }

  function toggleEdit(): void { dispatch({ type: "toggleEdit" }); }
  function cancel(): void { dispatch({ type: "cancel" }); }

  // an overlay has its screen's frame
  function screenFrozen(): void { dispatch({ type: "screenFrozen" }); }

  // the overlay's and grabber's last step: `item` holds the capture; write it out
  function grabbed(item: Item, size: size): void {
    item.grabToImage(result => {
      if (result?.saveToFile(root._state.path)) root.dispatch({ type: "grabbed" });
      else root.dispatch({ type: "grabFailed", message: "Failed to save capture" });
      // a grab holds a full-resolution image until it is collected; captures
      // are rare, so collect now rather than leave tens of MB to linger
      Qt.callLater(gc);
    }, size);
  }

  // the editor closed: `copy` means it wrote its result over the capture
  function editorClosed(copy: bool): void { dispatch({ type: "editorClosed", copy }); }

  function fail(message: string): void { dispatch({ type: "fail", message }); }

  // ---- the adapter: Capture.js's events in, its effects out

  property var _queue: []
  property bool _running: false

  function dispatch(event: var): void {
    _queue.push(event);
    if (_running) return;
    _running = true;
    while (_queue.length > 0) {
      const r = Capture.step(_state, _queue.shift(), config());
      _state = r.state;
      for (const effect of r.effects) perform(effect);
    }
    _running = false;
  }

  function config(): var {
    const focused = focusedScreen();
    return {
      save: Settings.screenshot.save,
      notify: Settings.screenshot.notify,
      editor: Settings.screenshot.editor,
      dir: root.dir,
      tmpDir: Quickshell.env("XDG_RUNTIME_DIR") || "/tmp",
      stamp: Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss"),
      screenCount: Quickshell.screens.length,
      focused: { name: focused.name, width: focused.width, height: focused.height },
    };
  }

  function perform(effect: var): void {
    switch (effect.type) {
    case "refreshToplevels":
      // region mode snaps to windows: have their positions current as of the freeze
      Hyprland.refreshToplevels();
      break;
    case "startTimer":
      timer(effect.name).interval = effect.ms;
      timer(effect.name).restart();
      break;
    case "stopTimer":
      timer(effect.name).stop();
      break;
    case "copyImage":
      dispatch({ type: "copied", ok: Clipboard.setImage(effect.path), path: effect.path });
      break;
    case "copyText":
      Clipboard.setText(effect.text);
      break;
    case "runTesseract":
      tesseract.path = effect.path;
      // the default layout analysis reads blocks of text; scattered labels need
      // the sparse mode, which jumbles blocks a little, so it is only the fallback
      tesseract.command = ["tesseract", effect.path, "-", "-l", "eng", ...(effect.sparse ? ["--psm", "11"] : [])];
      tesseract.running = true;
      break;
    case "notify":
      announce(effect);
      break;
    case "closeNotification":
      shots[effect.path]?.dismiss();
      break;
    case "stopTesseract":
      tesseract.running = false;
      break;
    case "removeFile":
      Files.remove(effect.path);
      break;
    }
  }

  function timer(name: string): Timer {
    return name === "freeze" ? freezeTimeout : name === "ocr" ? ocrTimer : settleTimer;
  }

  Timer {
    id: freezeTimeout
    onTriggered: root.dispatch({ type: "freezeTimeout" })
  }

  Timer {
    id: settleTimer
    onTriggered: root.dispatch({ type: "settled" })
  }

  Timer {
    id: ocrTimer
    onTriggered: root.dispatch({ type: "ocrTimeout" })
  }

  Process {
    id: tesseract
    property string path
    stdout: StdioCollector { id: ocrText }
    onExited: root.dispatch({ type: "ocrFinished", text: ocrText.text })
  }

  // the "copied" notifications still up, by capture file: each holds its file
  // until it closes, so its thumbnail and Edit action keep working
  readonly property var shots: ({})

  function announce(effect: var): void {
    if (effect.kind === "failed") {
      Notifications.notify({ appName: "Screenshot", appIcon: "camera-photo", summary: "Screenshot failed", body: effect.message,
        urgency: NotificationUrgency.Critical });
    } else if (effect.kind === "ocr") {
      const found = effect.found;
      Notifications.notify({
        appName: "Screenshot", appIcon: "insert-text",
        summary: found !== "" ? "Text copied" : "No text found",
        body: found.length > 160 ? found.slice(0, 160) + "…" : found,
      });
    } else {
      const path = effect.path;
      shots[path] = Notifications.notify({
        appName: "Screenshot",
        appIcon: "camera-photo",
        image: "file://" + path,
        summary: "Screenshot copied",
        body: effect.saved ? "Saved as " + path.replace(/^.*\//, "") : "Not saved to disk",
        actions: [{ identifier: "edit", text: "Edit", invoke: () => root.dispatch({ type: "editRequested", path }) }],
      }, () => {
        delete root.shots[path];
        root.dispatch({ type: "released", path });
      });
    }
  }

  reloadableId: "screenshot"
}
