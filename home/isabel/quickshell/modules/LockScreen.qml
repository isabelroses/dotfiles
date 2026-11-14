import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Pam
import Quickshell.Io
import qs.data
import qs.components
import qs.services

Scope {
  id: root

  property string buffer: ""
  property string message: ""
  property bool failed: false
  readonly property bool busy: pam.active
  property bool hasOwnPamConfig: false

  FileView {
    path: "/etc/pam.d/quickshell"
    printErrors: false
    onLoaded: root.hasOwnPamConfig = true
    onLoadFailed: root.hasOwnPamConfig = false
  }

  function submit(): void {
    if (buffer === "" || pam.active) return;
    message = "";
    failed = false;
    pam.start();
  }

  Connections {
    target: Runtime
    function onLockedChanged() {
      if (Runtime.locked) {
        root.buffer = "";
        root.message = "";
        root.failed = false;
      }
    }
  }

  PamContext {
    id: pam
    config: root.hasOwnPamConfig ? "quickshell" : "login"

    onPamMessage: {
      if (responseRequired) respond(root.buffer);
      else if (messageIsError) root.message = message;
    }

    onCompleted: (result) => {
      if (result === PamResult.Success) {
        root.buffer = "";
        Runtime.locked = false;
      } else {
        root.buffer = "";
        root.failed = true;
        root.message = "Wrong password";
      }
    }

    onError: (error) => {
      root.buffer = "";
      root.failed = true;
      root.message = PamError.toString(error);
    }
  }

  IdleMonitor {
    enabled: Config.get("lock.idle_minutes") > 0 && !Runtime.locked
    timeout: Config.get("lock.idle_minutes") * 60
    respectInhibitors: true
    onIsIdleChanged: if (isIdle) Runtime.lock()
  }

  WlSessionLock {
    id: lock
    locked: Runtime.locked

    WlSessionLockSurface {
      id: surface
      color: Settings.colors.base

      Image {
        id: wallpaper
        anchors.fill: parent
        source: Settings.wallpaper
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        visible: false
      }

      MultiEffect {
        anchors.fill: parent
        source: wallpaper
        visible: wallpaper.status === Image.Ready
        blurEnabled: true
        blur: 1.0
        blurMax: 64
        brightness: -0.35
        saturation: -0.2
      }

      Rectangle {
        anchors.fill: parent
        color: Qt.rgba(0, 0, 0, 0.35)
      }

      ColumnLayout {
        id: content
        anchors.centerIn: parent
        spacing: 18

        opacity: 0
        Component.onCompleted: opacity = 1
        Behavior on opacity { NumberAnimation { duration: Settings.animNormal * 2 } }

        ColumnLayout {
          Layout.alignment: Qt.AlignHCenter
          spacing: 0

          StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: `${Time.hours}:${Time.minutes}`
            mono: true
            font.pixelSize: 96
            font.weight: Font.Bold
          }

          StyledText {
            Layout.alignment: Qt.AlignHCenter
            text: Time.longDate + (Time.period ? ` · ${Time.period}` : "")
            color: Settings.colors.textMuted
            font.pixelSize: 16
          }
        }

        Item { implicitHeight: 24 }

        ClippingWrapperRectangle {
          Layout.alignment: Qt.AlignHCenter
          implicitWidth: 80
          implicitHeight: 80
          radius: Settings.radiusRound
          color: Settings.colors.overlay
          border.color: root.failed ? Settings.colors.red : Settings.colors.accent
          border.width: 2

          Image {
            source: Settings.profilePicture
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            mipmap: true
            sourceSize: Qt.size(160, 160)
          }
        }

        StyledText {
          Layout.alignment: Qt.AlignHCenter
          text: Settings.username
          font.pixelSize: 15
          font.weight: Font.DemiBold
        }

        InputField {
          id: field
          Layout.alignment: Qt.AlignHCenter
          implicitWidth: 300
          implicitHeight: 44
          color: Settings.colors.base
          password: true
          revealable: false
          mono: true
          fontSize: 14
          error: root.failed
          enabled: !root.busy
          placeholder: root.busy ? "Checking…" : "Password"
          text: root.buffer
          onTextChanged: {
            if (text !== root.buffer) root.buffer = text;
            if (text !== "") root.failed = false;
          }
          onAccepted: root.submit()
          onEscaped: root.buffer = ""
          Component.onCompleted: takeFocus()

          Connections {
            target: root
            function onFailedChanged() {
              if (!root.failed) return;
              field.shake();
              field.takeFocus();
            }
          }

          BoxButton {
            implicitHeight: 32
            icon: "go-next-symbolic"
            fontSize: 11
            filled: root.buffer !== ""
            border.width: 0
            onClicked: root.submit()
          }
        }

        Rectangle {
          id: notiCount
          readonly property int count: Notifications.list.length
          Layout.alignment: Qt.AlignHCenter
          visible: Config.get("lock.notification_count") && count > 0
          implicitWidth: countRow.implicitWidth + 20
          implicitHeight: 28
          radius: Settings.radiusSm
          color: Qt.rgba(0, 0, 0, 0.5)
          border.width: 1
          border.color: Settings.colors.border

          RowLayout {
            id: countRow
            anchors.centerIn: parent
            spacing: 8

            MyIcon {
              icon: "preferences-system-notifications-symbolic"
              size: 13
              color: Settings.colors.accent
            }

            StyledText {
              text: notiCount.count === 1 ? "1 notification" : `${notiCount.count} notifications`
              font.pixelSize: 12
            }
          }
        }

        StyledText {
          Layout.alignment: Qt.AlignHCenter
          Layout.preferredHeight: 16
          text: root.message
          color: root.failed ? Settings.colors.red : Settings.colors.textMuted
          font.pixelSize: 12
        }
      }

      Rectangle {
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 40 }
        visible: Media.selectedPlayer !== null
        implicitWidth: mediaRow.implicitWidth + 24
        implicitHeight: 44
        radius: Settings.radiusSm
        color: Qt.rgba(0, 0, 0, 0.5)
        border.width: 1
        border.color: Settings.colors.border

        RowLayout {
          id: mediaRow
          anchors.centerIn: parent
          spacing: 10

          StyledText {
            Layout.maximumWidth: 320
            text: `${Media.selectedPlayer?.trackTitle ?? ""}${Media.selectedPlayer?.trackArtist ? " — " + Media.selectedPlayer.trackArtist : ""}`
            font.pixelSize: 12
            elide: Text.ElideRight
          }

          IconButton {
            icon: "media-skip-backward-symbolic"
            size: 12
            enabled: Media.selectedPlayer?.canGoPrevious ?? false
            onClicked: Media.selectedPlayer.previous()
          }

          IconButton {
            icon: Media.selectedPlayer?.isPlaying ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"
            size: 14
            color: Settings.colors.accent
            onClicked: Media.selectedPlayer.togglePlaying()
          }

          IconButton {
            icon: "media-skip-forward-symbolic"
            size: 12
            enabled: Media.selectedPlayer?.canGoNext ?? false
            onClicked: Media.selectedPlayer.next()
          }
        }
      }
    }
  }
}
