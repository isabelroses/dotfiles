import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "root:/data"
import "root:/services"

ColumnLayout {
    id: root

    Layout.fillWidth: true
    spacing: 8
    visible: Media.players.length > 0

    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Text {
            text: "Now Playing"
            color: Settings.colors.foreground
            font {
                pixelSize: 14
                weight: Font.Bold
            }
        }

        Item { Layout.fillWidth: true }

        // Player selector (if multiple players)
        Row {
            spacing: 4
            visible: Media.players.length > 1

            Repeater {
                model: Media.players

                Rectangle {
                    required property MprisPlayer modelData
                    required property int index
                    width: 8
                    height: 8
                    radius: 4
                    color: Media.selectedPlayer === modelData ? Settings.colors.accent : Settings.colors.backgroundLightest

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Media.selectedPlayer = modelData
                    }
                }
            }
        }
    }

    // Current Player
    ListView {
        id: mediaPlayerList
        Layout.fillWidth: true
        Layout.preferredHeight: contentHeight
        model: Media.players
        spacing: 8
        clip: true
        interactive: false

        delegate: Rectangle {
            required property MprisPlayer modelData
            required property int index
            width: ListView.view.width
            height: 90
            radius: 8
            color: Settings.colors.backgroundLighter
            opacity: Media.selectedPlayer === modelData ? 1.0 : 0.6

            MouseArea {
                anchors.fill: parent
                onClicked: Media.selectedPlayer = modelData
            }

            RowLayout {
                anchors {
                    fill: parent
                    margins: 10
                }
                spacing: 10

                // Album Art
                ClippingWrapperRectangle {
                    radius: 6
                    Layout.preferredWidth: 70
                    Layout.preferredHeight: 70

                    Image {
                        anchors.fill: parent
                        source: modelData.trackArtUrl
                        fillMode: Image.PreserveAspectCrop
                    }
                }

                // Track Info & Controls
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 4

                        Text {
                            text: modelData.trackTitle ?? "Unknown"
                            color: Settings.colors.foreground
                            font {
                                pixelSize: 13
                                weight: Font.Medium
                            }
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Player app name badge
                        Rectangle {
                            visible: Media.players.length > 1
                            Layout.preferredHeight: 16
                            Layout.preferredWidth: appNameText.width + 8
                            radius: 4
                            color: Settings.colors.backgroundLightest

                            Text {
                                id: appNameText
                                anchors.centerIn: parent
                                text: modelData.identity ?? ""
                                color: Settings.colors.foreground
                                opacity: 0.7
                                font.pixelSize: 9
                            }
                        }
                    }

                    Text {
                        text: modelData.trackArtist ?? ""
                        color: Settings.colors.foreground
                        opacity: 0.7
                        font.pixelSize: 11
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                    }

                    Item { Layout.fillHeight: true }

                    // Playback Controls
                    RowLayout {
                        spacing: 14
                        Layout.alignment: Qt.AlignLeft

                        IconButton {
                            icon: "media-skip-backward-symbolic"
                            size: 14
                            onClicked: modelData.previous()
                        }

                        IconButton {
                            icon: modelData.playbackState === MprisPlaybackState.Playing
                                ? "media-playback-pause-symbolic"
                                : "media-playback-start-symbolic"
                            size: 18
                            onClicked: {
                                if (modelData.playbackState === MprisPlaybackState.Playing) {
                                    modelData.pause();
                                } else {
                                    modelData.play();
                                }
                            }
                        }

                        IconButton {
                            icon: "media-skip-forward-symbolic"
                            size: 14
                            onClicked: modelData.next()
                        }
                    }
                }
            }
        }
    }
}
