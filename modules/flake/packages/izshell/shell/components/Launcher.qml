import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.data

Clickable {
    id: root

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 34
    implicitHeight: 34
    radius: Theme.innerRadius
    color: root.hovered ? Theme.colors.accent : Theme.colors.accentSoft
    onClicked: Quickshell.execDetached(["vicinae", "toggle"])


    MyIcon {
        anchors.centerIn: parent
        icon: "nix-snowflake"
        size: 18
        color: root.hovered ? Theme.colors.textOnAccent : Theme.colors.accent
    }

    scale: root.pressed ? 0.92 : 1.0
    Behavior on scale { NumberAnimation { duration: 90 } }
}
