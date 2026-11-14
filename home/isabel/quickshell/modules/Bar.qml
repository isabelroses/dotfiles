import Quickshell
import QtQuick
import QtQuick.Layouts
import qs.data
import qs.components
import qs.services

Scope {
  id: root

  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property ShellScreen modelData
      screen: modelData
      implicitWidth: Settings.barWidth
      color: "transparent"

      anchors {
        top: true
        bottom: true
        left: !Settings.barOnRight
        right: Settings.barOnRight
      }

      Rectangle {
        id: bar
        anchors.fill: parent
        color: Settings.colors.base

        Rectangle {
          anchors { top: parent.top; bottom: parent.bottom }
          x: Settings.barOnRight ? 0 : parent.width - width
          width: 1
          color: Settings.colors.border
        }

        ColumnLayout {
          anchors {
            horizontalCenter: parent.horizontalCenter
            top: parent.top
            topMargin: 9
          }
          spacing: 12

          Launcher {}
          BarDivider {}
          Workspaces {}
        }

        Clock {
          anchors.centerIn: parent
        }

        ColumnLayout {
          anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 9
          }
          spacing: 10

          RecordingDot {}
          NowPlaying {}
          SysTray {}

          Clickable {
            id: capsule
            onClicked: Runtime.toggleQuickSettings()
            onScrolled: (e) => Pipewire.setSinkVolume(Pipewire.sinkVolume + (e.angleDelta.y > 0 ? 0.05 : -0.05))
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 34
            implicitHeight: statusColumn.implicitHeight + 22
            radius: Settings.radiusSm
            color: Runtime.quickSettingsOpen ? Settings.colors.accentSoft
                 : capsule.hovered ? Settings.colors.surfaceRaised
                 : Settings.colors.surface
            border.color: Runtime.quickSettingsOpen ? Settings.colors.accent : Settings.colors.border
            border.width: 1

            Behavior on color { ColorAnimation { duration: Settings.animFast } }
            Behavior on border.color { ColorAnimation { duration: Settings.animFast } }

            ColumnLayout {
              id: statusColumn
              anchors.centerIn: parent
              spacing: 12

              Noti {}
              Volume {}
              Network {}
              Battery {}
            }
          }
        }
      }
    }
  }
}
