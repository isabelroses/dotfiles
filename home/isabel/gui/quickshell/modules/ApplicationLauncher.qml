import "root:/components"
import "root:/data"
import QtQuick
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland

Scope {
  id: root

  IpcHandler {
      target: "launcher"

      function open(): void {
        loader.activeAsync = true;
      }

      function close(): void {
        loader.active = false;
      }

      function toggle(): void {
        if (loader.active) {
          loader.active = false;
        } else {
          loader.activeAsync = true;
        }
      }
  }

  LazyLoader {
    id: loader

    PanelWindow {
      id: launcher

      anchors.top: true
      margins.top: screen.height / 5

      implicitWidth: 400
      implicitHeight: 500

      color: "transparent"
      exclusionMode: ExclusionMode.Ignore
      WlrLayershell.layer: WlrLayer.Overlay

      WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
      Keys.onEscapePressed: loader.active = false

      Rectangle {
        anchors.fill: parent
        radius: 25
        color: Settings.colors.background

        ListView {
          model: DesktopEntries.applications.values

          ScrollBar.vertical: ScrollBar {}

          anchors {
            top: parent.top
            topMargin: 20
            bottom: parent.bottom
            bottomMargin: 20
          }

          width: parent.width
          height: parent.height
          spacing: 10

          delegate: Rectangle {
            required property DesktopEntry modelData

            width: parent.width - 30
            height: 60
            radius: 8

            anchors.horizontalCenter: parent.horizontalCenter

            color: Settings.colors.border

            IconImage {
              anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
              }
              width: 48
              height: 48
              source: Quickshell.iconPath(modelData.icon, "application-x-executable")
            }

            Text {
              anchors.centerIn: parent
              verticalAlignment: Text.AlignVCenter
              text: modelData.name
              color: Settings.colors.foreground
              font.pointSize: 14
            }

            MouseArea {
              id: mouseArea
              anchors.fill: parent
              hoverEnabled: true
              onClicked: {
                modelData.execute();
                loader.active = false;
              }
            }
          }
        }
      }
    }
  }
}
