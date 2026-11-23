import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

// Status indicator inside the bar capsule; the capsule itself opens the panel.
Item {
    id: root

    readonly property int count: Notifications.list.length

    visible: count > 0 || Notifications.dndEnabled
    Layout.alignment: Qt.AlignCenter
    implicitWidth: 16
    implicitHeight: 16

    MyIcon {
        anchors.centerIn: parent
        icon: Notifications.dndIcon
        size: 16
        color: Notifications.dndEnabled ? Theme.colors.textSubtle : Theme.colors.text
    }

    Rectangle {
        visible: root.count > 0 && !Notifications.dndEnabled
        anchors { top: parent.top; right: parent.right; topMargin: -2; rightMargin: -2 }
        width: 7
        radius: Theme.pill(width)
        height: 7
        color: Theme.colors.accent
        border.color: Theme.colors.surface
        border.width: 1.5
    }

    BarTooltip {
        text: Notifications.dndEnabled ? "Do not disturb"
            : root.count === 1 ? "1 notification" : `${root.count} notifications`
    }
}
