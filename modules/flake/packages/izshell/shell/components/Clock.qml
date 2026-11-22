import QtQuick
import QtQuick.Layouts
import qs.data

// Serif numerals: upright hours over italic minutes. Click for the
// calendar.
Item {
    id: root

    implicitWidth: Settings.barVertical ? 34 : row.implicitWidth + 12
    implicitHeight: Settings.barVertical ? column.implicitHeight + 8 : 34

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: Runtime.toggleCalendar() }

    Rectangle {
        anchors.fill: parent
        radius: Settings.innerRadius
        color: Runtime.calendarOpen ? Settings.colors.accentSoft : Utils.withAlpha(Settings.colors.text, 0.08)
        opacity: Runtime.calendarOpen || hover.hovered ? 1 : 0
        Behavior on opacity { Anim { duration: Settings.animFast } }
    }

    // side bar: stacked hours / minutes / period
    ColumnLayout {
        id: column
        visible: Settings.barVertical
        anchors.centerIn: parent
        spacing: -5

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.hours
            serif: true
            font.pixelSize: 21
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.minutes
            serif: true
            font.italic: true
            color: Settings.colors.textMuted
            font.pixelSize: 21
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            visible: text !== ""
            text: Time.period.toLowerCase()
            color: Settings.colors.accent
            serif: true
            font.italic: true
            font.pixelSize: 12
        }
    }

    // top/bottom bar: one line
    RowLayout {
        id: row
        visible: !Settings.barVertical
        anchors.centerIn: parent
        spacing: 3

        StyledText { text: Time.hours; serif: true; font.pixelSize: 19 }

        StyledText {
            text: Time.minutes
            serif: true
            font.italic: true
            color: Settings.colors.textMuted
            font.pixelSize: 19
        }

        StyledText {
            Layout.leftMargin: 3
            visible: text !== ""
            text: Time.period.toLowerCase()
            color: Settings.colors.accent
            serif: true
            font.italic: true
            font.pixelSize: 12
        }
    }

    BarTooltip { text: Time.longDate }
}
