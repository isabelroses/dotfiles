import QtQuick
import QtQuick.Layouts
import qs.data

Clickable {
    id: root

    property string icon: ""
    property string text: ""
    property string badge: ""
    property bool active: false
    property color tint: Settings.colors.accent


    implicitHeight: 40
    radius: Settings.radiusSm
    color: active ? Utils.withAlpha(tint, 0.12)
         : root.hovered ? Settings.colors.surfaceRaised
         : "transparent"

    Behavior on color { ColorAnimation { duration: Settings.animFast } }

    Rectangle {
        visible: root.active
        anchors { left: parent.left; top: parent.top; bottom: parent.bottom }
        width: 2
        color: root.tint
    }

    RowLayout {
        anchors { fill: parent; leftMargin: 10; rightMargin: 12 }
        spacing: 10

        IconChip {
            size: 26
            color: root.active ? root.tint : Settings.colors.overlay
            icon: root.icon
            iconSize: 14
            iconColor: root.active ? Settings.colors.textOnAccent : Settings.colors.text
        }

        StyledText {
            Layout.fillWidth: true
            text: root.text
            color: root.active ? root.tint : Settings.colors.text
            font.weight: root.active ? Font.DemiBold : Font.Normal
            elide: Text.ElideRight
        }

        StyledText {
            visible: root.badge !== ""
            text: root.badge
            mono: true
            color: root.active ? root.tint : Settings.colors.textSubtle
            font.pixelSize: 10
        }
    }
}
