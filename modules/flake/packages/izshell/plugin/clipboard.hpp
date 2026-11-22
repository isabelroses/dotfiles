#pragma once

#include <QByteArray>
#include <QList>
#include <QObject>
#include <QSocketNotifier>
#include <QtQml/qqmlregistration.h>

struct wl_display;
struct wl_registry;
struct wl_seat;
struct ext_data_control_manager_v1;
struct ext_data_control_device_v1;
struct ext_data_control_source_v1;

// The clipboard through Wayland's data-control protocol: works with no window
// focused and for images (Quickshell.clipboardText does neither). Its own Wayland
// connection, so it never touches Qt's; what was copied is served from memory
// until something else takes the clipboard.
class Clipboard : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  explicit Clipboard(QObject* parent = nullptr);
  ~Clipboard() override;


  // a PNG file, offered as image/png
  Q_INVOKABLE bool setImage(const QString& path);
  Q_INVOKABLE bool setText(const QString& text);

  // protocol callbacks
  void addGlobal(wl_registry* registry, uint32_t name, const char* interface);
  void send(int fd);
  void cancelled(ext_data_control_source_v1* source);
  void deviceFinished();

private:
  bool offer(const QList<QByteArray>& mimes, const QByteArray& data);
  void dispatch();

  wl_display* m_display = nullptr;
  wl_seat* m_seat = nullptr;
  ext_data_control_manager_v1* m_manager = nullptr;
  ext_data_control_device_v1* m_device = nullptr;
  ext_data_control_source_v1* m_source = nullptr;
  QSocketNotifier* m_notifier = nullptr;
  QByteArray m_data;
};
