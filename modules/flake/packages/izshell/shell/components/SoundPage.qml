import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Pipewire as Pw
import qs.data
import qs.services

// Settings page for audio: devices with volume and port; which device
// each app plays to or records from; and each sound card's profile.
ColumnLayout {
  id: root

  spacing: 10

  Component.onCompleted: AudioCards.watching = true
  Component.onDestruction: AudioCards.watching = false

  Pw.PwObjectTracker { objects: [...Pipewire.sinks, ...Pipewire.sources] }

  readonly property var sinkOptions: Pipewire.sinks.map(n => ({ value: n, label: Pipewire.nodeName(n) }))
  readonly property var sourceOptions: Pipewire.sources.map(n => ({ value: n, label: Pipewire.nodeName(n) }))

  SectionLabel { text: "Output devices"; size: 16 }
  Repeater {
    model: Pipewire.sinks
    DeviceRow { isDefault: modelData === Pipewire.sink; onMakeDefault: Pipewire.setDefaultSink(modelData) }
  }

  SectionLabel { text: "Input devices"; size: 16; Layout.topMargin: 10 }
  Repeater {
    model: Pipewire.sources
    DeviceRow { isDefault: modelData === Pipewire.source; onMakeDefault: Pipewire.setDefaultSource(modelData) }
  }

  SectionLabel { text: "Playback"; size: 16; Layout.topMargin: 10 }
  Empty { visible: Pipewire.streams.length === 0; text: "No apps are playing sound" }
  Repeater { model: Pipewire.streams; StreamRow { options: root.sinkOptions; outgoing: true } }

  SectionLabel { text: "Recording"; size: 16; Layout.topMargin: 10 }
  Empty { visible: Pipewire.micUsers.length === 0; text: "No apps are recording" }
  Repeater { model: Pipewire.micUsers; StreamRow { options: root.sourceOptions; outgoing: false } }

  SectionLabel { text: "Cards"; size: 16; Layout.topMargin: 10 }
  Repeater {
    model: AudioCards.cards

    SettingsBlock {
      required property var modelData

      RowLayout {
        Layout.fillWidth: true
        spacing: 12

        StyledText {
          Layout.fillWidth: true
          text: modelData.name
          font.pixelSize: 13
          font.weight: Font.Medium
        }

        Dropdown {
          implicitWidth: 300
          options: modelData.profiles.map(p => ({ value: p.index, label: p.description }))
          value: modelData.profile
          onPicked: (index) => AudioCards.setProfile(modelData, index)
        }
      }
    }
  }

  component Empty: StyledText {
    Layout.leftMargin: 2
    color: Theme.colors.textMuted
    font.pixelSize: 12
  }

  // a sink or source: name, default, volume, port
  component DeviceRow: SettingsBlock {
    id: dev
    required property Pw.PwNode modelData
    property bool isDefault: false
    readonly property bool muted: modelData?.audio?.muted ?? false
    readonly property var ports: AudioCards.portsFor(modelData)
    signal makeDefault()

    RowLayout {
      Layout.fillWidth: true
      spacing: 10

      MyIcon {
        icon: dev.modelData.isSink ? Pipewire.nodeIcon(dev.modelData) : Pipewire.inputIcon(dev.modelData)
        size: 16
        color: dev.isDefault ? Theme.colors.accent : Theme.colors.textMuted
      }

      StyledText {
        Layout.fillWidth: true
        text: Pipewire.nodeName(dev.modelData)
        font.pixelSize: 13
        font.weight: Font.Medium
      }

      StyledText {
        visible: dev.isDefault
        text: "Default"
        color: Theme.colors.accent
        font.pixelSize: 11
        font.weight: Font.DemiBold
      }

      BoxButton {
        visible: !dev.isDefault
        implicitHeight: 26
        fontSize: 11
        text: "Make default"
        onClicked: dev.makeDefault()
      }
    }

    RowLayout {
      Layout.fillWidth: true
      spacing: 10

      ColumnLayout {
        Layout.fillWidth: true
        spacing: 4

        ThinSlider {
          Layout.fillWidth: true
          tint: dev.muted ? Theme.colors.textSubtle : Theme.colors.accent
          value: dev.modelData?.audio?.volume ?? 0
          onMoved: if (dev.modelData?.audio) dev.modelData.audio.volume = value
        }
      }

      Caption {
        Layout.preferredWidth: 36
        horizontalAlignment: Text.AlignRight
        text: dev.muted ? "—" : Math.round((dev.modelData?.audio?.volume ?? 0) * 100) + "%"
        mono: true
      }

      IconButton {
        icon: dev.muted ? "audio-volume-muted-symbolic" : "audio-volume-high-symbolic"
        size: 14
        color: dev.muted ? Theme.colors.error : Theme.colors.textMuted
        onClicked: if (dev.modelData?.audio) dev.modelData.audio.muted = !dev.muted
      }
    }

    RowLayout {
      visible: dev.ports.options.length > 1
      Layout.fillWidth: true
      spacing: 10

      StyledText {
        Layout.fillWidth: true
        text: "Port"
        color: Theme.colors.textMuted
        font.pixelSize: 12
      }

      Dropdown {
        options: dev.ports.options.map(p => ({ value: p.index, label: p.description }))
        value: dev.ports.current
        onPicked: (index) => AudioCards.setPort(dev.modelData, index)
      }
    }
  }

  // an app's stream, with the device it plays to or records from
  component StreamRow: SettingsBlock {
    id: stream
    required property Pw.PwNode modelData
    property var options: []
    property bool outgoing: true
    readonly property Pw.PwNode device: {
      const groups = links.linkGroups ?? [];
      const g = groups.find(g => outgoing ? g.source === modelData : g.target === modelData);
      return g ? (outgoing ? g.target : g.source) : null;
    }

    Pw.PwNodeLinkTracker { id: links; node: stream.modelData }

    RowLayout {
      Layout.fillWidth: true
      spacing: 12

      AppVolumeRow {
        visible: stream.outgoing
        Layout.fillWidth: true
        node: stream.modelData
        tint: Theme.colors.accent
      }

      IconImage {
        visible: !stream.outgoing
        asynchronous: true
        implicitSize: 18
        Layout.leftMargin: 6
        source: Quickshell.iconPath(Pipewire.streamIcon(stream.modelData), "audio-input-microphone-symbolic")
      }

      StyledText {
        visible: !stream.outgoing
        Layout.fillWidth: true
        text: Pipewire.streamName(stream.modelData)
        font.pixelSize: 12
      }

      Dropdown {
        implicitWidth: 240
        options: stream.options
        value: stream.device
        onPicked: (target) => Pipewire.moveStream(stream.modelData, target)
      }
    }
  }
}
