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

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 24
    visible: Media.recent
    radius: Settings.radiusMd
    color: Settings.colors.surface
    clip: true

    Timer {
        running: root.visible && Media.playing && Media.hasProgress
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
            sourceSize: Qt.size(192, 192) // same as MediaArt so both share one cached decode
            visible: false
        }

        MultiEffect {
            anchors.fill: parent
            source: backdrop
            visible: backdrop.status === Image.Ready
            blurEnabled: true
            blur: 1.0
            blurMax: 64
            saturation: 0.7
            opacity: 0.7
        }

        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Utils.withAlpha(Settings.colors.base, 0.35) }
                GradientStop { position: 1.0; color: Utils.withAlpha(Settings.colors.base, 0.75) }
            }
        }
    }

    // art and track details on top, progress across the whole card underneath
    ColumnLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            MediaArt {
                Layout.alignment: Qt.AlignTop
                size: details.implicitHeight
            }

            ColumnLayout {
                id: details
                Layout.fillWidth: true
                spacing: 6

                MediaTitles { Layout.fillWidth: true }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 28

                    MediaControl {
                        icon: "media-skip-backward-symbolic"
                        enabled: root.player?.canGoPrevious ?? false
                        onClicked: root.player.previous()
                    }

                    MediaPlayButton { diameter: 32 }

                    MediaControl {
                        icon: "media-skip-forward-symbolic"
                        enabled: root.player?.canGoNext ?? false
                        onClicked: root.player.next()
                    }
                }
            }

            // switch between players when more than one is open
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

        MediaProgress { Layout.fillWidth: true }
    }
}
