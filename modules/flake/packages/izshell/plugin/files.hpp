#pragma once

#include <QObject>
#include <QStringList>
#include <QtQml/qqmlregistration.h>

// The file operations FileView doesn't cover.
class Files : public QObject {
  Q_OBJECT
  QML_ELEMENT
  QML_SINGLETON

public:
  explicit Files(QObject* parent = nullptr): QObject(parent) {}

  // creates parent directories too; true if the directory exists afterwards
  Q_INVOKABLE static bool mkdir(const QString& path);
  // true if the file is gone afterwards, including when it never existed
  Q_INVOKABLE static bool remove(const QString& path);
  // the names in a directory, sorted; empty if it can't be read
  Q_INVOKABLE static QStringList list(const QString& path);
};
