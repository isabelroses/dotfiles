import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import "root:/data"
import "root:/services"

Item {
  id: workspaces

  property int selectedWorkspace: 0

  Layout.alignment: Qt.AlignCenter

  width: 20
  height: 20

  Process {
    id: getSelectedWorkspace
    running: true
    command: ["fht-compositor", "ipc", "--json", "focused-workspace"]
    stdout: StdioCollector {
      onStreamFinished: {
        var jsonData = JSON.parse(text);
        workspaces.selectedWorkspace = jsonData.id;
      }
    }
  }

  Timer {
    interval: 100
    running: true
    repeat: true
    onTriggered: getSelectedWorkspace.running = true
  }

  ColumnLayout {
    spacing: 5

    anchors.horizontalCenter: parent.horizontalCenter

    Repeater {
      model: 9

      Text {
        id: workspace
        required property int index

        font.pointSize: 13

        color: workspaces.selectedWorkspace === index ? Settings.colors.accent : Settings.colors.foreground
        text: index + 1
      }
    }
  }
}
