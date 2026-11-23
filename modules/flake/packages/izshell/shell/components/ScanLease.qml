import QtQuick
import qs.services

// Holds a Wi-Fi scan while `active`: scanning runs while anything holds one.
// Released when this goes inactive or is destroyed.
QtObject {
  id: root

  property bool active: false
  property bool _held: false

  onActiveChanged: sync()
  Component.onCompleted: sync()
  Component.onDestruction: {
    if (_held) Networking.releaseScan();
  }

  function sync(): void {
    if (active && !_held) {
      _held = true;
      Networking.acquireScan();
    } else if (!active && _held) {
      _held = false;
      Networking.releaseScan();
    }
  }
}
