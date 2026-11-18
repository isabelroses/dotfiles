import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.data

// Workspace tiles: a soft outlined square each, with a dot in the
// middle. The focused one fills in and its dot grows and takes the tint.
BarGroup {
    id: root

    Layout.alignment: Qt.AlignCenter
    spacing: 6

    // one hover tracker for the whole strip, so at most one tile reads as hovered
    readonly property int hoveredId: hover.hovered ? (root.childAt(hover.point.position.x, hover.point.position.y)?.modelData?.id ?? -1) : -1
    HoverHandler { id: hover }

    WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (e) => Hyprland.dispatch(`hl.dsp.focus({ workspace = "${e.angleDelta.y < 0 ? "e+1" : "e-1"}" })`)
    }

    Repeater {
        model: Hyprland.workspaces

        delegate: Clickable {
            id: ws
            required property HyprlandWorkspace modelData
            readonly property bool focused: modelData.focused
            readonly property bool visibleElsewhere: modelData.active && !focused
            readonly property bool hot: root.hoveredId === modelData.id
            readonly property color tint: Config.get("bar.workspace_colours")
              ? Settings.colors.pops[(Math.max(1, modelData.id) - 1) % Settings.colors.pops.length]
              : Settings.colors.accent

            visible: modelData.id > 0
            Layout.alignment: Qt.AlignCenter
            implicitWidth: 30
            implicitHeight: 30
            radius: Settings.innerRadius
            color: ws.focused ? Utils.withAlpha(Settings.colors.text, 0.10)
                 : ws.hot ? Utils.withAlpha(Settings.colors.text, 0.06)
                 : "transparent"
            border.width: 1
            border.color: ws.visibleElsewhere ? Utils.withAlpha(ws.tint, 0.6)
                        : Utils.withAlpha(Settings.colors.text, ws.focused ? 0.18 : 0.10)
            onClicked: modelData.activate()

            Behavior on color { ColorAnimation { duration: Settings.animFast } }

            Rectangle {
                property real size: ws.focused ? 8 : ws.visibleElsewhere || ws.hot ? 6 : 4
                anchors.centerIn: parent
                width: size
                height: size
                radius: size / 2
                color: ws.focused || ws.visibleElsewhere ? ws.tint : Settings.colors.text
                opacity: ws.focused ? 1 : ws.visibleElsewhere ? 0.8 : ws.hot ? 0.7 : 0.35

                Behavior on size { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Settings.curve } }
                Behavior on color { ColorAnimation { duration: Settings.animFast } }
                Behavior on opacity { NumberAnimation { duration: Settings.animFast } }
            }

            BarTooltip {
                id: tip
                text: {
                    if (!tip.hovered) return `Workspace ${ws.modelData.id}`;
                    const titles = Hyprland.toplevels.values
                        .filter(t => t.workspace?.id === ws.modelData.id)
                        .map(t => t.title);
                    return `Workspace ${ws.modelData.id}` + (titles.length ? "\n" + titles.join("\n") : " · empty");
                }
            }
        }
    }
}
