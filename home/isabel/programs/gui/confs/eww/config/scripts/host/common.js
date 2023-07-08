import { Gio } from './lib.js'

function showNotification(title, message) {
  let notification = new Gio.Notification();
  notification.set_title(title);
  notification.set_body(message);
  notification.set_priority(Gio.NotificationPriority.NORMAL);
  let application = new Gio.Application({
    application_id: 'com.github.isabel.system',
    flags: Gio.ApplicationFlags.FLAGS_NONE
  });
  application.register(null);
  application.send_notification(null, notification);
  GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 2, () => {
    application.quit();
    return GLib.SOURCE_REMOVE;
  });
}
