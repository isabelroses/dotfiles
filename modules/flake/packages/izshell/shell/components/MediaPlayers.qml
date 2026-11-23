import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell.Widgets
import Quickshell.Services.Mpris
import qs.data
import qs.services

Box {
    id: root

    readonly property MprisPlayer player: Media.selectedPlayer

    Layout.fillWidth: true
    implicitHeight: content.implicitHeight + 24
    visible: Media.recent
    clip: true

    WheelHandler {
        enabled: Media.players.length > 1
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (e) => {
            const list = Media.players;
            const i = list.indexOf(Media.selectedPlayer);
            Media.selectedPlayer = list[(i + (e.angleDelta.y < 0 ? 1 : list.length - 1)) % list.length];
        }
    }

    Lease {
        active: root.visible
        onAcquire: Media.acquirePosition()
        onRelease: Media.releasePosition()
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
                GradientStop { position: 0.0; color: Utils.withAlpha(Theme.colors.base, 0.35) }
                GradientStop { position: 1.0; color: Utils.withAlpha(Theme.colors.base, 0.75) }
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
                    radius: Theme.pill(height)
                    color: selected ? Theme.colors.accentSoft : hovered ? Theme.colors.surfaceRaised : "transparent"
                    border.width: 1
                    border.color: selected ? Utils.withAlpha(Theme.colors.accent, 0.5) : Theme.colors.border
                    onClicked: Media.selectedPlayer = modelData


                    StyledText {
                        id: tabLabel
                        anchors.centerIn: parent
                        text: tab.modelData.identity || "Player"
                        font.pixelSize: 11
                        font.weight: tab.selected ? Font.DemiBold : Font.Normal
                        color: tab.selected ? Theme.colors.accent : Theme.colors.textMuted
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            MediaArt { Layout.alignment: Qt.AlignTop; size: details.implicitHeight }

            ColumnLayout {
                id: details
                Layout.fillWidth: true
                spacing: 6

                Titles { Layout.fillWidth: true }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 28

                    Control {
                        icon: "media-skip-backward-symbolic"
                        enabled: root.player?.canGoPrevious ?? false
                        onClicked: root.player.previous()
                    }

                    PlayButton { diameter: 32 }

                    Control {
                        icon: "media-skip-forward-symbolic"
                        enabled: root.player?.canGoNext ?? false
                        onClicked: root.player.next()
                    }
                }
            }

        }

        Progress { Layout.fillWidth: true }
    }

    // skip buttons
    component Control: IconButton {
        size: 16
        padding: 7
        color: Theme.colors.text
        hoverColor: Utils.withAlpha(Theme.colors.text, 0.1)
    }

    component PlayButton: Clickable {
        id: play

        property int diameter: 34
        onClicked: Media.selectedPlayer?.togglePlaying()
        implicitWidth: diameter
        implicitHeight: diameter
        radius: diameter / 2
        color: hovered ? Qt.lighter(Theme.colors.accent, 1.08) : Theme.colors.accent
        scale: pressed ? 0.92 : 1
        Behavior on scale { NumberAnimation { duration: 90 } }

        MyIcon {
            anchors.centerIn: parent
            icon: Media.playing ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"
            size: play.diameter * 0.45
            color: Theme.colors.textOnAccent
        }
    }

    component Titles: ColumnLayout {
        spacing: 2

        StyledText {
            Layout.fillWidth: true
            // the tabs above name the players when there are several
            visible: Media.players.length <= 1
            text: Media.selectedPlayer?.identity ?? ""
            color: Theme.colors.accent
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
            color: Theme.colors.textMuted
            font.pixelSize: 12
        }
    }

    // full-width bar with the elapsed and total times underneath
    component Progress: ColumnLayout {
        visible: Media.hasProgress
        spacing: 3

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 4
            radius: Theme.pill(height)
            color: Utils.withAlpha(Theme.colors.text, 0.15)

            Rectangle {
                width: parent.width * Media.progress
                height: parent.height
                radius: Theme.pill(height)
                color: Theme.colors.accent
            }
        }

        RowLayout {
            Layout.fillWidth: true

            Caption { text: Utils.formatDuration(Media.position); mono: true }

            Item { Layout.fillWidth: true }

            Caption { text: Utils.formatDuration(Media.length); mono: true }
        }
    }
}
