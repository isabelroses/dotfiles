import QtQuick
import QtQuick.Layouts
import "root:/data"
import "root:/services"

Item {
    id: root

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 20
    implicitHeight: 20

    MyIcon {
        anchors.centerIn: parent
        icon: Pipewire.sinkIcon
        size: 18
    }
}
