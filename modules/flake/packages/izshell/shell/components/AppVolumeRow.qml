import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire as Pw
import qs.data
import qs.services

RowLayout {
  id: root

  required property Pw.PwNode node
  property color tint: Theme.colors.pink
  readonly property bool muted: node?.audio?.muted ?? false

  spacing: 10
  height: 40

  IconImage {
    asynchronous: true
    Layout.leftMargin: 6
    implicitSize: 18
    source: Quickshell.iconPath(Pipewire.streamIcon(root.node), "audio-x-generic-symbolic")
    opacity: root.muted ? 0.4 : 1
  }

  ColumnLayout {
    Layout.fillWidth: true
    spacing: 4

    RowLayout {
      Layout.fillWidth: true

      StyledText {
        Layout.fillWidth: true
        text: Pipewire.streamName(root.node)
        font.pixelSize: 12
        color: root.muted ? Theme.colors.textSubtle : Theme.colors.text
      }

      Caption { text: Math.round((root.node?.audio?.volume ?? 0) * 100) + "%"; mono: true }
    }

    ThinSlider {
      Layout.fillWidth: true
      tint: root.muted ? Theme.colors.textSubtle : root.tint
      value: root.node?.audio?.volume ?? 0
      onMoved: if (root.node?.audio) root.node.audio.volume = value
    }
  }

  IconButton {
    icon: root.muted ? "audio-volume-muted-symbolic" : "audio-volume-high-symbolic"
    size: 14
    color: root.muted ? Theme.colors.error : Theme.colors.textMuted
    onClicked: if (root.node?.audio) root.node.audio.muted = !root.node.audio.muted
  }
}
