import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import Quickshell.Services.Mpris
import "root:/data"
import "root:/services"
import "root:/components"

Item {
  id: noti

  property bool showIndicator: Notifications.list.length > 0 || Media.players.length > 0

  Layout.alignment: Qt.AlignCenter

  Text {
    text: ""
    color: Settings.colors.foreground
    font.pixelSize: 16

    anchors.horizontalCenter: parent.horizontalCenter

    visible: noti.showIndicator

    MouseArea {
      anchors.fill: parent
      onClicked: notificationLoader.item.visible = !notificationLoader.item.visible
    }
  }

  LazyLoader {
    id: notificationLoader

    loading: true

    PopupWindow {
      id: popup
      anchor.window: noti.QsWindow.window
      anchor.rect.x: parentWindow.width * 1.2

      visible: false

      color: "transparent"

      implicitWidth: 400
      implicitHeight: noti.QsWindow.window.height

      Rectangle {
        anchors.fill: parent
        radius: 10
        color: Settings.colors.background

        ColumnLayout {
          spacing: 10

          anchors {
            fill: parent
            topMargin: 15
            bottomMargin: 15
            leftMargin: 15
            rightMargin: 15
          }

          Rectangle {
            width: parent.width
            height: 30
            color: Settings.colors.background
            radius: 5

            Text {
              text: "Notifications"
              color: Settings.colors.foreground
              font.pixelSize: 20
              font.bold: true

              anchors.centerIn: parent
            }
          }

          Rectangle {
            width: parent.width
            height: 120
            radius: 5
            color: Settings.colors.backgroundLighter

            ColumnLayout {
              id: mprisRoot
              spacing: 7

              width: parent.width
              height: parent.height

              anchors {
                fill: parent
                leftMargin: 10
                rightMargin: 20
                topMargin: 10
                bottomMargin: 10
              }

              Row {
                spacing: 10

                Layout.preferredWidth: parent.width
                Layout.preferredHeight: 80

                ClippingWrapperRectangle {
                  radius: 5
                  width: parent.height
                  height: parent.height

                  Image {
                    source: Media.selectedPlayer.trackArtUrl
                    fillMode: Image.PreserveAspectFit
                    width: parent.width
                    height: parent.height
                  }
                }

                ColumnLayout {
                  spacing: 5

                  height: 80
                  width: parent.width

                  Text {
                    text: Media.selectedPlayer.trackTitle
                    color: Settings.colors.foreground
                    font.pixelSize: 20
                  }

                  Text {
                    text: Media.selectedPlayer.trackArtist
                    color: Settings.colors.foreground
                    font.pixelSize: 14
                  }

                  Row {
                    spacing: (parent.width / 3) - 10

                    IconButton {
                      // icon: "media-skip-backward-symbolic"
                      icon: "󰒫"
                      onClicked: Media.selectedPlayer.previous()
                    }

                    IconButton {
                      // icon: "media-playback-start-symbolic"
                      icon: "󰐊"
                      onClicked: Media.selectedPlayer.play()
                      visible: Media.selectedPlayer.playbackState == MprisPlaybackState.Paused
                    }

                    IconButton {
                      // icon: "media-playback-pause-symbolic"
                      icon: "󰏤"
                      onClicked: Media.selectedPlayer.pause()
                      visible: Media.selectedPlayer.playbackState == MprisPlaybackState.Playing
                    }

                    IconButton {
                      // icon: "media-skip-forward-symbolic"
                      icon: "󰒬"
                      onClicked: Media.selectedPlayer.next()
                    }
                  }
                }
              }

              RowLayout {
                id: progressBar
                spacing: 10

                Layout.preferredWidth: parent.width
                Layout.preferredHeight: parent.height

                Text {
                  id: positionText
                  text: Math.round(Media.selectedPlayer.position) + "s"
                  color: Settings.colors.foreground
                }

                Slider {
                  id: progress
                  from: 0
                  to: Media.selectedPlayer.length
                  value: Media.selectedPlayer.position

                  onMoved: Media.selectedPlayer.position = value

                  implicitHeight: parent.height
                  implicitWidth: parent.width - positionText.width - lengthText.width - 10

                  background: Rectangle {
                    id: sliderBackground
                    color: Settings.colors.backgroundDarker
                    x: progress.leftPadding
                    y: progress.topPadding + progress.availableHeight / 2 - height / 2
                    implicitWidth: parent.width
                    implicitHeight: 4
                    width: progress.availableWidth
                    height: implicitHeight
                    radius: 2

                    Rectangle {
                      implicitWidth: progress.visualPosition * parent.width
                      implicitHeight: parent.height
                      color: Settings.colors.accent
                      radius: 2
                    }
                  }

                  handle: Rectangle {
                    x: progress.leftPadding + progress.visualPosition * progress.availableWidth
                    y: progress.topPadding + progress.availableHeight / 2 - height / 2
                    implicitWidth: 20
                    implicitHeight: 20
                    radius: 13
                    color: Settings.colors.backgroundLightest
                    border.color: Settings.colors.border
                  }
                }

                Text {
                  id: lengthText
                  text: Math.round(Media.selectedPlayer.length) + "s"
                  color: Settings.colors.foreground
                }

                FrameAnimation {
                  running: Media.selectedPlayer.playbackState == MprisPlaybackState.Playing
                  onTriggered: {
                    progress.value = Media.selectedPlayer.position;
                    positionText.text = Math.round(Media.selectedPlayer.position) + "s";
                  }
                }
              }
            }
          }

          ListView {
            id: notiList
            model: Notifications.list

            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: parent.height

            ScrollBar.vertical: ScrollBar {}

            spacing: 15

            delegate: Item {
              required property Notification modelData

              width: parent.width
              height: 80

              Rectangle {
                anchors.fill: parent
                color: Settings.colors.backgroundLighter
                radius: 5

                IconImage {
                  anchors {
                    left: parent.left
                    leftMargin: 10
                    verticalCenter: parent.verticalCenter
                  }
                  width: 48
                  height: 48
                  source: Quickshell.iconPath(modelData.appIcon)
                }

                ColumnLayout {
                  anchors {
                    left: parent.left
                    leftMargin: 75
                    top: parent.top
                    topMargin: 10
                  }

                  spacing: 5

                  Text {
                    text: modelData.appName
                    color: Settings.colors.foreground
                    font {
                      pixelSize: 18
                      bold: true
                    }
                  }

                  Text {
                    text: modelData.body
                    color: Settings.colors.foreground
                    font.pixelSize: 13
                  }
                }

                Text {
                  text: "x"
                  color: Settings.colors.error
                  font.pixelSize: 16

                  anchors {
                    top: parent.top
                    topMargin: 5
                    right: parent.right
                    rightMargin: 10
                  }

                  MouseArea {
                    anchors.fill: parent
                    onClicked: {
                      modelData.dismiss();
                      if (Notifications.list.length <= 0) {
                        popup.visible = false;
                      }
                    }
                  }
                }

                Repeater {
                  model: modelData.actions

                  Item {
                    required property NotificationAction actionData

                    width: 100
                    height: 30

                    anchors {
                      left: parent.left
                      leftMargin: 5
                      top: parent.top
                      topMargin: 5
                    }

                    Rectangle {
                      anchors.fill: parent
                      color: Settings.colors.backgroundDarker
                      radius: 5

                      Text {
                        text: actionData.text
                        color: Settings.colors.foreground
                        font.pixelSize: 12

                        anchors {
                          left: parent.left
                          leftMargin: 10
                          verticalCenter: parent.verticalCenter
                        }
                      }

                      MouseArea {
                        anchors.fill: parent
                        onClicked: actionData.invoke()
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }
}
