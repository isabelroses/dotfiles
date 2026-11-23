import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

ColumnLayout {
    id: root

    readonly property bool low: UPower.percentage < 20 && !UPower.charging

    visible: UPower.isPresent
    Layout.alignment: Qt.AlignCenter
    spacing: 2

    MyIcon {
        Layout.alignment: Qt.AlignCenter
        icon: UPower.icon

        BarTooltip {
            text: `${Math.round(UPower.percentage)}%${UPower.charging ? " · charging" : ""}`
        }
        size: 16
        color: root.low ? Theme.colors.error
            : UPower.charging ? Theme.colors.success
            : Theme.colors.text
    }

    StyledText {
        Layout.alignment: Qt.AlignCenter
        visible: Settings.bar.battery_percent
        text: Math.round(UPower.percentage)
        mono: true
        font.pixelSize: 9
        color: root.low ? Theme.colors.error : Theme.colors.textMuted
    }
}
