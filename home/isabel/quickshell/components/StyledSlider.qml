import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import qs.data

Slider {
    id: root

    property string icon: ""
    property color accentColor: Settings.colors.accent
    property bool iconClickable: false
    property bool dimmed: false

    signal iconClicked()

    Layout.fillWidth: true
    implicitHeight: 40
    padding: 0

    readonly property real fillWidth: height + visualPosition * (width - height)

    background: Rectangle {
        implicitHeight: 40
        radius: Settings.radiusSm
        color: Settings.colors.surfaceRaised
        border.color: Settings.colors.border
        border.width: 1

        Rectangle {
            width: root.fillWidth
            height: parent.height
            radius: Settings.radiusSm
            color: root.dimmed ? Settings.colors.overlay : root.accentColor

            Behavior on color { ColorAnimation { duration: Settings.animFast } }
        }
    }

    handle: Item {}

    StyledText {
        anchors { right: parent.right; rightMargin: 14; verticalCenter: parent.verticalCenter }
        text: Math.round(root.position * 100) + "%"
        mono: true
        font.pixelSize: 11
        color: root.fillWidth > root.width - 44 && !root.dimmed
            ? Settings.colors.textOnAccent : Settings.colors.textMuted
    }

    IconButton {
        anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: (root.height - width) / 2 }
        icon: root.icon
        size: 16
        padding: 6
        color: root.dimmed ? Settings.colors.textMuted : Settings.colors.textOnAccent
        hoverColor: Qt.rgba(0, 0, 0, 0.15)
        enabled: root.iconClickable
        opacity: 1
        onClicked: root.iconClicked()
    }
}
