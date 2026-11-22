import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import qs.data
import qs.components
import qs.services

LazyLoader {
  active: Runtime.powerMenuOpen

  Modal {
    id: win
    namespace: "powermenu"
    onDismissed: close()

    readonly property var actions: [
      { id: "lock",     label: "Lock",      key: "L", icon: "system-lock-screen-symbolic",    confirm: false },
      { id: "suspend",  label: "Sleep",     key: "S", icon: "weather-clear-night-symbolic",   confirm: false },
      { id: "logout",   label: "Log out",   key: "E", icon: "system-log-out-symbolic",    confirm: true },
      { id: "reboot",   label: "Restart",   key: "R", icon: "view-refresh-symbolic",    confirm: true },
      { id: "poweroff", label: "Power off", key: "P", icon: "system-shutdown-symbolic",    confirm: true },
    ]

    // starts on the action it was opened for, e.g. from the settings tiles
    property int current: Math.max(0, actions.findIndex(a => a.id === Runtime.powerMenuAction))
    property string armed: ""

    function close(): void {
      Runtime.powerMenuOpen = false;
    }

    function run(action: var): void {
      if (action.confirm && armed !== action.id) {
        armed = action.id;
        return;
      }
      close();
      switch (action.id) {
      case "lock": Runtime.lock(); break;
      case "suspend": System.power("Suspend"); break;
      case "logout": Hyprland.dispatch("hl.dsp.exit()"); break;
      case "reboot": System.power("Reboot"); break;
      case "poweroff": System.power("PowerOff"); break;
      }
    }

    Timer { running: win.armed !== ""; interval: 3000; onTriggered: win.armed = "" }

    ColumnLayout {
      id: content
      spacing: 24
      focus: true

      Keys.onLeftPressed: win.current = (win.current + win.actions.length - 1) % win.actions.length
      Keys.onRightPressed: win.current = (win.current + 1) % win.actions.length
      Keys.onTabPressed: win.current = (win.current + 1) % win.actions.length
      Keys.onReturnPressed: win.run(win.actions[win.current])
      Keys.onEnterPressed: win.run(win.actions[win.current])
      Keys.onSpacePressed: win.run(win.actions[win.current])
      Keys.onPressed: (e) => {
        const i = win.actions.findIndex(a => a.key === e.text.toUpperCase());
        if (i >= 0) {
          win.current = i;
          win.run(win.actions[i]);
          e.accepted = true;
        }
      }

      ColumnLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 2

        RowLayout {
          Layout.alignment: Qt.AlignHCenter
          spacing: 6

          StyledText { text: Time.hours; serif: true; font.pixelSize: 44 }
          StyledText { text: Time.minutes; serif: true; font.italic: true; font.pixelSize: 44; color: Settings.colors.textMuted }
          StyledText {
            visible: text !== ""
            Layout.alignment: Qt.AlignBaseline
            text: Time.period.toLowerCase()
            serif: true
            font.italic: true
            font.pixelSize: 18
            color: Settings.colors.accent
          }
        }

        StyledText {
          Layout.alignment: Qt.AlignHCenter
          text: `${Settings.username} · ${Time.longDate}`
          color: Settings.colors.textMuted
          font.pixelSize: 13
        }
      }

      RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 10

        Repeater {
          model: win.actions

          Clickable {
            id: tile
            onHoveredChanged: if (hovered) win.current = index
            onClicked: win.run(modelData)
            required property var modelData
            required property int index
            readonly property bool selected: win.current === index
            readonly property bool isArmed: win.armed === modelData.id

            implicitWidth: 112
            implicitHeight: 112
            radius: Settings.radiusMd
            color: isArmed ? Settings.colors.error
                 : selected ? Settings.colors.accentSoft
                 : Settings.colors.base
            border.width: selected || isArmed ? 2 : 1
            border.color: isArmed ? Settings.colors.error : selected ? Settings.colors.accent : Settings.colors.borderStrong


            ColumnLayout {
              anchors.centerIn: parent
              spacing: 10

              MyIcon {
                Layout.alignment: Qt.AlignHCenter
                icon: tile.modelData.icon
                size: 28
                color: tile.isArmed ? Settings.colors.textOnAccent : tile.selected ? Settings.colors.accent : Settings.colors.text
              }

              StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: tile.isArmed ? "Sure?" : tile.modelData.label
                font.pixelSize: 12
                font.weight: Font.DemiBold
                color: tile.isArmed ? Settings.colors.textOnAccent : Settings.colors.text
              }
            }

            StyledText {
              anchors { top: parent.top; right: parent.right; margins: 8 }
              text: tile.modelData.key
              mono: true
              font.pixelSize: 11
              color: tile.isArmed ? Settings.colors.textOnAccent : Settings.colors.textMuted
            }
          }
        }
      }

      Caption {
        Layout.alignment: Qt.AlignHCenter
        text: win.armed !== "" ? "Click again or press Enter to confirm" : "←/→ to choose · Enter to select · Esc to close"
      }
    }
  }
}
