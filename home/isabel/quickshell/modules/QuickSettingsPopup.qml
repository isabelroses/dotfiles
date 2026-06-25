import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Io
import Quickshell.Services.Notifications as QsNotifications
import "root:/data"
import "root:/components"
import "root:/services"

LazyLoader {
  id: loader
  active: Runtime.quickSettingsOpen

  PanelWindow {
    id: popup
    color: "transparent"

    anchors.left: true
    margins.left: 70

    implicitWidth: screen.width * 0.21
    implicitHeight: screen.height * 0.98
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Rectangle {
      anchors.fill: parent
      radius: Settings.rounding
      color: Settings.colors.background
      border.color: Settings.colors.border
      border.width: 1

      ColumnLayout {
        spacing: 12
        anchors {
          fill: parent
          margins: 16
        }

        // Header
        RowLayout {
          Layout.fillWidth: true
          spacing: 8

          Text {
            text: "Notifications"
            color: Settings.colors.foreground
            font {
              pixelSize: 18
              weight: Font.Bold
            }
          }

          Item { Layout.fillWidth: true }

          IconButton {
            icon: "edit-clear-all-symbolic"
            size: 16
            onClicked: {
              for (const n of Notifications.list) {
                n.dismiss();
              }
              popup.visible = false;
            }
          }
        }

        // Notifications List
        ListView {
          id: notiList
          model: Notifications.list
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 8
          clip: true

          ScrollBar.vertical: ScrollBar {
            policy: ScrollBar.AsNeeded
          }

          delegate: Rectangle {
            id: notiDelegate
            required property QsNotifications.Notification modelData
            width: ListView.view.width
            height: modelData.hasInlineReply ? 116 : 72
            radius: 8
            color: Settings.colors.backgroundLighter
            border.color: Settings.colors.border
            border.width: 1

            ColumnLayout {
              anchors {
                fill: parent
                margins: 10
              }
              spacing: 8

              RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 10

                IconImage {
                  source: Quickshell.iconPath(notiDelegate.modelData?.appIcon ? Utils.getIcon(notiDelegate.modelData.appIcon) : "application-x-executable")

                  implicitSize: 40
                  Layout.alignment: Qt.AlignVCenter
                }

                ColumnLayout {
                  Layout.fillWidth: true
                  Layout.fillHeight: true
                  spacing: 2

                  Text {
                    text: notiDelegate.modelData.appName
                    color: Settings.colors.foreground
                    font {
                      pixelSize: 13
                      weight: Font.Medium
                    }
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                  }

                  Text {
                    text: notiDelegate.modelData.body
                    color: Settings.colors.foreground
                    opacity: 0.8
                    font.pixelSize: 12
                    elide: Text.ElideRight
                    maximumLineCount: 2
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                  }
                }

                IconButton {
                  icon: "window-close-symbolic"
                  size: 14
                  Layout.alignment: Qt.AlignTop
                  onClicked: {
                    notiDelegate.modelData.dismiss();
                    if (Notifications.list.length <= 0) {
                      popup.visible = false;
                    }
                  }
                }
              }

              RowLayout {
                visible: notiDelegate.modelData.hasInlineReply
                Layout.fillWidth: true
                spacing: 6

                TextField {
                  id: listReplyField
                  Layout.fillWidth: true
                  placeholderText: notiDelegate.modelData.inlineReplyPlaceholder || "Reply..."
                  placeholderTextColor: Qt.rgba(Settings.colors.foreground.r, Settings.colors.foreground.g, Settings.colors.foreground.b, 0.4)
                  color: Settings.colors.foreground
                  font.pixelSize: 12
                  onAccepted: { notiDelegate.modelData.sendInlineReply(text); text = ""; }
                  background: Rectangle {
                    radius: 6
                    color: Settings.colors.background
                    border.color: listReplyField.activeFocus ? Settings.colors.accent : Settings.colors.border
                    border.width: 1
                  }
                }

                IconButton {
                  icon: "mail-send-symbolic"
                  size: 14
                  onClicked: { notiDelegate.modelData.sendInlineReply(listReplyField.text); listReplyField.text = ""; }
                }
              }
            }
          }
        }

        // Separator before Media
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 1
          color: Settings.colors.backgroundLightest
          visible: Media.players.length > 0
        }

        // Media Players Section
        MediaPlayers {}

        // Separator
        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 1
          color: Settings.colors.backgroundLightest
        }

        // Quick Settings Section
        QuickSettings {}
      }
    }
  }
}
