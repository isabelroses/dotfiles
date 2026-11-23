pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.data
import "NotificationFeed.js" as Feed

Singleton {
  id: root

  readonly property bool dndEnabled: Settings.notifications.dnd
  function setDnd(on: bool): void { Settings.set("notifications.dnd", on); }
  readonly property string dndIcon: dndEnabled ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"
  // D-Bus notifications plus the shell's own (`notify`), which look the same to the UI
  readonly property var all: [...notificationServer.trackedNotifications.values, ...root.local]
  readonly property var list: all.filter(
    notification => notification.tracked && !root.dndEnabled && !Settings.notifications.blacklist.includes(notification.appName)
  )
  property var local: []
  property int nextLocalId: -1

  readonly property var times: ({})
  property var history: []
  readonly property int historyLimit: 100

  // a notification that should pop up: not muted, not on do-not-disturb, and toasts are on
  signal toast(var notification)

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
    if (!root.dndEnabled && !blocked && Settings.notifications.toasts) root.toast(notification);
  }

  // "5m", "3h", a date (re-read each minute by whatever binds to it)
  function relativeTime(time: real): string {
    return Feed.relativeTime(time, Time.date);
  }

  // the sheet's feeds: rows of age headers and items, newest first
  // ({ kind: "header", label } or { kind: "item", item, index })
  readonly property var liveFeed: Feed.groupFeed([...list].reverse(), n => timeOf(n), Time.date)

  function historyFeed(): var {
    return Feed.groupFeed(history, h => h.time, Time.date);
  }

  // dismiss everything tracked, including what do-not-disturb or a muted app hides
  function dismissAll(): void {
    for (const notification of all) notification.dismiss();
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
    id: notificationServer
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
}
