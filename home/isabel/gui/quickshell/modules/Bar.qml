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
      implicitWidth: 40
      color: "transparent"

      anchors {
        top: true
        left: true
        bottom: true
      }

      margins {
        left: 15
        right: 15
        top: 15
        bottom: 15
      }

      Rectangle {
        id: bar
        anchors.fill: parent
        radius: 10
        color: Settings.colors.background

        ColumnLayout {
          anchors {
            left: parent.left
            top: parent.top
            right: parent.right
            topMargin: 15
          }

          spacing: 15

          Launcher {}
          Workspaces {}
        }

        ColumnLayout {
          anchors {
            left: parent.left
            right: parent.right
            top: parent.verticalCenter
          }

          spacing: 20

          Clock {}
          Noti {}
        }

        ColumnLayout {
          anchors {
            left: parent.left
            bottom: parent.bottom
            right: parent.right
            bottomMargin: 15
          }

          spacing: 15

          SysTray {}
          Volume {}
          Network {}
        }
      }
    }
  }
}
