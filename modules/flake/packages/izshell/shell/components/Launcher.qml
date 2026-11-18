import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.data

Clickable {
    id: root

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 34
    implicitHeight: 34
    radius: Settings.innerRadius
    color: root.hovered ? Settings.colors.accent : Settings.colors.accentSoft
    onClicked: Quickshell.execDetached(["vicinae", "toggle"])

    Behavior on color { ColorAnimation { duration: Settings.animFast } }

    MyIcon {
        anchors.centerIn: parent
        icon: "nix-snowflake"
        size: 18
        color: root.hovered ? Settings.colors.textOnAccent : Settings.colors.accent
    }

    scale: root.pressed ? 0.92 : 1.0
    Behavior on scale { NumberAnimation { duration: 90 } }
}
