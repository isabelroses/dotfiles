import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.data
import qs.services

// full-width bar with the elapsed and total times underneath
ColumnLayout {
    id: root

    readonly property MprisPlayer player: Media.selectedPlayer

    visible: Media.hasProgress
    spacing: 3

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: 4
        radius: Settings.pill(height)
        color: Utils.withAlpha(Settings.colors.text, 0.15)

        Rectangle {
            width: parent.width * Math.min(1, (root.player?.position ?? 0) / Math.max(1, root.player?.length ?? 1))
            height: parent.height
            radius: Settings.pill(height)
            color: Settings.colors.accent
        }
    }

    RowLayout {
        Layout.fillWidth: true

        Caption { text: Utils.formatDuration(root.player?.position ?? 0); mono: true }

        Item { Layout.fillWidth: true }

        Caption { text: Utils.formatDuration(root.player?.length ?? 0); mono: true }
    }
}
