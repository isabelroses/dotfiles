import QtQuick
import Quickshell
import Quickshell.Widgets
import "root:/data"
import "root:/components"

Item {
    id: root

    property string icon: ""
    property int size: 18
    property bool invert: false

    signal clicked

    implicitWidth: size
    implicitHeight: size

    MyIcon {
        anchors.centerIn: parent
        icon: root.icon
        size: root.size
        invert: root.invert
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }

    scale: mouseArea.pressed ? 0.9 : 1.0

    Behavior on scale {
        NumberAnimation { duration: 100 }
    }
}
