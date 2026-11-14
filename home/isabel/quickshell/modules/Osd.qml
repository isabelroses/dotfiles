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
  property bool osdMic: false
  readonly property bool osdMuted: osdMic ? Pipewire.sourceMuted : Pipewire.sinkMuted
  readonly property real osdVolume: osdMic ? Pipewire.sourceVolume : Pipewire.sinkVolume
  readonly property string osdIcon: osdMic ? Pipewire.sourceIcon : Pipewire.sinkIcon

  property QsNotifications.Notification currentNotification: null
  property bool toastShown: false
  readonly property int toastTimeout: Config.get("notifications.toast_timeout") * 1000

  Connections {
    target: Pipewire
    function onSinkVolumeChanged() { if (Config.get("osd.volume")) root.showVolumeOsd(); }
    function onSinkMutedChanged() { if (Config.get("osd.volume")) root.showVolumeOsd(); }
    function onSourceMutedChanged() { if (Config.get("osd.volume")) root.showVolumeOsd(true); }
  }

  Connections {
    target: Notifications
    function onNewNotification(notification: QsNotifications.Notification): void {
      if (!Config.get("notifications.toasts")) return;
      root.currentNotification = notification;
      root.toastShown = true;
      toastProgress.restart();
    }
  }

  function showVolumeOsd(mic = false): void {
    root.osdMic = mic;
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
    exclusionMode: ExclusionMode.Ignore

    anchors.bottom: true
    margins.bottom: 72
    implicitWidth: 300
    implicitHeight: 64

    Rectangle {
      id: osdPill
      anchors.horizontalCenter: parent.horizontalCenter
      y: root.osdShown ? 4 : 16
      width: 280
      height: 52
      radius: Settings.rounding
      color: Settings.colors.base
      border.color: Settings.colors.borderStrong
      border.width: 1
      opacity: root.osdShown ? 1 : 0

      Behavior on opacity { NumberAnimation { duration: Settings.animNormal } }
      Behavior on y { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic } }

      RowLayout {
        anchors { fill: parent; leftMargin: 8; rightMargin: 18 }
        spacing: 12

        IconChip {
          size: 36
          color: root.osdMuted ? Settings.colors.overlay : Settings.colors.accentSoft
          icon: root.osdIcon
          iconSize: 18
          iconColor: root.osdMuted ? Settings.colors.textMuted : Settings.colors.accent
        }

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 6
          radius: 0
          color: Settings.colors.overlay

          Rectangle {
            width: parent.width * Math.min(root.osdVolume, 1.0)
            height: parent.height
            radius: 0
            color: root.osdMuted ? Settings.colors.textSubtle : Settings.colors.accent

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
    exclusionMode: ExclusionMode.Ignore

    anchors.top: true
    margins.top: 12
    implicitWidth: 400
    implicitHeight: toastSlot.implicitHeight + 16

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
      width: parent.width - 16
      implicitHeight: card.implicitHeight
      y: root.toastShown ? 4 : -12
      opacity: root.toastShown ? 1 : 0

      Behavior on opacity { NumberAnimation { duration: Settings.animNormal } }
      Behavior on y { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic } }

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
        anchors { bottom: card.bottom; left: card.left; bottomMargin: 1; leftMargin: Settings.radiusMd }
        width: (card.width - Settings.radiusMd * 2) * fraction
        height: 2
        radius: 0
        color: card.critical ? Settings.colors.error : Settings.colors.accent
        opacity: 0.8
      }
    }
  }
}
