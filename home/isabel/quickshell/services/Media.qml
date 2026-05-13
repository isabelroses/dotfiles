pragma Singleton

import Quickshell
import Quickshell.Services.Mpris

Singleton {
  id: root

  property MprisPlayer selectedPlayer: players[0]
  property list<MprisPlayer> players: Mpris.players.values.filter(player => player.length != 0 && player?.trackTitle != "")
}
