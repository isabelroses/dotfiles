pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Notifications
import QtQuick
import qs.data
import Izshell

// Screenshot state. Capturing is all screencopy inside the shell:
// ScreenshotOverlay freezes every screen for the picker/region modes,
// ScreenshotGrabber takes direct shots without showing anything, and
// ScreenshotEditor annotates when `edit` is set. The clipboard and file
// handling are the Izshell plugin's; only tesseract runs outside the shell.
Singleton {
  id: root

  // overlay shown (frozen screens, picker or region selection)
  property bool active: false
  property string mode: ""
  // overlays are capturing their screens; the overlay shows once all have a frame
  property bool freezing: false
  property int frozenScreens: 0
  property string pendingPath: ""
  // crop request for one overlay's freeze: { output, x, y, w, h } in logical px
  property var autoGrab: null
  // direct capture for ScreenshotGrabber: { kind: "output" | "all" | "window", screen }
  property var job: null
  // capture waiting in the editor, or ""
  property string editing: ""
  // open the capture in the editor rather than copying it straight away; the picker can flip it per shot
  property bool edit: false
  // copy the text in the region (tesseract) rather than the image
  property bool ocr: false
  readonly property bool alwaysEdit: Config.get("screenshot.editor") === "always"

  readonly property string home: Quickshell.env("HOME")
  // XDG_SCREENSHOTS_DIR is not in quickshell's launch environment (only
  // interactive shells source user-dirs.dirs), so read it from the file
  readonly property string xdgDir: {
    const m = userDirs.text().match(/^XDG_SCREENSHOTS_DIR="(.*)"/m);
    return m ? m[1].replace(/^\$HOME/, home) : home + "/Pictures/Screenshots";
  }
  readonly property string dir: Config.get("screenshot.folder").replace(/^~/, home) || xdgDir
  onDirChanged: Files.mkdir(dir)
  Component.onCompleted: Files.mkdir(dir)

  FileView {
    id: userDirs
    path: Config.configHome + "/user-dirs.dirs"
    blockLoading: true
    printErrors: false
  }

  readonly property bool busy: active || freezing || job !== null || editing !== ""

  function newPath(): string {
    // unsaved captures still need a file for the editor or tesseract to read
    const folder = Config.get("screenshot.save") && !root.ocr ? root.dir : (Quickshell.env("XDG_RUNTIME_DIR") || "/tmp");
    return folder + "/Screenshot_" + Qt.formatDateTime(new Date(), "yyyy-MM-dd_HH-mm-ss") + ".png";
  }

  function focusedScreen(): var {
    const name = Hyprland.focusedMonitor?.name;
    return Quickshell.screens.find(s => s.name === name) ?? Quickshell.screens[0];
  }

  // a region whose text is copied instead of its image; from the picker too
  function text(): void {
    if (root.busy && !root.active) return;
    root.ocr = true;
    if (!root.active) return root.openOverlay("region");
    root.pendingPath = root.newPath();
    root.mode = "region";
  }

  function openOverlay(m: string): void {
    if (root.busy) return;
    // region mode snaps to windows: have their positions current as of the freeze
    Hyprland.refreshToplevels();
    root.pendingPath = root.newPath();
    root.mode = m;
    root.frozenScreens = 0;
    // the overlays capture while still hidden, so they can never be in the shot
    root.freezing = true;
    freezeTimeout.restart();
  }

  // an overlay has its screen's frame
  function screenFrozen(): void {
    if (!root.freezing || ++root.frozenScreens < Quickshell.screens.length) return;
    freezeTimeout.stop();
    root.active = true;
    root.freezing = false;
  }

  Timer {
    id: freezeTimeout
    interval: 2000
    onTriggered: root.fail("Could not capture the screen")
  }

  function capture(kind: string): void {
    if (!root.active) {
      if (root.busy) return;
      root.pendingPath = root.newPath();
      root.job = { kind: kind, screen: root.focusedScreen() };
      return;
    }
    if (kind === "output") {
      // crop the clean freeze: the overlay is up, so a live grab would include it
      const s = root.focusedScreen();
      root.autoGrab = { output: s.name, x: 0, y: 0, w: s.width, h: s.height };
      return;
    }
    root.active = false;
    root.mode = "";
    if (kind === "window") {
      // a window is captured from its own buffer, so the overlay never shows up in it
      root.job = { kind: "window" };
    } else {
      // no freeze spans every screen, so wait for the overlay to unmap and grab live
      allSettleTimer.restart();
    }
  }

  Timer {
    id: allSettleTimer
    interval: 120
    onTriggered: root.job = { kind: "all" }
  }

  // the overlay's and grabber's last step: write a grab of `item` to pendingPath
  function saveGrab(item: Item, size: size): void {
    item.grabToImage(result => {
      if (result?.saveToFile(root.pendingPath)) root.captured();
      else root.fail("Failed to save capture");
      // a grab holds a full-resolution image until it is collected; captures
      // are rare, so collect now rather than leave tens of MB to linger
      Qt.callLater(gc);
    }, size);
  }

  function captured(): void {
    const p = root.pendingPath;
    const edit = root.edit;
    const ocr = root.ocr;
    root.cancel();
    if (ocr) root.recognise(p);
    else if (edit) root.editing = p;
    else root.deliver(p);
  }

  function cancel(): void {
    root.active = false;
    root.freezing = false;
    root.mode = "";
    root.pendingPath = "";
    root.autoGrab = null;
    root.job = null;
    root.edit = false;
    root.ocr = false;
  }

  function recognise(path: string): void {
    tesseract.path = path;
    tesseract.sparse = false;
    tesseract.command = ["tesseract", path, "-", "-l", "eng"];
    tesseract.running = true;
  }

  Process {
    id: tesseract
    property string path
    // the default layout analysis reads blocks of text; scattered labels need the
    // sparse mode, which jumbles blocks a little, so it is only the fallback
    property bool sparse
    stdout: StdioCollector { id: ocrText }
    onExited: {
      const found = ocrText.text.trim();
      if (found === "" && !sparse) {
        sparse = true;
        command = ["tesseract", path, "-", "-l", "eng", "--psm", "11"];
        return running = true;
      }
      Files.remove(path);
      if (found !== "") Clipboard.setText(found);
      if (!Config.get("screenshot.notify") && found !== "") return;
      Notifications.notify({
        appName: "Screenshot", appIcon: "insert-text",
        summary: found !== "" ? "Text copied" : "No text found",
        body: found.length > 160 ? found.slice(0, 160) + "…" : found,
      });
    }
  }

  // Copy to the clipboard and notify. An unsaved capture's temp file lives as
  // long as its notification, so the thumbnail and the Edit action keep working.
  function deliver(path: string): void {
    const saved = Config.get("screenshot.save");
    const notify = Config.get("screenshot.notify");
    // the clipboard keeps its own copy, so the file is free to go once this returns
    if (!Clipboard.setImage(path)) return root.fail("Could not copy the capture");
    if (!saved && !notify) Files.remove(path);
    if (!notify) return;

    let editing = false;
    const n = Notifications.notify({
      appName: "Screenshot",
      appIcon: "camera-photo",
      image: "file://" + path,
      summary: "Screenshot copied",
      body: saved ? "Saved as " + path.replace(/^.*\//, "") : "Not saved to disk",
      actions: [{
        identifier: "edit",
        text: "Edit",
        invoke: () => {
          if (root.busy) return;
          editing = true;
          root.editing = path;
          n.dismiss();
        },
      }],
    }, () => {
      if (!saved && !editing) Files.remove(path);
    });
  }

  // the editor closed: `copy` means it wrote its result over the capture
  function editorClosed(copy: bool): void {
    const p = root.editing;
    root.editing = "";
    if (copy) root.deliver(p);
    else if (!Config.get("screenshot.save")) Files.remove(p);
  }

  function fail(msg: string): void {
    root.cancel();
    Notifications.notify({ appName: "Screenshot", appIcon: "camera-photo", summary: "Screenshot failed", body: msg,
      urgency: NotificationUrgency.Critical });
  }

  // the picker opens the editor unless screenshot.editor says never; direct
  // captures only when it says always. The picker's buttons call
  // capture() and text() directly, so the flag survives them
  function startFromIpc(edit: bool, action: var): void {
    if (!root.busy) root.edit = edit;
    action();
  }

  IpcHandler {
    target: "screenshot"

    function menu(): void { root.startFromIpc(Config.get("screenshot.editor") !== "never", () => root.openOverlay("picker")); }
    function region(): void { root.startFromIpc(root.alwaysEdit, () => root.openOverlay("region")); }
    function window(): void { root.startFromIpc(root.alwaysEdit, () => root.capture("window")); }
    function output(): void { root.startFromIpc(root.alwaysEdit, () => root.capture("output")); }
    function all(): void { root.startFromIpc(root.alwaysEdit, () => root.capture("all")); }
    function text(): void { root.text(); }
  }

  reloadableId: "screenshot"
}
