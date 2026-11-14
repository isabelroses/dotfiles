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
  Layout.alignment: Qt.AlignHCenter
  implicitWidth: 30
  implicitHeight: 30
  radius: Settings.radiusSm
  color: root.hovered ? Settings.colors.surfaceRaised : "transparent"
  border.width: 1
  border.color: root.hovered ? Settings.colors.borderStrong : "transparent"
  acceptedButtons: Qt.LeftButton | Qt.RightButton
  onClicked: (e) => {
    if (e.button === Qt.RightButton) Runtime.toggleQuickSettings();
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
    text: root.player
      ? `${root.playing ? "▶" : "❚❚"}  ${root.player.trackTitle}${root.player.trackArtist ? " — " + root.player.trackArtist : ""}`
      : ""
  }
}
