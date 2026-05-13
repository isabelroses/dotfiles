pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  function toggleQuickSettings() {
      quickSettingsOpen = !quickSettingsOpen;
  }
  property bool quickSettingsOpen: false
}
