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
        icon: Notifications.dndEnabled ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"
        size: 16
        color: Notifications.dndEnabled ? Settings.colors.textSubtle : Settings.colors.text
    }

    Rectangle {
        visible: root.count > 0 && !Notifications.dndEnabled
        anchors { top: parent.top; right: parent.right; topMargin: -2; rightMargin: -2 }
        width: 7
        height: 7
        color: Settings.colors.accent
        border.color: Settings.colors.surface
        border.width: 1.5
    }

    BarTooltip {
        text: Notifications.dndEnabled ? "Do not disturb"
            : root.count === 1 ? "1 notification" : `${root.count} notifications`
    }
}
