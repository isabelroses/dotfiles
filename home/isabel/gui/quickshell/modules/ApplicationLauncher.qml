import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Io
import Quickshell.Widgets
import Quickshell.Wayland
import "root:/components"
import "root:/data"

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

      readonly property list<DesktopEntry> rawApplications: DesktopEntries.applications.values.filter(entry => !entry.noDisplay && !entry.runInTerminal)
      property list<DesktopEntry> applications: rawApplications

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
        id: background
        anchors.fill: parent
        radius: 10
        color: Settings.colors.background

        ColumnLayout {
          spacing: 10

          anchors {
            fill: parent
            topMargin: 10
            leftMargin: 10
            rightMargin: 10
            bottomMargin: 10
          }

          width: parent.width
          height: parent.height

          TextField {
            id: searchField
            placeholderText: "Search applications..."
            font.pointSize: 14
            color: Settings.colors.foreground
            placeholderTextColor: Settings.colors.foreground

            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: parent.width
            Layout.preferredHeight: 40

            onTextChanged: {
              if (text.length > 0) {
                // fuzzy search algo
                applications = rawApplications.filter(entry => {
                  var needle = text.toLowerCase();
                  var haystack = entry.name.toLowerCase();

                  var hlen = haystack.length;
                  var nlen = needle.length;

                  if (nlen > hlen) return false;

                  if (nlen === hlen) return haystack === needle;

                  outer: for (var i = 0, j = 0; i < nlen; i++) {
                    var nch = needle.charCodeAt(i);
                    while (j < hlen) {
                      if (haystack.charCodeAt(j++) === nch) {
                        continue outer;
                      }
                    }
                    return false;
                  }
                  return true;
                });
              } else {
                applications = rawApplications;
              }
            }

            background: Rectangle {
              radius: 5
              color: Settings.colors.backgroundLighter
            }
          }

          ListView {
            model: applications
            spacing: 5

            ScrollBar.vertical: ScrollBar {}

            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: parent.width
            // account for searchField height and margins
            Layout.preferredHeight: parent.height - searchField.height - 20

            delegate: Rectangle {
              required property DesktopEntry modelData

              width: parent.width
              height: 60
              radius: 5

              color: Settings.colors.backgroundLighter

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
}
