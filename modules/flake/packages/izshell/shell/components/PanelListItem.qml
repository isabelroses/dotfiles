import QtQuick
import QtQuick.Layouts
import qs.data

// A row in a list: bare icon, label, optional badge. The active row is tinted
// and its icon and label take the accent; nothing else marks it.
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


    RowLayout {
        anchors { fill: parent; leftMargin: 12; rightMargin: 12 }
        spacing: 12

        MyIcon {
            icon: root.icon
            size: 16
            color: root.active ? root.tint : Settings.colors.textMuted
        }

        StyledText {
            Layout.fillWidth: true
            text: root.text
            color: root.active ? root.tint : Settings.colors.text
            font.weight: root.active ? Font.DemiBold : Font.Normal
        }

        StyledText {
            visible: root.badge !== ""
            text: root.badge
            mono: true
            color: root.active ? root.tint : Settings.colors.textMuted
            font.pixelSize: 11
        }
    }
}
