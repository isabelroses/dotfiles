import QtQuick
import QtQuick.Layouts
import qs.data

// Serif numerals: upright hours over italic minutes. Click for the
// calendar.
Item {
    id: root

    implicitWidth: Theme.barVertical ? 34 : row.implicitWidth + 12
    implicitHeight: Theme.barVertical ? column.implicitHeight + 8 : 34

    HoverHandler { id: hover; cursorShape: Qt.PointingHandCursor }
    TapHandler { onTapped: Surfaces.toggle("calendar") }

    Rectangle {
        anchors.fill: parent
        radius: Theme.innerRadius
        color: Surfaces.calendarOpen ? Theme.colors.accentSoft : Utils.withAlpha(Theme.colors.text, 0.08)
        opacity: Surfaces.calendarOpen || hover.hovered ? 1 : 0
        Behavior on opacity { Anim { duration: Theme.animFast } }
    }

    // side bar: stacked hours / minutes / period
    ColumnLayout {
        id: column
        visible: Theme.barVertical
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
            color: Theme.colors.textMuted
            font.pixelSize: 21
        }

        StyledText {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 6
            visible: text !== ""
            text: Time.period.toLowerCase()
            color: Theme.colors.accent
            serif: true
            font.italic: true
            font.pixelSize: 12
        }
    }

    // top/bottom bar: one line
    RowLayout {
        id: row
        visible: !Theme.barVertical
        anchors.centerIn: parent
        spacing: 3

        StyledText { text: Time.hours; serif: true; font.pixelSize: 19 }

        StyledText {
            text: Time.minutes
            serif: true
            font.italic: true
            color: Theme.colors.textMuted
            font.pixelSize: 19
        }

        StyledText {
            Layout.leftMargin: 3
            visible: text !== ""
            text: Time.period.toLowerCase()
            color: Theme.colors.accent
            serif: true
            font.italic: true
            font.pixelSize: 12
        }
    }

    BarTooltip { text: Time.longDate }
}
