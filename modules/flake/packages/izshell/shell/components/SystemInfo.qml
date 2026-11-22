import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.data

// System information as numbered rows, with the values set
// in the serif. Read once each time the page opens.
ColumnLayout {
  id: root

  property var rows: []

  spacing: 0

  // one "label<TAB>value" line per row
  Process {
    running: true
    command: ["sh", "-c", `
      . /etc/os-release
      gen=$(readlink /nix/var/nix/profiles/system | sed 's/^system-\\([0-9]*\\)-link$/\\1/')
      built=$(date -d @"$(stat -c %Y /nix/var/nix/profiles/system-$gen-link)" '+%-d %b %Y, %H:%M')
      gpu=$(sed -n 's/^Model:[[:space:]]*//p' /proc/driver/nvidia/gpus/*/information 2>/dev/null | head -1)
      [ -n "$gpu" ] || gpu=$(for c in /sys/class/drm/card[0-9]; do basename "$(readlink $c/device/driver)"; done | sort -u | paste -sd, -)
      up=$(awk '{d=int($1/86400); h=int($1%86400/3600); m=int($1%3600/60); printf (d ? d "d " : "") h "h " m "m"}' /proc/uptime)
      printf 'Host\\t%s\\n' "$(cat /etc/hostname 2>/dev/null || uname -n)"
      printf 'OS\\t%s\\n' "$PRETTY_NAME"
      printf 'Generation\\t%s · built %s\\n' "$gen" "$built"
      printf 'Revision\\t%s\\n' "$(nixos-version --configuration-revision 2>/dev/null || echo unknown)"
      printf 'Kernel\\t%s\\n' "$(uname -r)"
      printf 'CPU\\t%s\\n' "$(sed -n 's/^model name[[:space:]]*: //p' /proc/cpuinfo | head -1)"
      printf 'GPU\\t%s\\n' "$gpu"
      printf 'Memory\\t%s\\n' "$(awk '/MemTotal/{t=$2} /MemAvailable/{a=$2} END{printf "%.1f GB / %.1f GB", (t-a)/1048576, t/1048576}' /proc/meminfo)"
      printf 'Disk\\t%s\\n' "$(df -h / --output=used,size | tail -1 | awk '{print $1 " / " $2}')"
      printf 'Uptime\\t%s\\n' "$up"
    `]
    stdout: StdioCollector {
      onStreamFinished: root.rows = text.trim().split("\n").map(l => l.split("\t"))
    }
  }

  Repeater {
    model: root.rows

    ColumnLayout {
      id: line
      required property var modelData
      required property int index
      Layout.fillWidth: true
      spacing: 0

      RowLayout {
        Layout.fillWidth: true
        Layout.topMargin: 10
        Layout.bottomMargin: 10
        spacing: 14

        Rectangle {
          implicitWidth: 22
          implicitHeight: 22
          radius: Settings.pill(width)
          color: "transparent"
          border.width: 1
          border.color: Settings.colors.borderStrong

          StyledText {
            anchors.centerIn: parent
            text: line.index + 1
            mono: true
            font.pixelSize: 10
            color: Settings.colors.textMuted
          }
        }

        StyledText {
          Layout.preferredWidth: 90
          text: line.modelData[0]
          color: Settings.colors.textMuted
          font.pixelSize: 13
        }

        StyledText {
          Layout.fillWidth: true
          text: line.modelData[1] ?? ""
          color: Settings.colors.text
          font.pixelSize: 13
        }
      }

      Rule { visible: line.index < root.rows.length - 1 }
    }
  }
}
