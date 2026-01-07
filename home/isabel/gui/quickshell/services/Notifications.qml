pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "root:/data"

Singleton {
  id: root

  property bool dndEnabled: false
  property list<Notification> list: notifactionServer.trackedNotifications.values.filter(
    notification => notification.tracked && !root.dndEnabled && !Settings.notificationBlacklist.includes(notification.appName)
  )

  signal newNotification(Notification notification)

  NotificationServer {
    id: notifactionServer
    onNotification: (notification) => {
      notification.tracked = true
      // Only emit signal if not in DND and not blacklisted
      if (!root.dndEnabled && !Settings.notificationBlacklist.includes(notification.appName)) {
        root.newNotification(notification)
      }
    }

    actionsSupported: true
  }

  IpcHandler {
    target: "notifcations"

    function clear(): void {
      for (const notification of notifactionServer.trackedNotifications.values) {
        notification.tracked = false;
      }
    }
  }
}

