pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  readonly property string time: {
    Qt.formatTime(clock.date, "hh\nmmAP").slice(0, -2)
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
