import QtQuick
import QtQuick.Layouts
import qs.data

Item {
    id: root

    implicitWidth: 40
    implicitHeight: column.implicitHeight + 12

    ColumnLayout {
        id: column
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

    BarTooltip {
        text: Time.longDate
    }
}
