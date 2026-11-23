import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import qs.data

Item {
  id: trayItem
  required property SystemTrayItem modelData

  Layout.alignment: Qt.AlignCenter
  implicitWidth: 30
  implicitHeight: 30

  Rectangle {
    anchors.fill: parent
    radius: Theme.radiusSm
    color: popup.visible ? Theme.colors.accentSoft : Theme.colors.surfaceRaised
    opacity: popup.visible || mouseArea.containsMouse ? 1 : 0
    Behavior on opacity { Anim { duration: Theme.animFast } }
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
    anchor.rect.x: Theme.barVertical ? -(Theme.barWidth - trayItem.width) / 2 : 0
    anchor.rect.y: Theme.barVertical ? 0 : -(Theme.barWidth - trayItem.height) / 2
    anchor.rect.width: Theme.barVertical ? Theme.barWidth : trayItem.width
    anchor.rect.height: Theme.barVertical ? trayItem.height : Theme.barWidth
    anchor.edges: Theme.barAwayEdge | (Theme.barVertical ? Edges.Top : Edges.Left)
    anchor.gravity: Theme.barAwayEdge | (Theme.barVertical ? Edges.Bottom : Edges.Right)

    implicitWidth: 240
    implicitHeight: menuColumn.implicitHeight + 12

    onVisibleChanged: if (!visible) trayItem.menuStack = []

    Rectangle {
      anchors.fill: parent
      color: Theme.colors.base
      radius: Theme.radiusMd
      border.color: Theme.colors.borderStrong
      border.width: 1
    }

    ColumnLayout {
      id: menuColumn
      anchors { left: parent.left; right: parent.right; top: parent.top; margins: 6 }
      spacing: 1

      Clickable {
        Layout.fillWidth: true
        onClicked: if (trayItem.menuStack.length > 0) trayItem.popMenu()
        implicitHeight: 30
        radius: Theme.radiusXs
        color: hovered && trayItem.menuStack.length > 0
          ? Theme.colors.surfaceRaised : "transparent"

        RowLayout {
          anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
          spacing: 6

          MyIcon {
            visible: trayItem.menuStack.length > 0
            icon: "go-previous-symbolic"
            size: 12
            color: Theme.colors.textMuted
          }

          Caption {
            Layout.fillWidth: true
            text: trayItem.menuStack.length > 0
              ? trayItem.menuStack[trayItem.menuStack.length - 1].text.replace("_", "")
              : (trayItem.modelData.title || trayItem.modelData.id)
            font.weight: Font.DemiBold
          }
        }
      }

      Rectangle {
        Layout.fillWidth: true
        Layout.leftMargin: 6
        Layout.rightMargin: 6
        Layout.bottomMargin: 3
        implicitHeight: 1
        color: Theme.colors.border
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
                color: Theme.colors.border
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
              radius: Theme.radiusXs
              color: hovered && entry.enabled ? Theme.colors.surfaceRaised : "transparent"
              opacity: entry.enabled ? 1.0 : 0.4

              RowLayout {
                anchors { fill: parent; leftMargin: 10; rightMargin: 8 }
                spacing: 10

                Rectangle {
                  visible: entry.buttonType !== QsMenuButtonType.None
                  implicitWidth: 14
                  implicitHeight: 14
                  radius: entry.buttonType === QsMenuButtonType.RadioButton ? 7 : Theme.radiusXs
                  color: checked ? Theme.colors.accent : "transparent"
                  border.width: checked ? 0 : 1.5
                  border.color: Theme.colors.textSubtle

                  Rectangle {
                    anchors.centerIn: parent
                    visible: checked
                    width: 6
                    height: 6
                    radius: entry.buttonType === QsMenuButtonType.RadioButton ? 3 : 1
                    color: Theme.colors.textOnAccent
                  }
                }

                IconImage {
                  asynchronous: true
                  visible: entry.icon !== "" && entry.buttonType === QsMenuButtonType.None
                  source: entry.icon
                  implicitSize: 16
                }

                StyledText { Layout.fillWidth: true; text: entry.text.replace("_", "") }

                MyIcon {
                  visible: entry.hasChildren
                  icon: "go-next-symbolic"
                  size: 12
                  color: Theme.colors.textMuted
                }
              }
            }
          }
        }
      }
    }
  }
}
