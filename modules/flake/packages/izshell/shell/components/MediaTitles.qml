import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

ColumnLayout {
    spacing: 2

    StyledText {
        Layout.fillWidth: true
        // the tabs above name the players when there are several
        visible: Media.players.length <= 1
        text: Media.selectedPlayer?.identity ?? ""
        color: Settings.colors.accent
        font.pixelSize: 11
        font.weight: Font.Medium
    }

    Marquee {
        Layout.fillWidth: true
        text: Media.selectedPlayer?.trackTitle || "Unknown track"
        playing: Media.playing
        font.pixelSize: 14
        font.weight: Font.DemiBold
    }

    Marquee {
        Layout.fillWidth: true
        visible: text !== ""
        text: Media.selectedPlayer?.trackArtist ?? ""
        playing: Media.playing
        color: Settings.colors.textMuted
        font.pixelSize: 12
    }
}
