import QtQuick
import "root:/data"

Text {
    id: clock
    font.pointSize: 13
    color: Settings.colors.foreground
    anchors.centerIn: parent

    text: Time.time
}
