import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import Quickshell.Hyprland
import "root:/data"
import "root:/services"

Item {
  id: workspaces

  Layout.alignment: Qt.AlignCenter

  width: 20
  height: 20

  ColumnLayout {
    spacing: 20

    anchors.horizontalCenter: parent.horizontalCenter

    Repeater {
      model: Hyprland.workspaces

      delegate: Item {
        id: workspace
        required property HyprlandWorkspace modelData

        implicitWidth: 10
        implicitHeight: 10

        MouseArea {
          anchors.fill: parent
          hoverEnabled: true

          onClicked: modelData.activate()
        }

        Text {
          font.pointSize: 13
          Layout.alignment: Qt.AlignCenter

          color: modelData.focused === modelData.id ? Settings.colors.accent : Settings.colors.foreground
          text: modelData.id
        }
      }
    }
  }
}
