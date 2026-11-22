import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.data
import Izshell

// Keeps Hyprland's window gaps and corners in step with the shell. Floating:
// windows get the cards' rounding and an 8px breathing gap all round (the bar
// side only needs 4, the bar's own lane supplies the rest). Attached: back to
// flush, square windows, as config.lua sets them. Re-applied when Hyprland
// reloads its config, since that resets these to the config.lua values.
Scope {
  id: root

  readonly property bool floating: Settings.barFloating
  readonly property int rounding: floating ? Settings.cardRadius : 0
  readonly property int gapsIn: floating ? 4 : 0
  readonly property var gapsOut: {
    if (!floating) return { top: 0, right: 0, bottom: 0, left: 0 };
    const g = { top: 8, right: 8, bottom: 8, left: 8 };
    g[Settings.barSide] = 4;
    return g;
  }

  readonly property string lua: `hl.config({ decoration = { rounding = ${rounding} }, general = { gaps_in = ${gapsIn}, gaps_out = { top = ${gapsOut.top}, right = ${gapsOut.right}, bottom = ${gapsOut.bottom}, left = ${gapsOut.left} } } })`

  onLuaChanged: apply.restart()
  Component.onCompleted: apply.restart()

  Connections {
    target: Hyprland
    function onRawEvent(event: HyprlandEvent) {
      if (event.name === "configreloaded") apply.restart();
    }
  }

  // let the rounding slider settle before pushing to the compositor
  Timer {
    id: apply
    interval: 300
    onTriggered: Hyprctl.request("eval " + root.lua, reply => {
      if (reply.trim() !== "ok") console.warn("HyprlandSync: eval failed:", reply);
    })
  }
}
