import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.data
import qs.services

Rectangle {
    id: root

    readonly property MprisPlayer player: Media.selectedPlayer
    readonly property bool playing: player?.playbackState === MprisPlaybackState.Playing
    readonly property bool hasProgress: (player?.lengthSupported ?? false) && (player?.length ?? 0) > 0

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 28
    visible: player !== null && Config.get("quick_settings.show_media")
    radius: Settings.radiusMd
    color: Settings.colors.surface
    border.color: Settings.colors.border
    border.width: 1
    clip: true

    Timer {
        running: root.visible && root.playing && root.hasProgress
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    ClippingRectangle {
        anchors.fill: parent
        radius: root.radius
        color: "transparent"

        Image {
            id: backdrop
            anchors.fill: parent
            source: root.player?.trackArtUrl ?? ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(128, 128)
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: backdrop
            visible: backdrop.status === Image.Ready
            blurEnabled: true
            blur: 1.0
            blurMax: 64
            saturation: 0.2
            opacity: 0.35
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Utils.withAlpha(Settings.colors.surface, 0.55) }
                GradientStop { position: 1.0; color: Utils.withAlpha(Settings.colors.surface, 0.9) }
            }
        }
    }

    ColumnLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
        spacing: 12

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            ClippingWrapperRectangle {
                radius: Settings.radiusSm
                implicitWidth: 64
                implicitHeight: 64
                color: Settings.colors.overlay

                Item {
                    implicitWidth: 64
                    implicitHeight: 64

                    MyIcon {
                        anchors.centerIn: parent
                        visible: art.status !== Image.Ready
                        icon: "folder-music-symbolic"
                        size: 24
                        color: Settings.colors.textSubtle
                    }

                    Image {
                        id: art
                        anchors.fill: parent
                        source: root.player?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        sourceSize: Qt.size(160, 160)
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                StyledText {
                    Layout.fillWidth: true
                    text: (root.player?.identity ?? "").toUpperCase()
                    color: Settings.colors.sky
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.2
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.player?.trackTitle || "Unknown track"
                    font.pixelSize: 14
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }

                StyledText {
                    Layout.fillWidth: true
                    text: root.player?.trackArtist ?? ""
                    color: Settings.colors.textMuted
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    visible: text !== ""
                }
            }

            Column {
                Layout.alignment: Qt.AlignTop
                spacing: 4
                visible: Media.players.length > 1

                Repeater {
                    model: Media.players

                    Rectangle {
                        required property MprisPlayer modelData
                        width: 6
                        height: Media.selectedPlayer === modelData ? 14 : 6
                        radius: 0
                        color: Media.selectedPlayer === modelData ? Settings.colors.accent : Settings.colors.borderStrong

                        Behavior on height { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic } }

                        MouseArea {
                            anchors.fill: parent
                            anchors.margins: -4
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Media.selectedPlayer = parent.modelData
                        }
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            visible: root.hasProgress
            spacing: 4

            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 4
                radius: 0
                color: Settings.colors.overlay

                Rectangle {
                    width: parent.width * Math.min(1, (root.player?.position ?? 0) / Math.max(1, root.player?.length ?? 1))
                    height: parent.height
                    radius: 0
                    color: Settings.colors.accent
                }
            }

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    text: Utils.formatDuration(root.player?.position ?? 0)
                    mono: true
                    color: Settings.colors.textSubtle
                    font.pixelSize: 10
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: Utils.formatDuration(root.player?.length ?? 0)
                    mono: true
                    color: Settings.colors.textSubtle
                    font.pixelSize: 10
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 18

            IconButton {
                icon: "media-skip-backward-symbolic"
                size: 16
                enabled: root.player?.canGoPrevious ?? false
                onClicked: root.player.previous()
            }

            Clickable {
                onClicked: root.player.togglePlaying()
                implicitWidth: 42
                implicitHeight: 42
                radius: Settings.radiusSm
                color: hovered ? Qt.lighter(Settings.colors.accent, 1.08) : Settings.colors.accent
                scale: pressed ? 0.92 : 1
                Behavior on scale { NumberAnimation { duration: 90 } }

                MyIcon {
                    anchors.centerIn: parent
                    icon: root.playing ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"
                    size: 18
                    color: Settings.colors.textOnAccent
                }
            }

            IconButton {
                icon: "media-skip-forward-symbolic"
                size: 16
                enabled: root.player?.canGoNext ?? false
                onClicked: root.player.next()
            }
        }
    }
}
