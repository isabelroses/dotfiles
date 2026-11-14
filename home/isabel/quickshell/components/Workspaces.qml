import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.data

ColumnLayout {
    id: root

    Layout.alignment: Qt.AlignHCenter
    spacing: 4

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
            readonly property color tint: Config.get("bar.workspace_colours")
              ? Settings.colors.pops[(Math.max(1, modelData.id) - 1) % Settings.colors.pops.length]
              : Settings.colors.accent

            visible: modelData.id > 0
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 28
            implicitHeight: 28
            radius: Settings.radiusSm
            color: focused ? tint : Utils.withAlpha(tint, hovered ? 0.22 : 0.08)
            border.width: 1
            border.color: focused || hovered ? tint : Utils.withAlpha(tint, 0.55)
            onClicked: modelData.activate()

            Behavior on color { ColorAnimation { duration: Settings.animFast } }
            Behavior on border.color { ColorAnimation { duration: Settings.animFast } }

            StyledText {
                anchors.centerIn: parent
                text: ws.modelData.id
                mono: true
                color: ws.focused ? Settings.colors.textOnAccent : ws.tint
                font.pixelSize: 12
                font.weight: Font.Bold
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
