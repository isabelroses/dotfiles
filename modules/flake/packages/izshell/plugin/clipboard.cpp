#include "clipboard.hpp"

#include <QFile>
#include <QLoggingCategory>
#include <cerrno>
#include <cstring>
#include <fcntl.h>
#include <unistd.h>
#include <wayland-client.h>

#include "ext-data-control-v1-client.h"

Q_LOGGING_CATEGORY(logClipboard, "izshell.clipboard")

namespace {

void onGlobal(void* data, wl_registry* registry, uint32_t name, const char* interface, uint32_t) {
  static_cast<Clipboard*>(data)->addGlobal(registry, name, interface);
}

void onGlobalRemove(void*, wl_registry*, uint32_t) {}

const wl_registry_listener registryListener = { onGlobal, onGlobalRemove };

// Offers (other clients', and our own echoed back) are never read: they only
// need a listener for libwayland to accept their events, and destroying.
void onOfferMime(void*, ext_data_control_offer_v1*, const char*) {}
const ext_data_control_offer_v1_listener offerListener = { onOfferMime };

void onDataOffer(void*, ext_data_control_device_v1*, ext_data_control_offer_v1* offer) {
  ext_data_control_offer_v1_add_listener(offer, &offerListener, nullptr);
}

void onSelection(void*, ext_data_control_device_v1*, ext_data_control_offer_v1* offer) {
  if (offer) ext_data_control_offer_v1_destroy(offer);
}

void onFinished(void* data, ext_data_control_device_v1*) {
  static_cast<Clipboard*>(data)->deviceFinished();
}

const ext_data_control_device_v1_listener deviceListener = { onDataOffer, onSelection, onFinished, onSelection };

void onSend(void* data, ext_data_control_source_v1*, const char*, int32_t fd) {
  static_cast<Clipboard*>(data)->send(fd);
}

void onCancelled(void* data, ext_data_control_source_v1* source) {
  static_cast<Clipboard*>(data)->cancelled(source);
}

const ext_data_control_source_v1_listener sourceListener = { onSend, onCancelled };

} // namespace

Clipboard::Clipboard(QObject* parent): QObject(parent) {
  m_display = wl_display_connect(nullptr);
  if (!m_display) {
    qCWarning(logClipboard) << "no Wayland display; the clipboard is unavailable";
    return;
  }

  auto* registry = wl_display_get_registry(m_display);
  wl_registry_add_listener(registry, &registryListener, this);
  wl_display_roundtrip(m_display);
  wl_registry_destroy(registry);

  if (!m_seat || !m_manager) {
    qCWarning(logClipboard) << "the compositor has no ext-data-control-v1; the clipboard is unavailable";
    return;
  }

  m_device = ext_data_control_manager_v1_get_data_device(m_manager, m_seat);
  ext_data_control_device_v1_add_listener(m_device, &deviceListener, this);
  wl_display_flush(m_display);

  m_notifier = new QSocketNotifier(wl_display_get_fd(m_display), QSocketNotifier::Read, this);
  connect(m_notifier, &QSocketNotifier::activated, this, &Clipboard::dispatch);
}

Clipboard::~Clipboard() {
  if (!m_display) return;
  if (m_source) ext_data_control_source_v1_destroy(m_source);
  if (m_device) ext_data_control_device_v1_destroy(m_device);
  if (m_manager) ext_data_control_manager_v1_destroy(m_manager);
  if (m_seat) wl_seat_destroy(m_seat);
  wl_display_disconnect(m_display);
}

void Clipboard::addGlobal(wl_registry* registry, uint32_t name, const char* interface) {
  if (!m_seat && strcmp(interface, wl_seat_interface.name) == 0)
    m_seat = static_cast<wl_seat*>(wl_registry_bind(registry, name, &wl_seat_interface, 1));
  else if (!m_manager && strcmp(interface, ext_data_control_manager_v1_interface.name) == 0)
    m_manager = static_cast<ext_data_control_manager_v1*>(
        wl_registry_bind(registry, name, &ext_data_control_manager_v1_interface, 1));
}

bool Clipboard::setImage(const QString& path) {
  QFile file(path);
  if (!file.open(QIODevice::ReadOnly)) {
    qCWarning(logClipboard) << "can't read" << path;
    return false;
  }
  return offer({ "image/png" }, file.readAll());
}

bool Clipboard::setText(const QString& text) {
  return offer({ "text/plain;charset=utf-8", "text/plain", "UTF8_STRING", "STRING", "TEXT" }, text.toUtf8());
}

bool Clipboard::offer(const QList<QByteArray>& mimes, const QByteArray& data) {
  if (!m_device) return false;
  if (m_source) ext_data_control_source_v1_destroy(m_source);

  m_data = data;
  m_source = ext_data_control_manager_v1_create_data_source(m_manager);
  ext_data_control_source_v1_add_listener(m_source, &sourceListener, this);
  for (const auto& mime: mimes) ext_data_control_source_v1_offer(m_source, mime.constData());
  ext_data_control_device_v1_set_selection(m_device, m_source);
  wl_display_flush(m_display);
  return true;
}

void Clipboard::send(int fd) {
  // a reader can be slow; a blocking write keeps this simple and the data is small
  fcntl(fd, F_SETFL, fcntl(fd, F_GETFL) & ~O_NONBLOCK);
  const char* p = m_data.constData();
  qsizetype left = m_data.size();
  while (left > 0) {
    const auto n = write(fd, p, static_cast<size_t>(left));
    if (n < 0 && errno == EINTR) continue;
    if (n <= 0) {
      qCWarning(logClipboard) << "writing the clipboard failed:" << strerror(errno);
      break;
    }
    p += n;
    left -= n;
  }
  close(fd);
}

void Clipboard::cancelled(ext_data_control_source_v1* source) {
  ext_data_control_source_v1_destroy(source);
  if (source != m_source) return;
  m_source = nullptr;
  m_data.clear();
}

void Clipboard::dispatch() {
  while (wl_display_prepare_read(m_display) != 0) wl_display_dispatch_pending(m_display);
  wl_display_read_events(m_display);
  wl_display_dispatch_pending(m_display);
  wl_display_flush(m_display);
}

// the seat went away; copying stops working until the shell restarts
void Clipboard::deviceFinished() {
  ext_data_control_device_v1_destroy(m_device);
  m_device = nullptr;
}
