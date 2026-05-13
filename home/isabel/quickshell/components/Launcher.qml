import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import "root:/data"

Item {
    id: root

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 24
    implicitHeight: 24

    IconButton {
        anchors.centerIn: parent
        icon: "nix-snowflake"
        size: 20
        onClicked: launcherProcess.running = true
    }

    Process {
        id: launcherProcess
        command: ["vicinae", "toggle"]
    }
}
