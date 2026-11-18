import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import qs.data
import qs.services

Clickable {
  id: root

  readonly property MprisPlayer player: Media.selectedPlayer
  readonly property bool playing: player?.isPlaying ?? false

  visible: player !== null
  Layout.alignment: Qt.AlignCenter
  implicitWidth: 30
  implicitHeight: 30
  radius: Settings.radiusSm
  color: root.hovered ? Settings.colors.surfaceRaised : "transparent"
  acceptedButtons: Qt.LeftButton | Qt.RightButton
  onClicked: (e) => {
    if (e.button === Qt.RightButton) Runtime.toggleNotifications();
    else if (root.player?.canTogglePlaying) root.player.togglePlaying();
  }
  onScrolled: (e) => {
    if (e.angleDelta.y < 0 && root.player?.canGoNext) root.player.next();
    else if (e.angleDelta.y > 0 && root.player?.canGoPrevious) root.player.previous();
  }

  MyIcon {
    anchors.centerIn: parent
    icon: "audio-x-generic-symbolic"
    size: 16
    color: root.playing ? Settings.colors.accent : Settings.colors.textSubtle
    Behavior on color { ColorAnimation { duration: Settings.animNormal } }
  }

  BarTooltip {
    content: root.player ? card : null
  }

  Component {
    id: card

    RowLayout {
      spacing: 12

      Timer {
        running: root.playing && Media.hasProgress
        interval: 1000
        repeat: true
        onTriggered: root.player.positionChanged()
      }

      MediaArt { size: 56 }

      ColumnLayout {
        Layout.preferredWidth: 200
        spacing: 2

        StyledText {
          Layout.fillWidth: true
          text: root.player?.trackTitle ?? ""
          font.pixelSize: 13
          font.weight: Font.DemiBold
          elide: Text.ElideRight
        }

        StyledText {
          Layout.fillWidth: true
          visible: text !== ""
          text: root.player?.trackArtist ?? ""
          font.pixelSize: 12
          color: Settings.colors.textMuted
          elide: Text.ElideRight
        }

        ThinSlider {
          Layout.fillWidth: true
          Layout.topMargin: 6
          visible: Media.hasProgress
          enabled: false
          handleWidth: 0
          value: Media.hasProgress ? root.player.position / root.player.length : 0
          tint: root.playing ? Settings.colors.accent : Settings.colors.textSubtle
        }

        StyledText {
          Layout.topMargin: 4
          text: `${root.playing ? "Click to pause" : "Click to play"} · scroll to skip`
          font.pixelSize: 10
          color: Settings.colors.textSubtle
        }
      }
    }
  }
}
