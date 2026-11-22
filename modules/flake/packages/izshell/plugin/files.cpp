#include "files.hpp"

#include <QDir>
#include <QFile>

bool Files::mkdir(const QString& path) {
  return QDir().mkpath(path);
}

bool Files::remove(const QString& path) {
  return QFile::remove(path) || !QFile::exists(path);
}

QStringList Files::list(const QString& path) {
  return QDir(path).entryList(QDir::AllEntries | QDir::NoDotAndDotDot, QDir::Name);
}
