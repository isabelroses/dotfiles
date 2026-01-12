pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  // modified from
  // <https://github.com/caelestia-dots/shell/blob/3bb58e6da8f9bf465e6cd5517c46c4a0667c0e07/utils/Icons.qml#L215-L218>
  function getIcon(icon: string): string {
    if (icon.includes("?path=")) {
      const [name, path] = icon.split("?path=");
      icon = Qt.resolvedUrl(`${path}/${name.slice(name.lastIndexOf("/") + 1)}`);
    }

    return icon;
  }
}
