import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

MyIcon {
    Layout.alignment: Qt.AlignHCenter
    icon: Networking.icon
    size: 16
    color: Networking.connected ? Settings.colors.sky : Settings.colors.textSubtle

    BarTooltip {
        text: Networking.statusText
    }
}
