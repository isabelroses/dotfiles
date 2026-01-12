import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import "root:/data"

Item {
  id: trayItem
  required property SystemTrayItem modelData

  Layout.alignment: Qt.AlignHCenter
  implicitWidth: 24
  implicitHeight: 24

  IconImage {
    source: Utils.getIcon(modelData.icon)
    implicitSize: 18
    anchors.centerIn: parent
    mipmap: true
  }

  MouseArea {
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: (mouse) => {
      if (mouse.button === Qt.RightButton || modelData.onlyMenu) {
        popupLoader.item.visible = !popupLoader.item.visible;
      } else {
        modelData.activate();
      }
    }
  }

  ToolTip {
    visible: trayMouseArea.containsMouse && modelData.tooltipTitle !== ""
    text: modelData.tooltipTitle
    delay: 500
  }

  MouseArea {
    id: trayMouseArea
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.NoButton
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
      anchor.window: trayItem.QsWindow.window
      anchor.rect.x: (trayItem.QsWindow.window?.width ?? 0) * 1.15
      anchor.rect.y: (trayItem.QsWindow.window?.height ?? 0) / 1.25
      visible: false
      color: "transparent"

      implicitWidth: 220
      implicitHeight: menuColumn.implicitHeight + 16

      Rectangle {
        anchors.fill: parent
        color: Settings.colors.background
        radius: 10

        // Shadow effect
        layer.enabled: true
        layer.effect: null
      }

      ColumnLayout {
        id: menuColumn
        anchors {
          fill: parent
          margins: 8
        }
        spacing: 2

        // Header with app name
        Text {
          text: modelData.title || modelData.id
          color: Settings.colors.foreground
          font {
            pixelSize: 12
            weight: Font.Bold
          }
          opacity: 0.7
          Layout.fillWidth: true
          Layout.leftMargin: 8
          Layout.bottomMargin: 4
          elide: Text.ElideRight
          visible: text !== ""
        }

        Rectangle {
          Layout.fillWidth: true
          Layout.preferredHeight: 1
          Layout.leftMargin: 4
          Layout.rightMargin: 4
          Layout.bottomMargin: 4
          color: Settings.colors.foreground
          opacity: 0.1
          visible: (modelData.title || modelData.id) !== ""
        }

        Repeater {
          model: menu.children

          delegate: Loader {
            id: menuItemLoader
            required property var modelData

            Layout.fillWidth: true
            sourceComponent: modelData.isSeparator ? separatorComponent : menuItemComponent

            Component {
              id: separatorComponent

              Rectangle {
                height: 9
                color: "transparent"

                Rectangle {
                  anchors.centerIn: parent
                  width: parent.width - 16
                  height: 1
                  color: Settings.colors.foreground
                  opacity: 0.1
                }
              }
            }

            Component {
              id: menuItemComponent

              Rectangle {
                id: menuItemRect
                height: 32
                radius: 6
                color: menuMouse.containsMouse && menuItemLoader.modelData.enabled
                ? Settings.colors.backgroundLighter
                : "transparent"
                opacity: menuItemLoader.modelData.enabled ? 1.0 : 0.5

                RowLayout {
                  anchors {
                    fill: parent
                    leftMargin: 10
                    rightMargin: 10
                  }
                  spacing: 8

                  // Checkbox/Radio indicator
                  Rectangle {
                    visible: menuItemLoader.modelData.buttonType !== 0 // QsMenuButtonType.None
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    radius: menuItemLoader.modelData.buttonType === 2 ? 8 : 3 // RadioButton = 2
                    color: "transparent"
                    border.width: 1.5
                    border.color: menuItemLoader.modelData.checkState !== Qt.Unchecked
                    ? Settings.colors.accent
                    : Settings.colors.foreground
                    opacity: menuItemLoader.modelData.checkState !== Qt.Unchecked ? 1.0 : 0.5

                    Rectangle {
                      anchors.centerIn: parent
                      width: 8
                      height: 8
                      radius: menuItemLoader.modelData.buttonType === 2 ? 4 : 2
                      color: Settings.colors.accent
                      visible: menuItemLoader.modelData.checkState !== Qt.Unchecked
                    }
                  }

                  // Icon
                  Image {
                    visible: menuItemLoader.modelData.icon !== "" && menuItemLoader.modelData.buttonType === 0
                    source: menuItemLoader.modelData.icon
                    Layout.preferredWidth: 16
                    Layout.preferredHeight: 16
                    sourceSize.width: 16
                    sourceSize.height: 16
                    smooth: true
                  }

                  // Text
                  Text {
                    text: menuItemLoader.modelData.text
                    color: Settings.colors.foreground
                    font.pixelSize: 13
                    elide: Text.ElideRight
                    Layout.fillWidth: true
                  }

                  // Submenu indicator
                  MyIcon {
                    visible: menuItemLoader.modelData.hasChildren
                    icon: "go-next-symbolic"
                    size: 12
                    opacity: 0.6
                  }
                }

                MouseArea {
                  id: menuMouse
                  anchors.fill: parent
                  hoverEnabled: true
                  cursorShape: menuItemLoader.modelData.enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                  onClicked: {
                    if (!menuItemLoader.modelData.enabled) return;

                    if (menuItemLoader.modelData.hasChildren) {
                      // TODO: Handle submenu
                    } else {
                      menuItemLoader.modelData.triggered();
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
}
