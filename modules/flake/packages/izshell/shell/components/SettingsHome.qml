import QtQuick
import QtQuick.Layouts
import qs.data

ColumnLayout {
  id: root

  // sections to show: { name, title, icon }
  property var sections: []
  signal opened(name: string)

  spacing: 20

  readonly property var blurbs: ({
    lock: "Idle lock and what it shows",
    osd: "Volume, microphone, brightness",
    sound: "Outputs, inputs and apps",
    network: "Connections and Wi-Fi",
    bluetooth: "Devices and pairing",
    system: "About this machine",
    screenshot: "Saving and what happens after",
  })

  // other sections are summed up by their groups
  function blurb(name: string): string {
    if (blurbs[name]) return blurbs[name];
    const sec = Config.schema.find(s => s.name === name);
    const text = [...new Set((sec?.entries ?? []).map(e => e.group).filter(g => g))].join(", ").toLowerCase();
    return text.charAt(0).toUpperCase() + text.slice(1);
  }

  RowLayout {
    Layout.fillWidth: true
    spacing: 14

    Repeater {
      model: Config.pageGroups

      ColumnLayout {
        id: group
        required property var modelData

        Layout.fillWidth: true
        Layout.preferredWidth: 1
        Layout.alignment: Qt.AlignTop
        spacing: 8

        SectionLabel { text: group.modelData.title; size: 16; Layout.leftMargin: 2 }

        RowGroup {
          id: box

          Repeater {
            model: group.modelData.names.map(n => root.sections.find(s => s.name === n)).filter(s => s)

            Clickable {
              id: row
              required property var modelData
              required property int index

              Layout.fillWidth: true
              implicitHeight: 58
              radius: box.rowRadius
              color: hovered ? Settings.colors.surfaceRaised : "transparent"
              onClicked: root.opened(modelData.name)


              Hairline { visible: row.index > 0 }

              RowLayout {
                anchors { fill: parent; leftMargin: 16; rightMargin: 14 }
                spacing: 14

                MyIcon {
                  icon: row.modelData.icon
                  size: 16
                  color: row.hovered ? Settings.colors.accent : Settings.colors.textMuted
                  Behavior on color { ColorAnimation { duration: Settings.animFast } }
                }

                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: 2

                  StyledText {
                    Layout.fillWidth: true
                    text: row.modelData.title
                    font.pixelSize: 13
                    font.weight: Font.Medium
                  }

                  Caption { Layout.fillWidth: true; text: root.blurb(row.modelData.name) }
                }

                MyIcon { icon: "go-next-symbolic"; size: 10; color: Settings.colors.textSubtle }
              }
            }
          }
        }
      }
    }
  }

  // session shortcuts: each opens the power menu with its action selected, so
  // confirming (and the keyboard flow) lives in one place
  RowGroup {
    id: sessionBox

    RowLayout {
      Layout.fillWidth: true
      Layout.preferredHeight: 44
      spacing: 0

      Repeater {
        model: [
          { id: "lock", label: "Lock", icon: "system-lock-screen-symbolic" },
          { id: "suspend", label: "Sleep", icon: "weather-clear-night-symbolic" },
          { id: "logout", label: "Log out", icon: "system-log-out-symbolic" },
          { id: "reboot", label: "Restart", icon: "view-refresh-symbolic" },
          { id: "poweroff", label: "Shut down", icon: "system-shutdown-symbolic" },
        ]

        Clickable {
          id: session
          required property var modelData
          required property int index

          Layout.fillWidth: true
          Layout.fillHeight: true
          radius: sessionBox.rowRadius
          color: hovered ? Settings.colors.surfaceRaised : "transparent"
          onClicked: {
            Runtime.settingsOpen = false;
            Runtime.openPowerMenu(modelData.id);
          }


          Hairline { visible: session.index > 0; vertical: true }

          Row {
            anchors.centerIn: parent
            spacing: 8

            MyIcon {
              anchors.verticalCenter: parent.verticalCenter
              icon: session.modelData.icon
              size: 14
              color: session.hovered ? Settings.colors.accent : Settings.colors.textMuted
            }

            StyledText {
              anchors.verticalCenter: parent.verticalCenter
              text: session.modelData.label
              font.pixelSize: 12
            }
          }
        }
      }
    }
  }
}
