import QtQuick
import Quickshell
import Quickshell.Io
import qs.data

// Keeps the vicinae launcher's corners in step with the shell. vicinae's
// declarative settings import ~/.config/vicinae/quickshell.json (see
// home/isabel/vicinae); this writes the launcher radius there, matching the
// floating sheet, and restarts vicinae when the value really changes.
Scope {
  id: root

  readonly property int radius: Settings.sheetRadius
  readonly property string wanted: JSON.stringify({ launcher_window: { rounding: radius } }, null, 2) + "\n"

  FileView {
    id: file
    path: Quickshell.env("HOME") + "/.config/vicinae/quickshell.json"
    printErrors: false
    onLoaded: debounce.restart()
    onLoadFailed: debounce.restart()
  }

  // wait for the rounding slider to settle before touching vicinae
  onWantedChanged: debounce.restart()
  Timer {
    id: debounce
    interval: 1500
    onTriggered: {
      if (file.text() === root.wanted) return;
      file.setText(root.wanted);
      Quickshell.execDetached(["systemctl", "--user", "try-restart", "vicinae.service"]);
    }
  }
}
