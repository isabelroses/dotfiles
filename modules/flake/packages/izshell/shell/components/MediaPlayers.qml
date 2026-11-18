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
    border.width: 1
    border.color: Settings.colors.border

    WheelHandler {
        enabled: Media.players.length > 1
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (e) => {
            const list = Media.players;
            const i = list.indexOf(Media.selectedPlayer);
            Media.selectedPlayer = list[(i + (e.angleDelta.y < 0 ? 1 : list.length - 1)) % list.length];
        }
    }

    Timer {
        running: root.visible && Media.playing && Media.hasProgress
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
    }

    ClippingRectangle {
        anchors { fill: parent; margins: 1 }
        radius: Math.max(0, root.radius - 1)
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

    ColumnLayout {
        id: content
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: 12 }
        spacing: 10

        // one tab per player when there's more than one; the selected one is
        // tinted. scrolling over the card cycles through them too
        Flow {
            Layout.fillWidth: true
            visible: Media.players.length > 1
            spacing: 6

            Repeater {
                model: Media.players

                Clickable {
                    id: tab
                    required property MprisPlayer modelData
                    readonly property bool selected: Media.selectedPlayer === modelData

                    width: tabLabel.implicitWidth + 20
                    height: 24
                    radius: Settings.pill(height)
                    color: selected ? Settings.colors.accentSoft : hovered ? Settings.colors.surfaceRaised : "transparent"
                    border.width: 1
                    border.color: selected ? Utils.withAlpha(Settings.colors.accent, 0.5) : Settings.colors.border
                    onClicked: Media.selectedPlayer = modelData

                    Behavior on color { ColorAnimation { duration: Settings.animFast } }

                    StyledText {
                        id: tabLabel
                        anchors.centerIn: parent
                        text: tab.modelData.identity || "Player"
                        font.pixelSize: 11
                        font.weight: tab.selected ? Font.DemiBold : Font.Normal
                        color: tab.selected ? Settings.colors.accent : Settings.colors.textMuted
                    }
                }
            }
        }

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

        }

        MediaProgress { Layout.fillWidth: true }
    }
}
