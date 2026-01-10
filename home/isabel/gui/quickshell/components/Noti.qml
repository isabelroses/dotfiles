import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications as QsNotifications
import "root:/data"
import "root:/services"

Item {
    id: root

    property bool hasNotifications: Notifications.list.length > 0 || Notifications.dndEnabled

    visible: hasNotifications

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 24
    implicitHeight: 24

    MyIcon {
        anchors.centerIn: parent
        icon: Notifications.dndEnabled ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"
        size: 18
    }
}
