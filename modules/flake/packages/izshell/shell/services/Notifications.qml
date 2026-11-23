pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.data

Singleton {
  id: root

  readonly property bool dndEnabled: Settings.notifications.dnd
  function setDnd(on: bool): void { Settings.set("notifications.dnd", on); }
  // D-Bus notifications plus the shell's own (`notify`), which look the same to the UI
  readonly property var all: [...notifactionServer.trackedNotifications.values, ...root.local]
  readonly property var list: all.filter(
    notification => notification.tracked && !root.dndEnabled && !Settings.notifications.blacklist.includes(notification.appName)
  )
  property var local: []
  property int nextLocalId: -1

  readonly property var times: ({})
  property var history: []
  readonly property int historyLimit: 100

  signal newNotification(var notification)

  function timeOf(n: var): real {
    return times[n.id] ?? Date.now();
  }

  // A notification from the shell itself, not over D-Bus. `props`: summary, body,
  // appName, appIcon, image, urgency, actions ([{ identifier, text, invoke }]);
  // `onClosed` runs on dismissal. A plain object, since a QML object can't have
  // the `id` timestamps are keyed by; only `tracked` changes, and dismissing also
  // reassigns `local`, so bindings over `list` see it go.
  function notify(props: var, onClosed: var): var {
    const listeners = [];
    const n = Object.assign({
      id: root.nextLocalId--,
      appName: "izshell", appIcon: "", image: "", summary: "", body: "", desktopEntry: "",
      urgency: NotificationUrgency.Normal, actions: [],
      hasInlineReply: false, inlineReplyPlaceholder: "",
      tracked: true,
      closed: { connect: f => listeners.push(f) },
      dismiss() {
        if (!n.tracked) return;
        n.tracked = false;
        root.local = root.local.filter(l => l !== n);
        listeners.forEach(f => f());
        onClosed?.();
      },
      expire() { n.dismiss(); },
    }, props);
    root.local = root.local.concat([n]);
    root.track(n);
    return n;
  }

  // shared by D-Bus and local notifications: timestamps, history on close, the toast
  function track(notification: var): void {
    const t = Date.now();
    root.times[notification.id] = t;
    const blocked = Settings.notifications.blacklist.includes(notification.appName);
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
    if (!root.dndEnabled && !blocked) root.newNotification(notification);
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
      notification.tracked = true;
      root.track(notification);
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
      for (const notification of root.all) {
        notification.dismiss();
      }
    }

    // notify-send for scripts, minus the D-Bus round trip
    function send(summary: string, body: string): void { root.notify({ summary: summary, body: body }); }

    function clearHistory(): void { root.clearHistory(); }
  }
}
