#pragma once

#include <QDBusServiceWatcher>
#include <QJSValue>
#include <QObject>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>

// D-Bus method calls from QML, for the services Quickshell has no type for
// (logind, systemd, AccountsService). Asynchronous: nothing blocks the shell.
class DBus : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  explicit DBus(QObject* parent = nullptr): QObject(parent) {}

  // `bus` is "system" or "session". JavaScript has one number type, so
  // `signature` gives each argument's D-Bus type, busctl style: "ssu" for two
  // strings and a uint32. Basic types only (s o b y n q i u x t d).
  // `callback(result, error)` gets the reply (its only value, or a list) and ""
  // or the error message.
  Q_INVOKABLE void call(const QString& bus, const QString& service, const QString& path,
      const QString& interface, const QString& method, const QString& signature = {},
      const QVariantList& args = {}, const QJSValue& callback = {});
};

// Whether a name is on the bus, kept current.
class DBusWatcher : public QObject {
  Q_OBJECT
  QML_ELEMENT
  Q_PROPERTY(QString bus READ bus WRITE setBus NOTIFY busChanged)
  Q_PROPERTY(QString service READ service WRITE setService NOTIFY serviceChanged)
  Q_PROPERTY(bool registered READ registered NOTIFY registeredChanged)

public:
  explicit DBusWatcher(QObject* parent = nullptr);

  QString bus() const { return m_bus; }
  void setBus(const QString& bus);
  QString service() const { return m_service; }
  void setService(const QString& service);
  bool registered() const { return m_registered; }

signals:
  void busChanged();
  void serviceChanged();
  void registeredChanged();

private:
  void rewatch();
  void setRegistered(bool registered);

  QString m_bus = QStringLiteral("session");
  QString m_service;
  bool m_registered = false;
  QDBusServiceWatcher* m_watcher = nullptr;
};
