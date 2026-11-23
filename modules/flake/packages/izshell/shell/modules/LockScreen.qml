import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
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
    target: Session
    function onLockedChanged(): void {
      if (Session.locked) {
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
        Session.unlock();
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


  // suspend waits for this: the compositor says the lock is up
  Binding {
    target: Session
    property: "lockConfirmed"
    value: lock.secure
  }

  WlSessionLock {
    id: lock
    locked: Session.locked

    WlSessionLockSurface {
      id: surface
      color: Theme.colors.base

      Image {
        id: wallpaper
        anchors.fill: parent
        source: Settings.general.wallpaper
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

      Rectangle { anchors.fill: parent; color: Qt.rgba(0, 0, 0, 0.35) }

      LoginPrompt {
        anchors.centerIn: parent
        buffer: root.buffer
        onEdited: (text) => { root.buffer = text; if (text !== "") root.failed = false; }
        busy: root.busy
        failed: root.failed
        message: root.message
        onSubmitted: root.submit()

        Rectangle {
          id: notiCount
          readonly property int count: Notifications.list.length
          Layout.alignment: Qt.AlignHCenter
          visible: Settings.lock.notification_count && count > 0
          implicitWidth: countRow.implicitWidth + 20
          implicitHeight: 28
          radius: Theme.radiusSm
          color: Qt.rgba(0, 0, 0, 0.5)
          border.width: 1
          border.color: Theme.colors.border

          RowLayout {
            id: countRow
            anchors.centerIn: parent
            spacing: 8

            MyIcon {
              icon: "preferences-system-notifications-symbolic"
              size: 13
              color: Theme.colors.accent
            }

            StyledText {
              text: notiCount.count === 1 ? "1 notification" : `${notiCount.count} notifications`
              font.pixelSize: 12
            }
          }
        }
      }

      Rectangle {
        anchors { horizontalCenter: parent.horizontalCenter; bottom: parent.bottom; bottomMargin: 40 }
        visible: Media.selectedPlayer !== null
        implicitWidth: mediaRow.implicitWidth + 24
        implicitHeight: 44
        radius: Theme.radiusSm
        color: Qt.rgba(0, 0, 0, 0.5)
        border.width: 1
        border.color: Theme.colors.border

        RowLayout {
          id: mediaRow
          anchors.centerIn: parent
          spacing: 10

          StyledText {
            Layout.maximumWidth: 320
            text: `${Media.selectedPlayer?.trackTitle ?? ""}${Media.selectedPlayer?.trackArtist ? " — " + Media.selectedPlayer.trackArtist : ""}`
            font.pixelSize: 12
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
            color: Theme.colors.accent
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
