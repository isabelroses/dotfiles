import QtQuick
import Quickshell
import Quickshell.Io
import QtQuick.Layouts
import "root:/data"

Item {
  id: workspaces

  property int selectedWorkspace: 0

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


  Repeater {
    model: 9

    Text {
      id: workspace
      required property int index

      anchors {
        left: parent.left
        top: parent.top
        topMargin: 20 + (index * 22)
        leftMargin: 15
      }

      font.pointSize: 13

      color: workspaces.selectedWorkspace === index ? Settings.colors.accent : Settings.colors.foreground
      text: index + 1
    }
  }
}
