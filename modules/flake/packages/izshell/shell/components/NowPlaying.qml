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
  radius: Theme.radiusSm
  color: root.hovered ? Theme.colors.surfaceRaised : "transparent"
  acceptedButtons: Qt.LeftButton | Qt.RightButton
  onClicked: (e) => {
    if (e.button === Qt.RightButton) Surfaces.toggle("quickSettings");
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
    color: root.playing ? Theme.colors.accent : Theme.colors.textSubtle
    Behavior on color { ColorAnimation { duration: Theme.animNormal } }
  }

  BarTooltip { content: root.player ? card : null }

  Component {
    id: card

    RowLayout {
      spacing: 12

      Lease {
        active: true
        onAcquire: Media.acquirePosition()
        onRelease: Media.releasePosition()
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
        }

        StyledText {
          Layout.fillWidth: true
          visible: text !== ""
          text: root.player?.trackArtist ?? ""
          font.pixelSize: 12
          color: Theme.colors.textMuted
        }

        ThinSlider {
          Layout.fillWidth: true
          Layout.topMargin: 6
          visible: Media.hasProgress
          enabled: false
          handleWidth: 0
          value: Media.progress
          tint: root.playing ? Theme.colors.accent : Theme.colors.textSubtle
        }

        StyledText {
          Layout.topMargin: 4
          text: `${root.playing ? "Click to pause" : "Click to play"} · scroll to skip`
          font.pixelSize: 10
          color: Theme.colors.textSubtle
        }
      }
    }
  }
}
