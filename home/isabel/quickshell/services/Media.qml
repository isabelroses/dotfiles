pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris
import qs.data

Singleton {
  id: root

  property list<MprisPlayer> players: Mpris.players.values.filter(player => player?.trackTitle != "")
  property MprisPlayer selectedPlayer: players.length > 0 ? players[0] : null

  readonly property bool playing: selectedPlayer?.isPlaying ?? false
  readonly property bool hasProgress: (selectedPlayer?.lengthSupported ?? false) && (selectedPlayer?.length ?? 0) > 0
  property date lastActive: new Date()
  onPlayingChanged: lastActive = new Date()
  onSelectedPlayerChanged: lastActive = new Date()

  // playing, or paused more recently than notifications.media_timeout
  readonly property bool recent: {
    if (!selectedPlayer) return false;
    const minutes = Config.get("notifications.media_timeout");
    return playing || minutes === 0 || Time.date - lastActive < minutes * 60000;
  }
}
