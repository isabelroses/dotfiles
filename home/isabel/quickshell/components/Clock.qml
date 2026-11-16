import QtQuick
import QtQuick.Layouts
import qs.data

Item {
    id: root

    implicitWidth: Settings.barVertical ? 40 : row.implicitWidth + 12
    implicitHeight: Settings.barVertical ? column.implicitHeight + 12 : 40

    // side bar: stacked hours / minutes / period
    ColumnLayout {
        id: column
        visible: Settings.barVertical
        anchors.centerIn: parent
        spacing: -2

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.hours
            mono: true
            font.pixelSize: 15
            font.weight: Font.Bold
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.minutes
            mono: true
            color: Settings.colors.textMuted
            font.pixelSize: 15
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 4
            visible: text !== ""
            text: Time.period
            color: Settings.colors.accent
            font.pixelSize: 9
            font.weight: Font.DemiBold
            font.letterSpacing: 1
        }
    }

    // top/bottom bar: one line
    RowLayout {
        id: row
        visible: !Settings.barVertical
        anchors.centerIn: parent
        spacing: 6

        StyledText {
            text: `${Time.hours}:${Time.minutes}`
            mono: true
            font.pixelSize: 14
            font.weight: Font.Bold
        }

        StyledText {
            visible: text !== ""
            text: Time.period
            color: Settings.colors.accent
            font.pixelSize: 10
            font.weight: Font.DemiBold
            font.letterSpacing: 1
        }
    }

    BarTooltip {
        text: Time.longDate
    }
}
