import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.data

BarGroup {
    id: root

    Layout.alignment: Qt.AlignCenter
    spacing: 2

    // one hover tracker for the whole strip, so at most one dot reads as hovered
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
            // fixed slot that fits the longest pill, so dots never shift when focus moves
            implicitWidth: Settings.barVertical ? 24 : 26
            implicitHeight: Settings.barVertical ? 26 : 24
            onClicked: modelData.activate()

            Rectangle {
                // focused: long pill; shown on another monitor: shorter, dimmer tint; otherwise a dot
                property real length: ws.focused ? 22 : ws.visibleElsewhere ? 14 : 8
                anchors.centerIn: parent
                width: Settings.barVertical ? 8 : length
                height: Settings.barVertical ? length : 8
                radius: 4
                color: ws.focused || ws.visibleElsewhere ? ws.tint : ws.hot ? Settings.colors.text : Settings.colors.textMuted
                opacity: ws.focused || ws.hot ? 1 : ws.visibleElsewhere ? 0.6 : 0.5

                Behavior on length { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic } }
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
