import QtQuick
import QtQuick.Layouts
import "root:/data"

Rectangle {
    id: root

    property string icon: ""
    property string text: ""
    property string badge: ""
    property bool active: false
    property bool showBadge: badge !== ""

    signal clicked()

    width: parent?.width ?? 100
    height: 36
    radius: 6
    color: active ? Settings.colors.accent : "transparent"

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        onEntered: if (!root.active) parent.color = Settings.colors.backgroundLightest
        onExited: parent.color = root.active ? Settings.colors.accent : "transparent"
        onClicked: root.clicked()
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 8

        MyIcon {
            icon: root.icon
            size: 16
        }

        Text {
            text: root.text
            color: root.active ? Settings.colors.background : Settings.colors.foreground
            font.pixelSize: 12
            elide: Text.ElideRight
            Layout.fillWidth: true
        }

        Text {
            visible: root.showBadge
            text: root.badge
            color: root.active ? Settings.colors.background : Settings.colors.foreground
            opacity: 0.7
            font.pixelSize: 11
        }
    }
}
