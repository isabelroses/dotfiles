import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Hyprland
import "root:/data"

Item {
    id: root

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 24
    implicitHeight: workspaceColumn.implicitHeight

    ColumnLayout {
        id: workspaceColumn
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        Repeater {
            model: Hyprland.workspaces

            delegate: Item {
                id: workspaceItem
                required property HyprlandWorkspace modelData

                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 24
                implicitHeight: 24

                Rectangle {
                    anchors.centerIn: parent
                    width: 22
                    height: 22
                    radius: 6
                    color: "transparent"

                    Text {
                        anchors.centerIn: parent
                        text: workspaceItem.modelData.id
                        color: workspaceItem.modelData.focused
                            ? Settings.colors.accent
                            : Settings.colors.foreground
                        font {
                            pixelSize: 14
                            weight: Font.Medium
                        }
                        opacity: workspaceItem.modelData.focused ? 1.0 : 0.6

                        Behavior on color {
                            ColorAnimation { duration: 150 }
                        }
                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: workspaceItem.modelData.activate()
                }
            }
        }
    }
}
