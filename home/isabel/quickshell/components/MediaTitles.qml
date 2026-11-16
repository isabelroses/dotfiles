import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

ColumnLayout {
    spacing: 2

    StyledText {
        Layout.fillWidth: true
        text: (Media.selectedPlayer?.identity ?? "").toUpperCase()
        color: Settings.colors.sky
        font.pixelSize: 9
        font.weight: Font.DemiBold
        font.letterSpacing: 1.2
        elide: Text.ElideRight
    }

    StyledText {
        Layout.fillWidth: true
        text: Media.selectedPlayer?.trackTitle || "Unknown track"
        font.pixelSize: 14
        font.weight: Font.DemiBold
        elide: Text.ElideRight
    }

    StyledText {
        Layout.fillWidth: true
        visible: text !== ""
        text: Media.selectedPlayer?.trackArtist ?? ""
        color: Settings.colors.textMuted
        font.pixelSize: 12
        elide: Text.ElideRight
    }
}
