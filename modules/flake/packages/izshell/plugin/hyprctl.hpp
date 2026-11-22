#pragma once

#include <QJSValue>
#include <QObject>
#include <QtQml/qqmlregistration.h>

// Requests on Hyprland's request socket, the way hyprctl sends them ("j/binds",
// "eval ..."), for what Quickshell's Hyprland types don't expose. Hyprland
// answers once and hangs up; the whole answer is handed back.
class Hyprctl : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  explicit Hyprctl(QObject* parent = nullptr): QObject(parent) {}

  // `callback(reply)` gets the answer, or "" if Hyprland can't be reached
  Q_INVOKABLE void request(const QString& command, const QJSValue& callback = {});
};
