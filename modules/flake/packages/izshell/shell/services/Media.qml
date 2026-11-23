pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.data

Singleton {
  id: root

  property list<MprisPlayer> players: Mpris.players.values.filter(player => player?.trackTitle != "")
  property MprisPlayer selectedPlayer: players.length > 0 ? players[0] : null
  readonly property ScriptModel playerModel: ScriptModel { values: [...root.players] }

  readonly property bool playing: selectedPlayer?.isPlaying ?? false
  readonly property bool hasProgress: (selectedPlayer?.lengthSupported ?? false) && (selectedPlayer?.length ?? 0) > 0
  property date lastActive: new Date()
  onPlayingChanged: lastActive = new Date()
  onSelectedPlayerChanged: lastActive = new Date()

  // playing, or paused more recently than notifications.media_timeout
  readonly property bool recent: {
    if (!selectedPlayer) return false;
    const minutes = Settings.notifications.media_timeout;
    return playing || minutes === 0 || Time.date - lastActive < minutes * 60000;
  }

  // where the selected player is, in seconds, and how far through (0 to 1).
  // MPRIS doesn't announce position, so it is polled once a second while a view
  // that shows it holds the poll (acquirePosition / releasePosition).
  readonly property real position: selectedPlayer?.position ?? 0
  readonly property real length: selectedPlayer?.length ?? 0
  readonly property real progress: hasProgress ? Math.min(1, position / Math.max(1, length)) : 0

  property int positionWatchers: 0
  function acquirePosition(): void { positionWatchers++; }
  function releasePosition(): void { positionWatchers = Math.max(0, positionWatchers - 1); }

  Timer {
    running: root.positionWatchers > 0 && root.playing && root.hasProgress
    interval: 1000
    repeat: true
    onTriggered: root.selectedPlayer.positionChanged()
  }
}
