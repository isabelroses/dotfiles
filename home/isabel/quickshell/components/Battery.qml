import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/data"
import "root:/components"
import "root:/services"

Item {
    id: root

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 20
    implicitHeight: 20

    // Only show if battery is present
    visible: UPower.isPresent

    MyIcon {
        anchors.centerIn: parent
        icon: UPower.icon
        size: 18
    }

    // Tooltip showing percentage and status
    ToolTip {
        id: tooltip
        visible: mouseArea.containsMouse
        text: `${Math.round(UPower.percentage)}% - ${UPower.statusText}`
        delay: 500
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }
}
