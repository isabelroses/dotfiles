import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.data

Rectangle {
  id: root

  implicitHeight: 196
  radius: Settings.radiusMd
  color: Settings.colors.surface
  border.width: 1
  border.color: Settings.colors.border
  clip: true

  RowLayout {
    anchors { fill: parent; margins: 12 }
    spacing: 0
    layoutDirection: Settings.barOnRight ? Qt.RightToLeft : Qt.LeftToRight

    Rectangle {
      Layout.fillHeight: true
      implicitWidth: 34
      color: Settings.colors.base
      border.width: 1
      border.color: Settings.colors.border

      ColumnLayout {
        anchors { top: parent.top; horizontalCenter: parent.horizontalCenter; topMargin: 6 }
        spacing: 4

        Rectangle {
          Layout.alignment: Qt.AlignHCenter
          implicitWidth: 22
          implicitHeight: 22
          radius: Settings.radiusSm
          color: "transparent"
          border.width: 1
          border.color: Settings.colors.accent

          MyIcon {
            anchors.centerIn: parent
            icon: "nix-snowflake"
            size: 12
            color: Settings.colors.accent
          }
        }

        Repeater {
          model: 4
          Rectangle {
            required property int index
            readonly property color tint: Config.get("bar.workspace_colours") ? Settings.colors.pops[index % Settings.colors.pops.length] : Settings.colors.accent
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 18
            implicitHeight: 18
            radius: Settings.radiusSm
            color: index === 1 ? tint : Utils.withAlpha(tint, 0.08)
            border.width: 1
            border.color: index === 1 ? tint : Utils.withAlpha(tint, 0.55)

            StyledText {
              anchors.centerIn: parent
              text: parent.index + 1
              mono: true
              font.pixelSize: 8
              font.weight: Font.Bold
              color: parent.index === 1 ? Settings.colors.textOnAccent : parent.tint
            }
          }
        }
      }

      StyledText {
        anchors { bottom: parent.bottom; horizontalCenter: parent.horizontalCenter; bottomMargin: 8 }
        text: Time.use24h ? "14\n32" : "02\n32"
        mono: true
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 9
        font.weight: Font.Bold
        lineHeight: 0.85
      }
    }

    Rectangle {
      Layout.fillHeight: true
      Layout.fillWidth: true
      color: Settings.colors.base
      border.width: 1
      border.color: Settings.colors.border

      ColumnLayout {
        anchors { fill: parent; margins: 10 }
        spacing: 8

        RowLayout {
          spacing: 8
          ClippingWrapperRectangle {
            implicitWidth: 22
            implicitHeight: 22
            radius: Settings.radiusRound
            color: Settings.colors.overlay
            border.width: 1
            border.color: Settings.colors.accent

            Image {
              source: Settings.profilePicture
              fillMode: Image.PreserveAspectCrop
              sourceSize: Qt.size(44, 44)
              mipmap: true
              asynchronous: true
            }
          }
          StyledText {
            text: `${Time.greeting}, ${Settings.username}`
            font.pixelSize: 11
            font.weight: Font.DemiBold
          }
        }

        RowLayout {
          Layout.fillWidth: true
          spacing: 6

          Repeater {
            model: [
              { label: "Wi-Fi", tint: Settings.colors.sky, on: true },
              { label: "Bluetooth", tint: Settings.colors.blue, on: false },
            ]

            Rectangle {
              required property var modelData
              Layout.fillWidth: true
              implicitHeight: 34
              radius: Settings.radiusMd
              color: modelData.on ? modelData.tint : Settings.colors.surface
              border.width: 1
              border.color: modelData.on ? modelData.tint : Settings.colors.border

              StyledText {
                anchors { left: parent.left; verticalCenter: parent.verticalCenter; leftMargin: 10 }
                text: parent.modelData.label
                font.pixelSize: 10
                font.weight: Font.DemiBold
                color: parent.modelData.on ? Settings.colors.textOnAccent : Settings.colors.text
              }
            }
          }
        }

        Rectangle {
          Layout.fillWidth: true
          implicitHeight: 22
          radius: Settings.radiusSm
          color: Settings.colors.surfaceRaised
          border.width: 1
          border.color: Settings.colors.border

          Rectangle {
            width: parent.width * 0.55
            height: parent.height
            radius: Settings.radiusSm
            color: Settings.colors.accent
          }
        }

        Item { Layout.fillHeight: true }

        RowLayout {
          Layout.fillWidth: true
          spacing: 6

          Rectangle { implicitWidth: 5; implicitHeight: 5; color: Settings.colors.accent }

          StyledText {
            Layout.fillWidth: true
            text: "NOTIFICATIONS"
            font.pixelSize: 8
            font.weight: Font.DemiBold
            font.letterSpacing: 1
            color: Settings.colors.textSubtle
          }

          Rectangle {
            implicitWidth: 44
            implicitHeight: 18
            radius: Settings.radiusSm
            color: Settings.colors.accent

            StyledText {
              anchors.centerIn: parent
              text: "Button"
              font.pixelSize: 9
              font.weight: Font.DemiBold
              color: Settings.colors.textOnAccent
            }
          }
        }
      }
    }
  }
}
