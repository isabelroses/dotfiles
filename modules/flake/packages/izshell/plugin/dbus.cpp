#include "dbus.hpp"

#include <QDBusConnection>
#include <QDBusConnectionInterface>
#include <QDBusMessage>
#include <QDBusObjectPath>
#include <QDBusPendingCallWatcher>
#include <QDBusVariant>
#include <QQmlEngine>

namespace {

QDBusConnection connectionFor(const QString& bus) {
  return bus == QLatin1String("system") ? QDBusConnection::systemBus() : QDBusConnection::sessionBus();
}

// give a JS value the D-Bus type its signature letter names
QVariant typed(const QVariant& value, QChar type) {
  switch (type.unicode()) {
  case 's': return value.toString();
  case 'o': return QVariant::fromValue(QDBusObjectPath(value.toString()));
  case 'b': return value.toBool();
  case 'y': return QVariant::fromValue(static_cast<uchar>(value.toUInt()));
  case 'n': return QVariant::fromValue(static_cast<short>(value.toInt()));
  case 'q': return QVariant::fromValue(static_cast<ushort>(value.toUInt()));
  case 'i': return value.toInt();
  case 'u': return value.toUInt();
  case 'x': return value.toLongLong();
  case 't': return value.toULongLong();
  case 'd': return value.toDouble();
  default: return value;
  }
}

// and back: object paths and variants become plain values JS can use
QVariant plain(const QVariant& value) {
  if (value.metaType() == QMetaType::fromType<QDBusObjectPath>())
    return value.value<QDBusObjectPath>().path();
  if (value.metaType() == QMetaType::fromType<QDBusVariant>()) return plain(value.value<QDBusVariant>().variant());
  return value;
}

} // namespace

void DBus::call(const QString& bus, const QString& service, const QString& path, const QString& interface,
    const QString& method, const QString& signature, const QVariantList& args, const QJSValue& callback) {
  auto message = QDBusMessage::createMethodCall(service, path, interface, method);
  QVariantList typedArgs;
  for (qsizetype i = 0; i < args.size(); ++i)
    typedArgs << (i < signature.size() ? typed(args[i], signature[i]) : args[i]);
  message.setArguments(typedArgs);

  auto* watcher = new QDBusPendingCallWatcher(connectionFor(bus).asyncCall(message), this);
  connect(watcher, &QDBusPendingCallWatcher::finished, this, [this, watcher, callback]() {
    watcher->deleteLater();
    if (!callback.isCallable()) return;
    auto* engine = qjsEngine(this);
    if (!engine) return;

    const auto reply = watcher->reply();
    QVariant result;
    QString error;
    if (reply.type() == QDBusMessage::ErrorMessage) {
      error = reply.errorMessage().isEmpty() ? reply.errorName() : reply.errorMessage();
    } else {
      QVariantList values;
      for (const auto& v: reply.arguments()) values << plain(v);
      result = values.size() == 1 ? values.first() : QVariant(values);
    }
    QJSValue(callback).call({ engine->toScriptValue(result), QJSValue(error) });
  });
}

DBusWatcher::DBusWatcher(QObject* parent): QObject(parent) {}

void DBusWatcher::setBus(const QString& bus) {
  if (bus == m_bus) return;
  m_bus = bus;
  emit busChanged();
  rewatch();
}

void DBusWatcher::setService(const QString& service) {
  if (service == m_service) return;
  m_service = service;
  emit serviceChanged();
  rewatch();
}

void DBusWatcher::rewatch() {
  delete m_watcher;
  m_watcher = nullptr;
  if (m_service.isEmpty()) return setRegistered(false);

  auto connection = connectionFor(m_bus);
  m_watcher = new QDBusServiceWatcher(m_service, connection,
      QDBusServiceWatcher::WatchForRegistration | QDBusServiceWatcher::WatchForUnregistration, this);
  connect(m_watcher, &QDBusServiceWatcher::serviceRegistered, this, [this]() { setRegistered(true); });
  connect(m_watcher, &QDBusServiceWatcher::serviceUnregistered, this, [this]() { setRegistered(false); });
  setRegistered(connection.interface() && connection.interface()->isServiceRegistered(m_service).value());
}

void DBusWatcher::setRegistered(bool registered) {
  if (registered == m_registered) return;
  m_registered = registered;
  emit registeredChanged();
}
