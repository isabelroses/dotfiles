import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

MyIcon {
    Layout.alignment: Qt.AlignCenter
    icon: Networking.icon
    size: 16
    color: Networking.connected ? Theme.colors.text : Theme.colors.textSubtle

    BarTooltip { text: Networking.statusText }
}
