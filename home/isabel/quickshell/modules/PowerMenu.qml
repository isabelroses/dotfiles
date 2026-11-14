import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.data
import qs.components

LazyLoader {
  active: Runtime.powerMenuOpen

  Modal {
    id: win
    namespace: "powermenu"
    onDismissed: close()

    readonly property var actions: [
      { id: "lock",     label: "Lock",      key: "L", icon: "system-lock-screen-symbolic", tint: Settings.colors.sky,    confirm: false },
      { id: "suspend",  label: "Sleep",     key: "S", icon: "weather-clear-night-symbolic", tint: Settings.colors.blue,   confirm: false },
      { id: "logout",   label: "Log out",   key: "E", icon: "system-log-out-symbolic",     tint: Settings.colors.yellow, confirm: true },
      { id: "reboot",   label: "Restart",   key: "R", icon: "system-reboot-symbolic",      tint: Settings.colors.peach,  confirm: true },
      { id: "poweroff", label: "Power off", key: "P", icon: "system-shutdown-symbolic",    tint: Settings.colors.red,    confirm: true },
    ]

    property int current: 0
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
      case "suspend": Runtime.lock(); Quickshell.execDetached(["sh", "-c", "sleep 0.5; systemctl suspend"]); break;
      case "logout": Quickshell.execDetached(["hyprctl", "dispatch", "exit"]); break;
      case "reboot": Quickshell.execDetached(["systemctl", "reboot"]); break;
      case "poweroff": Quickshell.execDetached(["systemctl", "poweroff"]); break;
      }
    }

    Timer {
      running: win.armed !== ""
      interval: 3000
      onTriggered: win.armed = ""
    }

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

        StyledText {
          Layout.alignment: Qt.AlignHCenter
          text: `${Time.hours}:${Time.minutes}${Time.period ? " " + Time.period : ""}`
          mono: true
          font.pixelSize: 40
          font.weight: Font.Bold
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
            color: isArmed ? modelData.tint
                 : selected ? Utils.withAlpha(modelData.tint, 0.14)
                 : Settings.colors.base
            border.width: selected || isArmed ? 2 : 1
            border.color: selected || isArmed ? modelData.tint : Settings.colors.borderStrong

            Behavior on color { ColorAnimation { duration: Settings.animFast } }

            ColumnLayout {
              anchors.centerIn: parent
              spacing: 10

              MyIcon {
                Layout.alignment: Qt.AlignHCenter
                icon: tile.modelData.icon
                size: 28
                color: tile.isArmed ? Settings.colors.textOnAccent : tile.modelData.tint
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
              font.pixelSize: 10
              color: tile.isArmed ? Settings.colors.textOnAccent : Settings.colors.textSubtle
            }
          }
        }
      }

      StyledText {
        Layout.alignment: Qt.AlignHCenter
        text: win.armed !== "" ? "Click again or press Enter to confirm" : "←/→ to choose · Enter to select · Esc to close"
        color: Settings.colors.textSubtle
        font.pixelSize: 11
      }
    }
  }
}
