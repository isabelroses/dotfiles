import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.data

// A small live mock of the shell for the Appearance page: the bar and the
// quick settings sheet in the current theme, accent, rounding and bar style,
// drawn the way the real ones are (floating cards or one attached strip).
Box {
  id: root

  // the preview is roughly half scale, so corners shrink with it
  readonly property real s: 0.6
  readonly property real cardR: Theme.cardRadius * s
  readonly property real ctrlR: Theme.radiusMd * s
  readonly property real gap: BarPlacement.floating ? 6 : 0

  implicitHeight: 196
  clip: true

  // a mock card: the base fill with the soft outline floating cards get, or
  // a single hairline on the side away from the bar when attached
  component MockCard: Rectangle {
    property bool attached: !BarPlacement.floating
    color: Theme.colors.base
    radius: attached ? 0 : root.cardR
    border.width: attached ? 0 : 1
    border.color: Theme.colors.border
  }

  RowLayout {
    anchors { fill: parent; margins: BarPlacement.floating ? 10 : 1 }
    spacing: root.gap
    layoutDirection: BarPlacement.onRight ? Qt.RightToLeft : Qt.LeftToRight

    // the bar: three cards when floating, one strip when attached
    Item {
      Layout.fillHeight: true
      implicitWidth: 30

      MockCard { visible: !BarPlacement.floating; anchors.fill: parent }

      Column {
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter }
        spacing: 4

        MockCard {
          attached: false
          visible: BarPlacement.floating
          width: 30
          height: head.implicitHeight + 10
          border.width: 1

          Column {
            id: head
            anchors.centerIn: parent
            spacing: 4

            Rectangle {
              width: 16; height: 16
              radius: Math.max(0, root.cardR - 3)
              color: Theme.colors.accentSoft
              MyIcon { anchors.centerIn: parent; icon: "nix-snowflake"; size: 9; color: Theme.colors.accent }
            }

            Repeater {
              model: 2
              Rectangle {
                required property int index
                readonly property color tint: Settings.bar.workspace_colours ? Theme.colors.pops[index % Theme.colors.pops.length] : Theme.colors.accent
                width: 16; height: 16
                radius: Math.max(0, root.cardR - 3)
                color: index === 0 ? Utils.withAlpha(Theme.colors.text, 0.10) : "transparent"
                border.width: 1
                border.color: Utils.withAlpha(Theme.colors.text, index === 0 ? 0.18 : 0.10)

                Rectangle {
                  anchors.centerIn: parent
                  width: parent.index === 0 ? 6 : 3
                  height: width
                  radius: Theme.pill(width)
                  color: parent.index === 0 ? parent.tint : Theme.colors.text
                  opacity: parent.index === 0 ? 1 : 0.35
                }
              }
            }
          }
        }

        // attached: the same groups straight on the strip
        Column {
          visible: !BarPlacement.floating
          anchors.horizontalCenter: parent.horizontalCenter
          topPadding: 5
          spacing: 4

          Rectangle {
            width: 16; height: 16
            radius: Math.max(0, root.cardR - 3)
            color: Theme.colors.accentSoft
            MyIcon { anchors.centerIn: parent; icon: "nix-snowflake"; size: 9; color: Theme.colors.accent }
          }

          Repeater {
            model: 2
            Rectangle {
              required property int index
              width: 16; height: 16
              radius: Math.max(0, root.cardR - 3)
              color: index === 0 ? Utils.withAlpha(Theme.colors.text, 0.10) : "transparent"
              border.width: 1
              border.color: Utils.withAlpha(Theme.colors.text, index === 0 ? 0.18 : 0.10)
            }
          }
        }
      }

      MockCard {
        attached: !BarPlacement.floating
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: BarPlacement.floating ? 0 : 5 }
        width: 30
        height: clock.implicitHeight + 8
        color: BarPlacement.floating ? Theme.colors.base : "transparent"
        border.width: BarPlacement.floating ? 1 : 0

        Column {
          id: clock
          anchors.centerIn: parent
          spacing: -4
          StyledText { anchors.horizontalCenter: parent.horizontalCenter; text: Time.hours; serif: true; font.pixelSize: 13 }
          StyledText { anchors.horizontalCenter: parent.horizontalCenter; text: Time.minutes; serif: true; font.italic: true; font.pixelSize: 13; color: Theme.colors.textMuted }
        }
      }
    }

    MockCard {
      Layout.fillWidth: true
      Layout.fillHeight: true
      attached: !BarPlacement.floating
      border.width: BarPlacement.floating ? 1 : 0

      // attached sheets keep the one hairline on their far edge
      Rectangle {
        visible: !BarPlacement.floating
        x: BarPlacement.onRight ? 0 : parent.width - 1
        width: 1
        height: parent.height
        color: Theme.colors.border
      }

      ColumnLayout {
        anchors { fill: parent; margins: 12 }
        spacing: 8

        StyledText { text: "Notifications"; serif: true; font.pixelSize: 15 }

        Rectangle { Layout.fillWidth: true; implicitHeight: 1; color: Theme.colors.border }

        Item { Layout.fillHeight: true }

        RowLayout {
          spacing: 8

          ClippingWrapperRectangle {
            implicitWidth: 22
            implicitHeight: 22
            radius: root.ctrlR
            color: Theme.colors.overlay
            border.width: 1
            border.color: Theme.colors.accent

            Image {
              source: Settings.profilePicture
              fillMode: Image.PreserveAspectCrop
              sourceSize: Qt.size(44, 44)
              mipmap: true
              asynchronous: true
            }
          }

          StyledText {
            text: `${Time.greeting}, ${Settings.general.username}`
            font.pixelSize: 11
            font.weight: Font.DemiBold
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 6

          Repeater {
            model: [{ label: "Wi-Fi", on: true }, { label: "Bluetooth", on: false }]

            Rectangle {
              id: chip
              required property var modelData
              Layout.fillWidth: true
              implicitHeight: 30
              radius: root.ctrlR
              color: modelData.on ? Utils.withAlpha(Theme.colors.accent, 0.14) : Theme.colors.surface
              border.width: 1
              border.color: modelData.on ? Utils.withAlpha(Theme.colors.accent, 0.5) : Theme.colors.border

              RowLayout {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 8 }
                spacing: 6

                Rectangle {
                  implicitWidth: 16; implicitHeight: 16
                  radius: root.ctrlR
                  color: chip.modelData.on ? Theme.colors.accent : Theme.colors.overlay
                }

                StyledText {
                  text: chip.modelData.label
                  font.pixelSize: 10
                  font.weight: Font.DemiBold
                }
              }
            }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 18
          radius: Theme.pill(height) * root.s
          color: Theme.colors.surfaceRaised
          border.width: 1
          border.color: Theme.colors.border

          Rectangle {
            width: parent.width * 0.55
            height: parent.height
            radius: parent.radius
            color: Theme.colors.accent
          }
        }
      }
    }
  }
}
