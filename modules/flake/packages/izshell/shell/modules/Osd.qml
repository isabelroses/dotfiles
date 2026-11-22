import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications as QsNotifications
import qs.data
import qs.components
import qs.services

Scope {
  id: root

  property bool osdShown: false
  property string osdKind: "sink" // sink | source | brightness
  readonly property bool osdMuted: osdKind === "sink" ? Pipewire.sinkMuted
    : osdKind === "source" ? Pipewire.sourceMuted
    : false
  readonly property real osdVolume: osdKind === "sink" ? Pipewire.sinkVolume
    : osdKind === "source" ? Pipewire.sourceVolume
    : Brightness.brightness
  readonly property string osdIcon: osdKind === "sink" ? Pipewire.sinkIcon
    : osdKind === "source" ? Pipewire.sourceIcon
    : Brightness.icon
  readonly property color osdTint: Settings.colors.accent

  property var currentNotification: null
  property bool toastShown: false
  readonly property int toastTimeout: Config.get("notifications.toast_timeout") * 1000

  Connections {
    target: Pipewire
    function onSinkVolumeChanged() { if (Config.get("osd.volume")) root.showOsd("sink"); }
    function onSinkMutedChanged() { if (Config.get("osd.volume")) root.showOsd("sink"); }
    function onSourceVolumeChanged() { if (Config.get("osd.mic")) root.showOsd("source"); }
    function onSourceMutedChanged() { if (Config.get("osd.mic")) root.showOsd("source"); }
  }

  Connections {
    target: Brightness
    // `available` flips true after the startup read, so that read doesn't pop the OSD
    function onBrightnessChanged() { if (Brightness.available && Config.get("osd.brightness")) root.showOsd("brightness"); }
  }

  Connections {
    target: Notifications
    function onNewNotification(notification: var): void {
      if (!Config.get("notifications.toasts")) return;
      root.currentNotification = notification;
      root.toastShown = true;
      toastProgress.restart();
    }
  }

  function showOsd(kind: string): void {
    root.osdKind = kind;
    root.osdShown = true;
    osdHideTimer.restart();
  }

  Timer {
    id: osdHideTimer
    interval: 1500
    onTriggered: root.osdShown = false
  }

  PanelWindow {
    id: osdWindow

    visible: root.osdShown || osdPill.opacity > 0
    color: "transparent"

    WlrLayershell.namespace: "osd"
    WlrLayershell.layer: WlrLayer.Overlay
    exclusionMode: ExclusionMode.Normal

    anchors.bottom: true
    margins.bottom: 48
    implicitWidth: 340
    implicitHeight: 100

    Item {
      id: osdPill
      anchors.horizontalCenter: parent.horizontalCenter
      y: root.osdShown ? 16 : 28
      width: 280
      height: 52
      opacity: root.osdShown ? 1 : 0

      Behavior on opacity { Anim {} }
      Behavior on y { Anim {} }

      CardSurface { radius: Math.min(Settings.sheetRadius, height / 2); raised: true }

      RowLayout {
        anchors { fill: parent; leftMargin: 8; rightMargin: 18 }
        spacing: 12

        IconChip {
          size: 36
          color: root.osdMuted ? Settings.colors.overlay : Utils.withAlpha(root.osdTint, 0.14)
          icon: root.osdIcon
          iconSize: 18
          iconColor: root.osdMuted ? Settings.colors.textMuted : root.osdTint
        }

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 6
          radius: Settings.pill(height)
          color: Settings.colors.overlay

          Rectangle {
            width: parent.width * Math.min(root.osdVolume, 1.0)
            height: parent.height
            radius: Settings.pill(height)
            color: root.osdMuted ? Settings.colors.textSubtle : root.osdTint

            Behavior on width { SmoothedAnimation { velocity: 600 } }
          }
        }

        StyledText {
          Layout.preferredWidth: 34
          horizontalAlignment: Text.AlignRight
          text: root.osdMuted ? "—" : Math.round(root.osdVolume * 100)
          mono: true
          font.pixelSize: 13
          font.weight: Font.Medium
        }
      }
    }
  }

  PanelWindow {
    id: toastWindow

    visible: root.currentNotification !== null && (root.toastShown || toastSlot.opacity > 0)
    color: "transparent"

    WlrLayershell.namespace: "notification"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: root.currentNotification?.hasInlineReply ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    exclusionMode: ExclusionMode.Normal

    anchors.top: true
    margins.top: 0
    implicitWidth: 448
    implicitHeight: toastSlot.implicitHeight + 56

    NumberAnimation {
      id: toastProgress
      target: countdown
      property: "fraction"
      from: 1
      to: 0
      duration: root.toastTimeout
      paused: running && (card.cardHovered || card.replyFocused)
      onFinished: root.toastShown = false
    }

    Item {
      id: toastSlot
      anchors.horizontalCenter: parent.horizontalCenter
      width: parent.width - 48
      implicitHeight: card.implicitHeight
      y: root.toastShown ? 16 : 0
      opacity: root.toastShown ? 1 : 0

      Behavior on opacity { Anim {} }
      Behavior on y { Anim {} }

      NotificationCard {
        id: card
        width: parent.width
        notification: root.currentNotification
        elevated: true
        onDismissed: root.toastShown = false
        onReplied: root.toastShown = false
        onActionInvoked: root.toastShown = false

      }

      Rectangle {
        id: countdown
        property real fraction: 1
        anchors { bottom: card.bottom; left: card.left; bottomMargin: 5; leftMargin: 12 }
        width: (card.width - 24) * fraction
        height: 2
        radius: Settings.pill(height)
        color: card.critical ? Settings.colors.error : Settings.colors.accent
        opacity: 0.6
      }
    }
  }
}
