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
      implicitHeight: Settings.barWidth
      color: "transparent"

      anchors {
        top: Settings.barSide !== "bottom"
        bottom: Settings.barSide !== "top"
        left: Settings.barSide !== "right"
        right: Settings.barSide !== "left"
      }

      Rectangle {
        id: bar
        anchors.fill: parent
        color: Settings.colors.base

        // edge facing the screen
        Rectangle {
          color: Settings.colors.border
          x: Settings.barVertical ? (Settings.barOnRight ? 0 : parent.width - width) : 0
          y: Settings.barVertical ? 0 : (Settings.barOnBottom ? 0 : parent.height - height)
          width: Settings.barVertical ? 1 : parent.width
          height: Settings.barVertical ? parent.height : 1
        }

        BarGroup {
          spacing: 12
          x: Settings.barVertical ? (parent.width - width) / 2 : 9
          y: Settings.barVertical ? 9 : (parent.height - height) / 2

          Launcher {}
          BarDivider {}
          Workspaces {}
        }

        Clock {
          anchors.centerIn: parent
        }

        BarGroup {
          spacing: 10
          x: Settings.barVertical ? (parent.width - width) / 2 : parent.width - width - 9
          y: Settings.barVertical ? parent.height - height - 9 : (parent.height - height) / 2

          RecordingDot {}
          NowPlaying {}
          SysTray {}

          Clickable {
            id: capsule
            onClicked: Runtime.toggleQuickSettings()
            onScrolled: (e) => Pipewire.setSinkVolume(Pipewire.sinkVolume + (e.angleDelta.y > 0 ? 0.05 : -0.05))
            Layout.alignment: Qt.AlignCenter
            implicitWidth: Settings.barVertical ? 34 : statusGroup.implicitWidth + 22
            implicitHeight: Settings.barVertical ? statusGroup.implicitHeight + 22 : 34
            radius: Settings.radiusSm
            color: Runtime.quickSettingsOpen ? Settings.colors.accentSoft
                 : capsule.hovered ? Settings.colors.surfaceRaised
                 : Settings.colors.surface
            border.color: Runtime.quickSettingsOpen ? Settings.colors.accent : Settings.colors.border
            border.width: 1

            Behavior on color { ColorAnimation { duration: Settings.animFast } }
            Behavior on border.color { ColorAnimation { duration: Settings.animFast } }

            BarGroup {
              id: statusGroup
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
