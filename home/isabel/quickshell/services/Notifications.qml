pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.data

Singleton {
  id: root

  readonly property bool dndEnabled: Config.get("notifications.dnd")
  function setDnd(on: bool): void { Config.set("notifications.dnd", on); }
  property list<Notification> list: notifactionServer.trackedNotifications.values.filter(
    notification => notification.tracked && !root.dndEnabled && !Settings.notificationBlacklist.includes(notification.appName)
  )

  readonly property var times: ({})
  property var history: []
  readonly property int historyLimit: 100

  signal newNotification(Notification notification)

  function timeOf(n: Notification): real {
    return times[n.id] ?? Date.now();
  }

  function ageGroup(time: real): string {
    Time.date;
    const now = new Date();
    const d = new Date(time);
    const mins = (now.getTime() - time) / 60000;
    if (mins < 10) return "Just now";
    const startOfToday = new Date(now.getFullYear(), now.getMonth(), now.getDate()).getTime();
    if (time >= startOfToday) return "Earlier today";
    if (time >= startOfToday - 86400000) return "Yesterday";
    if (time >= startOfToday - 6 * 86400000) return Qt.formatDate(d, "dddd");
    return "Older";
  }

  function relativeTime(time: real): string {
    Time.date;
    const mins = Math.floor((Date.now() - time) / 60000);
    if (mins < 1) return "now";
    if (mins < 60) return `${mins}m`;
    if (mins < 1440) return `${Math.floor(mins / 60)}h`;
    return Qt.formatDate(new Date(time), "MMM d");
  }

  function clearHistory(): void {
    history = [];
    saveTimer.restart();
  }

  function removeHistory(index: int): void {
    const next = history.slice();
    next.splice(index, 1);
    history = next;
    saveTimer.restart();
  }

  NotificationServer {
    id: notifactionServer
    onNotification: (notification) => {
      const t = Date.now();
      root.times[notification.id] = t;
      notification.tracked = true;

      const blocked = Settings.notificationBlacklist.includes(notification.appName);
      const snapshot = {
        appName: notification.appName,
        appIcon: notification.appIcon,
        summary: notification.summary,
        body: notification.body,
        time: t,
      };
      const id = notification.id;
      notification.closed.connect(() => {
        delete root.times[id];
        if (!blocked) {
          root.history = [snapshot, ...root.history].slice(0, root.historyLimit);
          saveTimer.restart();
        }
      });

      if (!root.dndEnabled && !blocked) {
        root.newNotification(notification);
      }
    }

    actionsSupported: true
    inlineReplySupported: true
  }

  Timer {
    id: saveTimer
    interval: 1000
    onTriggered: historyFile.setText(JSON.stringify(root.history))
  }

  FileView {
    id: historyFile
    path: Quickshell.statePath("notification-history.json")
    printErrors: false
    onLoaded: {
      try {
        const data = JSON.parse(text());
        if (Array.isArray(data)) root.history = data.slice(0, root.historyLimit);
      } catch (e) {
        console.warn("notification history unreadable, starting fresh:", e);
      }
    }
  }

  IpcHandler {
    target: "notifications"

    function clear(): void {
      for (const notification of notifactionServer.trackedNotifications.values) {
        notification.tracked = false;
      }
    }

    function clearHistory(): void { root.clearHistory(); }
  }
}
