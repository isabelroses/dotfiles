import QtQuick

// Holds something for as long as `active`: `acquire` fires when it becomes active
// and `release` when it stops or this is destroyed, so a view can keep a shared
// resource running (a scan, a poll) only while it needs it, and never leak it.
QtObject {
  id: root

  property bool active: false
  property bool _held: false
  signal acquire()
  signal release()

  onActiveChanged: sync()
  Component.onCompleted: sync()
  Component.onDestruction: {
    if (_held) release();
  }

  function sync(): void {
    if (active && !_held) {
      _held = true;
      acquire();
    } else if (!active && _held) {
      _held = false;
      release();
    }
  }
}
