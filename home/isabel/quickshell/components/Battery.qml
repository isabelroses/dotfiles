import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

ColumnLayout {
    id: root

    readonly property bool low: UPower.percentage < 20 && !UPower.charging

    visible: UPower.isPresent
    Layout.alignment: Qt.AlignHCenter
    spacing: 2

    MyIcon {
        Layout.alignment: Qt.AlignHCenter
        icon: UPower.icon

        BarTooltip {
            text: `${Math.round(UPower.percentage)}%${UPower.charging ? " · charging" : ""}`
        }
        size: 16
        color: root.low ? Settings.colors.error
            : UPower.charging ? Settings.colors.success
            : Settings.colors.text
    }

    StyledText {
        Layout.alignment: Qt.AlignHCenter
        visible: Config.get("bar.battery_percent")
        text: Math.round(UPower.percentage)
        mono: true
        font.pixelSize: 9
        color: root.low ? Settings.colors.error : Settings.colors.textMuted
    }
}
