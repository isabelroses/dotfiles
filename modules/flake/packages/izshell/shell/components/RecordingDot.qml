import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

Item {
  id: root

  readonly property list<string> micApps: [...new Set(Pipewire.micUsers.map(n => n.properties?.["application.name"] || n.name))]
  readonly property bool sharing: Pipewire.screenShares.length > 0
  readonly property bool micLive: micApps.length > 0 && !Pipewire.sourceMuted
  readonly property color micTint: Pipewire.sourceMuted ? Settings.colors.textSubtle : Settings.colors.red

  visible: micApps.length > 0 || sharing
  Layout.alignment: Qt.AlignCenter
  implicitWidth: 30
  implicitHeight: column.implicitHeight + 8

  Column {
    id: column
    anchors.centerIn: parent
    spacing: 4

    Clickable {
      id: mic
      visible: root.micApps.length > 0
      width: 22
      height: 22
      anchors.horizontalCenter: parent.horizontalCenter
      radius: Settings.radiusXs
      color: mic.hovered ? Utils.withAlpha(root.micTint, 0.18) : "transparent"
      onClicked: Pipewire.toggleSourceMute()

      Behavior on color { ColorAnimation { duration: Settings.animFast } }

      MyIcon {
        anchors.centerIn: parent
        icon: Pipewire.sourceMuted ? "microphone-sensitivity-muted-symbolic" : "audio-input-microphone-symbolic"
        size: 14
        color: root.micTint
      }
    }

    MyIcon {
      visible: root.sharing
      anchors.horizontalCenter: parent.horizontalCenter
      icon: "video-display-symbolic"
      size: 14
      color: Settings.colors.red
    }
  }

  Rectangle {
    id: dot
    anchors { top: parent.top; right: parent.right; rightMargin: 4 }
    width: 6
    height: 6
    color: root.micLive || root.sharing ? Settings.colors.red : Settings.colors.textSubtle

    SequentialAnimation on opacity {
      running: root.visible && (root.micLive || root.sharing) && Settings.animNormal > 0
      onRunningChanged: if (!running) dot.opacity = 1
      loops: Animation.Infinite
      NumberAnimation { to: 0.25; duration: 900; easing.type: Easing.InOutSine }
      NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
    }
  }

  BarTooltip {
    text: [
      root.micApps.length ? `Microphone${Pipewire.sourceMuted ? " (muted)" : ""}: ${root.micApps.join(", ")}\nClick to ${Pipewire.sourceMuted ? "unmute" : "mute"}` : "",
      root.sharing ? "Screen is being shared" : "",
    ].filter(s => s).join("\n")
  }
}
