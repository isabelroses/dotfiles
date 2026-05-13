import QtQuick
import QtQuick.Layouts
import "root:/data"

Item {
    id: root

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 30
    implicitHeight: 50

    Text {
        id: clockText
        anchors.centerIn: parent
        text: Time.time
        color: Settings.colors.foreground
        font {
            pixelSize: 14
            weight: Font.Medium
        }
        horizontalAlignment: Text.AlignHCenter
    }
}
