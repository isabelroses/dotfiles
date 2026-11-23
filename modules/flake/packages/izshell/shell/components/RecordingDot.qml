import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

// Mic and screen-share activity. On its own it gets a bar card; in compact
// mode it's the small icon in the status capsule, next to the volume.
Item {
  id: root

  property bool compact: false

  readonly property list<string> micApps: [...new Set(Pipewire.micUsers.map(n => n.properties?.["application.name"] || n.name))]
  readonly property bool sharing: Pipewire.screenShares.length > 0
  readonly property bool micLive: micApps.length > 0 && !Pipewire.sourceMuted
  readonly property bool live: micLive || sharing
  readonly property color micTint: Pipewire.sourceMuted ? Theme.colors.textSubtle : Theme.colors.red
  readonly property color tint: micApps.length > 0 ? micTint
    : sharing ? Theme.colors.red : Theme.colors.textSubtle
  readonly property string statusIcon: micApps.length > 0
    ? Pipewire.sourceMuted ? "microphone-sensitivity-muted-symbolic" : "audio-input-microphone-symbolic"
    : "video-display-symbolic"
  readonly property string muteHint: compact ? "" : `\nClick to ${Pipewire.sourceMuted ? "unmute" : "mute"}`
  readonly property string micTooltip: micApps.length
    ? `Microphone${Pipewire.sourceMuted ? " (muted)" : ""}: ${micApps.join(", ")}${muteHint}`
    : ""

  visible: micApps.length > 0 || sharing
  Layout.alignment: Qt.AlignCenter
  implicitWidth: compact ? 16 : 30
  implicitHeight: compact ? 16 : column.implicitHeight + 8

  Column {
    id: column
    visible: !root.compact
    anchors.centerIn: parent
    spacing: 4

    Clickable {
      id: mic
      visible: root.micApps.length > 0
      width: 22
      height: 22
      anchors.horizontalCenter: parent.horizontalCenter
      radius: Theme.radiusXs
      color: mic.hovered ? Utils.withAlpha(root.micTint, 0.18) : "transparent"
      onClicked: Pipewire.toggleSourceMute()


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
      color: Theme.colors.red
    }
  }

  MyIcon {
    visible: root.compact
    anchors.centerIn: parent
    icon: root.statusIcon
    size: 16
    color: root.tint
  }

  Rectangle {
    id: dot
    anchors {
      top: parent.top
      right: parent.right
      topMargin: root.compact ? -2 : 0
      rightMargin: root.compact ? -2 : 4
    }
    width: root.compact ? 7 : 6
    height: width
    radius: root.compact ? Theme.pill(width) : 0
    color: root.live ? Theme.colors.red : Theme.colors.textSubtle
    border.color: Theme.colors.surface
    border.width: root.compact ? 1.5 : 0

    SequentialAnimation on opacity {
      running: root.visible && root.live && Theme.animNormal > 0
      onRunningChanged: if (!running) dot.opacity = 1
      loops: Animation.Infinite
      NumberAnimation { to: 0.25; duration: 900; easing.type: Easing.InOutSine }
      NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
    }
  }

  BarTooltip {
    text: [
      root.micTooltip,
      root.sharing ? "Screen is being shared" : "",
    ].filter(s => s).join("\n")
  }
}
