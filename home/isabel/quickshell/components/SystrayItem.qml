import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.data

Item {
  id: trayItem
  required property SystemTrayItem modelData

  Layout.alignment: Qt.AlignHCenter
  implicitWidth: 30
  implicitHeight: 30

  Rectangle {
    anchors.fill: parent
    radius: Settings.radiusSm
    color: popup.visible ? Settings.colors.accentSoft : Settings.colors.surfaceRaised
    opacity: popup.visible || mouseArea.containsMouse ? 1 : 0
    Behavior on opacity { NumberAnimation { duration: Settings.animFast } }
  }

  IconImage {
    asynchronous: true
    source: Utils.getIcon(trayItem.modelData.icon)
    implicitSize: 16
    anchors.centerIn: parent
    mipmap: true
  }

  BarTooltip {
    text: popup.visible ? "" : (trayItem.modelData.tooltipTitle || trayItem.modelData.title || trayItem.modelData.id)
  }

  MouseArea {
    id: mouseArea
    anchors.fill: parent
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    onClicked: (mouse) => {
      if (mouse.button === Qt.RightButton || trayItem.modelData.onlyMenu) {
        if (trayItem.modelData.hasMenu) popup.visible = !popup.visible;
      } else {
        trayItem.modelData.activate();
      }
    }
  }

  property var menuStack: []
  readonly property QsMenuHandle currentMenu: menuStack.length > 0
    ? menuStack[menuStack.length - 1]
    : modelData.menu

  function pushMenu(entry: QsMenuEntry): void {
    menuStack = [...menuStack, entry];
  }

  function popMenu(): void {
    menuStack = menuStack.slice(0, -1);
  }

  QsMenuOpener {
    id: menu
    menu: trayItem.currentMenu
  }

  PopupWindow {
    id: popup
    visible: false
    grabFocus: true
    color: "transparent"

    anchor.item: trayItem
    anchor.rect.x: -(Settings.barWidth - trayItem.width) / 2
    anchor.rect.width: Settings.barWidth
    anchor.rect.height: trayItem.height
    anchor.edges: (Settings.barOnRight ? Edges.Left : Edges.Right) | Edges.Top
    anchor.gravity: (Settings.barOnRight ? Edges.Left : Edges.Right) | Edges.Bottom

    implicitWidth: 240
    implicitHeight: menuColumn.implicitHeight + 12

    onVisibleChanged: if (!visible) trayItem.menuStack = []

    Rectangle {
      anchors.fill: parent
      color: Settings.colors.base
      radius: Settings.radiusMd
      border.color: Settings.colors.borderStrong
      border.width: 1
    }

    ColumnLayout {
      id: menuColumn
      anchors {
        left: parent.left
        right: parent.right
        top: parent.top
        margins: 6
      }
      spacing: 1

      Clickable {
        Layout.fillWidth: true
        onClicked: if (trayItem.menuStack.length > 0) trayItem.popMenu()
        implicitHeight: 30
        radius: Settings.radiusXs
        color: hovered && trayItem.menuStack.length > 0
          ? Settings.colors.surfaceRaised : "transparent"

        RowLayout {
          anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
          spacing: 6

          MyIcon {
            visible: trayItem.menuStack.length > 0
            icon: "go-previous-symbolic"
            size: 12
            color: Settings.colors.textMuted
          }

          StyledText {
            Layout.fillWidth: true
            text: trayItem.menuStack.length > 0
              ? trayItem.menuStack[trayItem.menuStack.length - 1].text.replace("_", "")
              : (trayItem.modelData.title || trayItem.modelData.id)
            color: Settings.colors.textMuted
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.letterSpacing: 0.4
            elide: Text.ElideRight
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 6
        Layout.rightMargin: 6
        Layout.bottomMargin: 3
        implicitHeight: 1
        color: Settings.colors.border
      }

      Repeater {
        model: menu.children

        delegate: Loader {
          id: entryLoader
          required property QsMenuEntry modelData

          Layout.fillWidth: true
          sourceComponent: modelData.isSeparator ? separatorComponent : entryComponent

          Component {
            id: separatorComponent

            Item {
              implicitHeight: 9

              Rectangle {
                anchors.centerIn: parent
                width: parent.width - 12
                height: 1
                color: Settings.colors.border
              }
            }
          }

          Component {
            id: entryComponent

            Clickable {
              readonly property QsMenuEntry entry: entryLoader.modelData
              onClicked: {
                if (!entry.enabled) return;
                if (entry.hasChildren) trayItem.pushMenu(entry);
                else {
                  entry.triggered();
                  popup.visible = false;
                }
              }
              readonly property bool checked: entry.checkState !== Qt.Unchecked

              implicitHeight: 32
              radius: Settings.radiusXs
              color: hovered && entry.enabled ? Settings.colors.surfaceRaised : "transparent"
              opacity: entry.enabled ? 1.0 : 0.4

              RowLayout {
                anchors { fill: parent; leftMargin: 10; rightMargin: 8 }
                spacing: 10

                Rectangle {
                  visible: entry.buttonType !== QsMenuButtonType.None
                  implicitWidth: 14
                  implicitHeight: 14
                  radius: entry.buttonType === QsMenuButtonType.RadioButton ? 7 : Settings.radiusXs
                  color: checked ? Settings.colors.accent : "transparent"
                  border.width: checked ? 0 : 1.5
                  border.color: Settings.colors.textSubtle

                  Rectangle {
                    anchors.centerIn: parent
                    visible: checked
                    width: 6
                    height: 6
                    radius: entry.buttonType === QsMenuButtonType.RadioButton ? 3 : 1
                    color: Settings.colors.textOnAccent
                  }
                }

                IconImage {
                  asynchronous: true
                  visible: entry.icon !== "" && entry.buttonType === QsMenuButtonType.None
                  source: entry.icon
                  implicitSize: 16
                }

                StyledText {
                  Layout.fillWidth: true
                  text: entry.text.replace("_", "")
                  elide: Text.ElideRight
                }

                MyIcon {
                  visible: entry.hasChildren
                  icon: "go-next-symbolic"
                  size: 12
                  color: Settings.colors.textMuted
                }
              }
            }
          }
        }
      }
    }
  }
}
