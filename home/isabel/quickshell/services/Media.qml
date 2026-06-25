pragma Singleton

import Quickshell
import Quickshell.Services.Mpris

Singleton {
  id: root

  // MprisPlayer has no `length`; the old `player.length != 0` filter was a no-op.
  property list<MprisPlayer> players: Mpris.players.values.filter(player => player?.trackTitle != "")
  property MprisPlayer selectedPlayer: players.length > 0 ? players[0] : null
}
