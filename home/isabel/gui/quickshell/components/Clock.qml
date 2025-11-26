import QtQuick
import QtQuick.Layouts
import "root:/data"

Text {
    id: clock
    font.pointSize: 13
    color: Settings.colors.foreground
    Layout.alignment: Qt.AlignCenter

    text: Time.time
}
