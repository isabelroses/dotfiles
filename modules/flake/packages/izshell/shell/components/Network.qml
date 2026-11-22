import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

MyIcon {
    Layout.alignment: Qt.AlignCenter
    icon: Networking.icon
    size: 16
    color: Networking.connected ? Settings.colors.text : Settings.colors.textSubtle

    BarTooltip { text: Networking.statusText }
}
