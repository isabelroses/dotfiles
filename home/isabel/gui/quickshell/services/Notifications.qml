pragma Singleton

import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
  id: root

  property list<Notification> list: notifactionServer.trackedNotifications.values.filter(notification => notification.tracked)

  NotificationServer {
    id: notifactionServer
    onNotification: (notification) => {
      notification.tracked = true
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
