pragma Singleton

import Quickshell
import Quickshell.Services.Mpris

Singleton {
  id: root

  property MprisPlayer selectedPlayer: Mpris.players.values[0]
  property list<MprisPlayer> players: Mpris.players.values
}
