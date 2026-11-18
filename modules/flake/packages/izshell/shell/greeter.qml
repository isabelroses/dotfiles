//@ pragma IconTheme Adwaita

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Greetd
import qs.data
import qs.components

// greetd greeter: run as `quickshell -p greeter.qml` inside a bare compositor.
// The prompt sits on the focused monitor; the rest stay black. Sessions come
// from the .desktop files in $GREETER_SESSIONS (colon-separated dirs); Tab or
// clicking the session name cycles them.
Scope {
  id: root

  property string buffer: ""
  property string message: ""
  property bool failed: false
  readonly property bool busy: Greetd.state !== GreetdState.Inactive

  property var sessions: []
  property int sessionIndex: 0
  readonly property var session: sessions[sessionIndex] ?? null

  function submit(): void {
    if (busy || session === null) return;
    message = "";
    failed = false;
    Greetd.createSession(Settings.username);
  }

  function fail(text: string): void {
    buffer = "";
    failed = true;
    message = text;
    if (Greetd.state !== GreetdState.Inactive) Greetd.cancelSession();
  }

  Connections {
    target: Greetd

    function onAuthMessage(message: string, error: bool, responseRequired: bool, echoResponse: bool) {
      if (responseRequired) Greetd.respond(root.buffer);
      else if (error) root.message = message;
    }

    function onAuthFailure(message: string) { root.fail("Wrong password"); }
    function onError(error: string) { root.fail(error); }

    function onReadyToLaunch() {
      root.message = `Starting ${root.session.name}…`;
      Greetd.launch(root.session.exec.split(/\s+/), [], true);
    }
  }

  // one "Name<TAB>Exec" line per session
  Process {
    running: true
    command: ["sh", "-c", `
      IFS=:
      for d in $GREETER_SESSIONS; do
        for f in "$d"/*.desktop; do
          [ -f "$f" ] || continue
          name=$(sed -n 's/^Name=//p' "$f" | head -1)
          exec=$(sed -n 's/^Exec=//p' "$f" | head -1)
          [ -n "$exec" ] && printf '%s\\t%s\\n' "$name" "$exec"
        done
      done
    `]
    stdout: StdioCollector {
      onStreamFinished: root.sessions = text.split("\n").filter(l => l !== "").map(l => {
        const [name, exec] = l.split("\t");
        return { name, exec };
      }).sort((a, b) => (b.name === "Hyprland") - (a.name === "Hyprland") || a.name.localeCompare(b.name))
    }
  }

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win
      required property var modelData
      readonly property bool primary: Hyprland.focusedMonitor?.name === modelData.name

      screen: modelData
      anchors { top: true; bottom: true; left: true; right: true }
      exclusionMode: ExclusionMode.Ignore
      color: Settings.colors.base
      WlrLayershell.layer: WlrLayer.Overlay
      WlrLayershell.namespace: "quickshell:greeter"
      WlrLayershell.keyboardFocus: primary ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

      Loader {
        anchors.centerIn: parent
        active: win.primary
        focus: true

        sourceComponent: LoginPrompt {
          buffer: root.buffer
          busy: root.busy
          failed: root.failed
          message: root.message
          hint: "Type to log in"
          onEdited: (text) => { root.buffer = text; if (text !== "") root.failed = false; }
          onSubmitted: root.submit()

          Keys.onTabPressed: root.sessionIndex = (root.sessionIndex + 1) % Math.max(1, root.sessions.length)

          StyledText {
            Layout.alignment: Qt.AlignHCenter
            visible: root.sessions.length > 1
            text: `${root.session?.name ?? ""} · Tab to switch`
            color: Settings.colors.textMuted
            font.pixelSize: 12

            TapHandler {
              onTapped: root.sessionIndex = (root.sessionIndex + 1) % root.sessions.length
            }
          }
        }
      }
    }
  }
}
