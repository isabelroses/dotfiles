pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root

  readonly property date date: clock.date
  readonly property bool use24h: Config.get("bar.clock_24h")
  readonly property string hours: use24h ? Qt.formatTime(clock.date, "HH") : Qt.formatTime(clock.date, "hh AP").slice(0, 2)
  readonly property string minutes: Qt.formatTime(clock.date, "mm")
  readonly property string period: use24h ? "" : Qt.formatTime(clock.date, "AP")
  readonly property string longDate: Qt.formatDate(clock.date, "dddd, MMMM d")

  readonly property string greeting: {
    const hour = clock.date.getHours();
    if (hour < 5) return "Good night";
    if (hour < 12) return "Good morning";
    if (hour < 18) return "Good afternoon";
    return "Good evening";
  }

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
