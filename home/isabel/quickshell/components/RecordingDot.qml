import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

Item {
  id: root

  readonly property var micApps: [...new Set(Pipewire.micUsers.map(n => n.properties?.["application.name"] || n.name))]
  readonly property bool sharing: Pipewire.screenShares.length > 0

  visible: micApps.length > 0 || sharing
  Layout.alignment: Qt.AlignHCenter
  implicitWidth: 30
  implicitHeight: column.implicitHeight + 8

  Column {
    id: column
    anchors.centerIn: parent
    spacing: 4

    MyIcon {
      visible: root.micApps.length > 0
      icon: "audio-input-microphone-symbolic"
      size: 14
      color: Settings.colors.red
    }

    MyIcon {
      visible: root.sharing
      icon: "video-display-symbolic"
      size: 14
      color: Settings.colors.red
    }
  }

  Rectangle {
    anchors { top: parent.top; right: parent.right; rightMargin: 4 }
    width: 6
    height: 6
    color: Settings.colors.red

    SequentialAnimation on opacity {
      running: root.visible && Settings.animNormal > 0
      loops: Animation.Infinite
      NumberAnimation { to: 0.25; duration: 900; easing.type: Easing.InOutSine }
      NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
    }
  }

  BarTooltip {
    text: [
      root.micApps.length ? `Microphone: ${root.micApps.join(", ")}` : "",
      root.sharing ? "Screen is being shared" : "",
    ].filter(s => s).join("\n")
  }
}
