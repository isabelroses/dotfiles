import QtQuick
import qs.data

Item {
    id: root

    property string icon: ""
    property int size: 18
    property int padding: 6
    property color color: Settings.colors.text
    property color hoverColor: Settings.colors.surfaceRaised
    property bool enabled: true

    signal clicked

    implicitWidth: size + padding * 2
    implicitHeight: size + padding * 2
    opacity: enabled ? 1 : 0.4

    Rectangle {
        anchors.fill: parent
        radius: Settings.radiusSm
        color: mouseArea.pressed ? Settings.colors.overlay : root.hoverColor
        opacity: mouseArea.containsMouse && root.enabled ? 1 : 0

        Behavior on opacity { NumberAnimation { duration: Settings.animFast } }
    }

    MyIcon {
        anchors.centerIn: parent
        icon: root.icon
        size: root.size
        color: root.color
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: root.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: if (root.enabled) root.clicked()
    }

    scale: mouseArea.pressed ? 0.92 : 1.0
    Behavior on scale { NumberAnimation { duration: 90 } }
}
