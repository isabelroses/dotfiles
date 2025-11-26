import QtQuick
import QtQuick.Layouts
import Quickshell
import QtQuick.Controls
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "root:/data"

ColumnLayout {
  id: systray

  Layout.alignment: Qt.AlignCenter

  Repeater {
    model: SystemTray.items

    delegate: Item {
      id: delagate
      required property SystemTrayItem modelData

      width: 24
      height: 24

      IconImage {
        source: modelData.icon
        width: 16
        height: 16
        anchors.centerIn: parent
      }

      MouseArea {
        anchors.fill: parent
        hoverEnabled: true

        onClicked: popupLoader.item.visible = !popupLoader.item.visible
      }

      QsMenuOpener {
        id: menu
        menu: modelData.menu
      }

      LazyLoader {
        id: popupLoader

        loading: true

        PopupWindow {
          id: popup
          anchor.window: delagate.QsWindow.window
          anchor.rect.x: parentWindow.width * 1.15
          anchor.rect.y: parentWindow.height / 1.25

          color: "transparent"

          implicitWidth: 200
          implicitHeight: 200

          Rectangle {
            anchors.fill: parent
            color: Settings.colors.background
            radius: 5
          }

          ListView {
            model: menu.children

            anchors {
              top: parent.top
              topMargin: 5
              bottom: parent.bottom
              bottomMargin: 5
            }

            width: parent.width
            height: parent.height
            spacing: 5

            ScrollBar.vertical: ScrollBar {}

            delegate: Item {
              required property QsMenuHandle modelData

              width: parent.width
              height: 40

              Rectangle {
                anchors {
                  fill: parent
                  leftMargin: 5
                  rightMargin: 5
                }

                color: Settings.colors.backgroundLighter
                radius: 5

                Text {
                  anchors.centerIn: parent
                  text: modelData.text
                  color: Settings.colors.foreground
                  font.pointSize: 12
                }

                MouseArea {
                  anchors.fill: parent
                  hoverEnabled: true

                  onClicked: {
                    modelData.triggered();
                    popup.visible = false;
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
