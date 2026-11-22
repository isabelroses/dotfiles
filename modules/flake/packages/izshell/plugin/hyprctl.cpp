#include "hyprctl.hpp"

#include <QLocalSocket>
#include <QLoggingCategory>
#include <memory>

Q_LOGGING_CATEGORY(logHyprctl, "izshell.hyprctl")

void Hyprctl::request(const QString& command, const QJSValue& callback) {
  const auto path = QStringLiteral("%1/hypr/%2/.socket.sock")
                        .arg(qEnvironmentVariable("XDG_RUNTIME_DIR"), qEnvironmentVariable("HYPRLAND_INSTANCE_SIGNATURE"));

  auto* socket = new QLocalSocket(this);
  auto reply = std::make_shared<QByteArray>();
  auto done = std::make_shared<bool>(false);

  // runs once, whether Hyprland answered and hung up or the socket failed
  const auto finish = [socket, reply, done, callback](bool ok) {
    if (*done) return;
    *done = true;
    socket->deleteLater();
    if (callback.isCallable()) QJSValue(callback).call({ QJSValue(ok ? QString::fromUtf8(*reply) : QString()) });
  };

  connect(socket, &QLocalSocket::connected, socket, [socket, command]() {
    socket->write(command.toUtf8());
    socket->flush();
  });
  connect(socket, &QLocalSocket::readyRead, socket, [socket, reply]() { reply->append(socket->readAll()); });
  connect(socket, &QLocalSocket::disconnected, socket, [socket, reply, finish]() {
    reply->append(socket->readAll());
    finish(true);
  });
  connect(socket, &QLocalSocket::errorOccurred, socket, [socket, finish](QLocalSocket::LocalSocketError error) {
    // Hyprland closing the connection after answering is the normal end
    if (error == QLocalSocket::PeerClosedError) return;
    qCWarning(logHyprctl) << "request failed:" << socket->errorString();
    finish(false);
  });

  socket->connectToServer(path);
}
