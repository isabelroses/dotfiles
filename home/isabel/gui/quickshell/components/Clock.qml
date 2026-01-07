import QtQuick
import QtQuick.Layouts
import "root:/data"

Item {
    id: root

    signal clicked()

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

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
