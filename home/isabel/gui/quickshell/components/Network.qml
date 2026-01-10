import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import "root:/data"
import "root:/components"
import "root:/services"

Item {
    id: root

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 20
    implicitHeight: 20

    MyIcon {
        anchors.centerIn: parent
        icon: Networking.icon
        size: 18
    }
}
