import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "root:/data"
import "root:/components"

Scope {
  id: root

  Variants {
    model: Quickshell.screens

    PanelWindow {
      property var modelData
      screen: modelData
      implicitWidth: 48
      color: "transparent"

      anchors {
        top: true
        left: true
        bottom: true
      }

      margins {
        left: 10
        top: 10
        bottom: 10
      }

      Rectangle {
        id: bar
        anchors.fill: parent
        radius: Settings.rounding
        color: Settings.colors.background

        // Top section - Launcher & Workspaces
        ColumnLayout {
          anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 12
          }
          spacing: 16

          Launcher {}

          BarDivider {}

          Workspaces {}
        }

        // Center section - Clock
        ColumnLayout {
          anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
          }
          spacing: 16

          Clock {}
        }

        // Bottom section - System tray, Notis, Volume, Network
        Item {
          anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 12
          }
          implicitWidth: bottomColumn.implicitWidth
          implicitHeight: bottomColumn.implicitHeight

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Runtime.toggleQuickSettings()
          }

          ColumnLayout {
            id: bottomColumn
            anchors.fill: parent
            spacing: 12

            SysTray {}

            BarDivider {}

            Noti { }
            Volume {}
            Network {}
            Battery {}
          }
        }
      }
    }
  }
}
