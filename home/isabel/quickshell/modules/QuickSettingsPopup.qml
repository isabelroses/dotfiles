import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Widgets
import Quickshell.Wayland
import Quickshell.Services.Notifications as QsNotifications
import qs.data
import qs.components
import qs.services

LazyLoader {
  id: loader
  active: Runtime.quickSettingsOpen

  PanelWindow {
    id: popup
    color: "transparent"

    anchors {
      top: true
      bottom: true
      left: !Settings.barOnRight
      right: Settings.barOnRight
    }
    margins.left: Settings.barOnRight ? 0 : Settings.barWidth
    margins.right: Settings.barOnRight ? Settings.barWidth : 0

    implicitWidth: 380
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quicksettings"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand

    Rectangle {
      id: sheet
      width: parent.width
      height: parent.height
      color: Settings.colors.base
      focus: true

      Rectangle {
        anchors { top: parent.top; bottom: parent.bottom }
        x: Settings.barOnRight ? 0 : parent.width - width
        width: 1
        color: Settings.colors.border
      }

      Keys.onEscapePressed: Runtime.quickSettingsOpen = false

      x: Settings.barOnRight ? 16 : -16
      opacity: 0
      Component.onCompleted: { x = 0; opacity = 1; }
      Behavior on x { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic } }
      Behavior on opacity { NumberAnimation { duration: Settings.animNormal } }

      ColumnLayout {
        anchors { fill: parent; margins: 14 }
        spacing: 14

        RowLayout {
          Layout.fillWidth: true
          Layout.leftMargin: 2
          spacing: 12

          ClippingWrapperRectangle {
            implicitWidth: 56
            implicitHeight: 56
            radius: Settings.radiusRound
            color: Settings.colors.overlay
            border.color: Settings.colors.accent
            border.width: 2

            Image {
              source: Settings.profilePicture
              fillMode: Image.PreserveAspectCrop
              asynchronous: true
              smooth: true
              mipmap: true
              sourceSize: Qt.size(112, 112)
              onStatusChanged: if (status === Image.Error) console.error("Failed to load profile picture:", source)
            }
          }

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 1

            StyledText {
              Layout.fillWidth: true
              text: `${Time.greeting}, ${Settings.username}`
              font.pixelSize: 15
              font.weight: Font.DemiBold
              elide: Text.ElideRight
            }

            StyledText {
              Layout.fillWidth: true
              text: Time.longDate
              color: Settings.colors.textMuted
              font.pixelSize: 12
            }
          }

          IconButton {
            icon: "emblem-system-symbolic"
            size: 16
            padding: 10
            color: Settings.colors.textMuted
            onClicked: Runtime.openSettings()
          }

          BoxButton {
            icon: "system-shutdown-symbolic"
            filled: Runtime.powerMenuOpen
            fillColor: Settings.colors.error
            onClicked: Runtime.openPowerMenu()
          }
        }

        QuickSettings {}

        MediaPlayers {}

        Item {
          visible: !Config.get("quick_settings.show_notifications")
          Layout.fillHeight: true
        }

        RowLayout {
          visible: Config.get("quick_settings.show_notifications")
          Layout.fillWidth: true
          Layout.topMargin: 2
          Layout.leftMargin: 4
          spacing: 8

          SectionLabel { text: "Notifications" }

          Rectangle {
            visible: Notifications.list.length > 0
            implicitWidth: Math.max(18, countText.implicitWidth + 10)
            implicitHeight: 16
            radius: Settings.radiusXs
            color: Settings.colors.accentSoft

            StyledText {
              id: countText
              anchors.centerIn: parent
              text: Notifications.list.length
              mono: true
              color: Settings.colors.accent
              font.pixelSize: 10
            }
          }

          Item { Layout.fillWidth: true }

          BoxButton {
            visible: Notifications.list.length > 0
            implicitHeight: 24
            fontSize: 11
            border.width: 0
            text: "Clear all"
            onClicked: [...Notifications.list].forEach(n => n.dismiss())
          }
        }

        Item {
          id: feedArea
          visible: Config.get("quick_settings.show_notifications")
          Layout.fillWidth: true
          Layout.fillHeight: true

          property bool historyOpen: false

          function grouped(items, timeOf): var {
            const out = [];
            let group = "";
            items.forEach((item, index) => {
              const g = Notifications.ageGroup(timeOf(item));
              if (g !== group) { out.push({ kind: "header", label: g }); group = g; }
              out.push({ kind: "item", item, index });
            });
            return out;
          }

          readonly property var liveFeed: grouped([...Notifications.list].reverse(), n => Notifications.timeOf(n))
          readonly property var historyFeed: historyOpen ? grouped(Notifications.history, h => h.time) : []

          Component {
            id: headerComponent
            StyledText {
              topPadding: 6
              leftPadding: 4
              text: parent?.modelData?.label ?? ""
              color: Settings.colors.textMuted
              font.pixelSize: 11
              font.weight: Font.DemiBold
            }
          }

          Component {
            id: liveComponent
            NotificationCard {
              notification: parent.modelData.item
            }
          }

          Component {
            id: historyComponent
            Rectangle {
              id: histCard
              readonly property var entry: parent?.modelData?.item ?? ({})
              readonly property int entryIndex: parent?.modelData?.index ?? -1
              implicitHeight: histRow.implicitHeight + 16
              radius: Settings.radiusMd
              color: Settings.colors.surface
              border.width: 1
              border.color: Settings.colors.border
              opacity: 0.85

              RowLayout {
                id: histRow
                anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 10; rightMargin: 4 }
                spacing: 10

                IconImage {
                  asynchronous: true
                  Layout.alignment: Qt.AlignTop
                  implicitSize: 16
                  source: {
                    const icon = histCard.entry.appIcon ?? "";
                    if (icon.startsWith("/")) return "file://" + icon;
                    if (icon.includes("://")) return icon;
                    return Quickshell.iconPath(icon, "dialog-information-symbolic");
                  }
                }

                ColumnLayout {
                  Layout.fillWidth: true
                  spacing: 1

                  RowLayout {
                    Layout.fillWidth: true
                    StyledText {
                      Layout.fillWidth: true
                      text: histCard.entry.summary || histCard.entry.appName || ""
                      font.pixelSize: 12
                      font.weight: Font.DemiBold
                      elide: Text.ElideRight
                    }
                    StyledText {
                      text: histCard.entry.time ? Notifications.relativeTime(histCard.entry.time) : ""
                      mono: true
                      font.pixelSize: 10
                      color: Settings.colors.textSubtle
                    }
                  }

                  StyledText {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: histCard.entry.body ?? ""
                    textFormat: Text.PlainText
                    font.pixelSize: 11
                    color: Settings.colors.textMuted
                    elide: Text.ElideRight
                    maximumLineCount: 1
                  }
                }

                IconButton {
                  Layout.alignment: Qt.AlignTop
                  icon: "window-close-symbolic"
                  size: 10
                  padding: 5
                  color: Settings.colors.textSubtle
                  onClicked: Notifications.removeHistory(histCard.entryIndex)
                }
              }
            }
          }

          ColumnLayout {
            anchors.fill: parent
            spacing: 8

            ListView {
              id: notiList
              Layout.fillWidth: true
              Layout.fillHeight: true
              model: feedArea.liveFeed
              spacing: 6
              clip: true
              boundsBehavior: Flickable.StopAtBounds
              ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

              delegate: Loader {
                required property var modelData
                width: ListView.view.width
                sourceComponent: modelData.kind === "header" ? headerComponent : liveComponent
              }

              ColumnLayout {
                anchors.centerIn: parent
                visible: Notifications.list.length === 0
                spacing: 8

                IconChip {
                  Layout.alignment: Qt.AlignHCenter
                  size: 48
                  color: Settings.colors.surface
                  border.color: Settings.colors.border
                  border.width: 1
                  icon: Notifications.dndEnabled ? "notifications-disabled-symbolic" : "preferences-system-notifications-symbolic"
                  iconSize: 20
                  iconColor: Settings.colors.textSubtle
                }

                StyledText {
                  Layout.alignment: Qt.AlignHCenter
                  text: Notifications.dndEnabled ? "Do not disturb is on" : "You're all caught up"
                  color: Settings.colors.textMuted
                  font.pixelSize: 12
                }
              }
            }

            ListView {
              id: histList
              visible: feedArea.historyOpen
              Layout.fillWidth: true
              Layout.preferredHeight: Math.min(contentHeight, feedArea.height * 0.5)
              model: feedArea.historyFeed
              spacing: 6
              clip: true
              boundsBehavior: Flickable.StopAtBounds
              ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

              delegate: Loader {
                required property var modelData
                width: ListView.view.width
                sourceComponent: modelData.kind === "header" ? headerComponent : historyComponent
              }
            }

            Clickable {
              onClicked: feedArea.historyOpen = !feedArea.historyOpen
              visible: Notifications.history.length > 0
              Layout.fillWidth: true
              implicitHeight: 32
              radius: Settings.radiusSm
              color: hovered ? Settings.colors.surfaceRaised : "transparent"
              border.width: 1
              border.color: Settings.colors.border

              RowLayout {
                anchors { fill: parent; leftMargin: 10; rightMargin: 4 }
                spacing: 8

                MyIcon {
                  icon: "go-next-symbolic"
                  size: 10
                  color: Settings.colors.textMuted
                  rotation: feedArea.historyOpen ? -90 : 0
                  Behavior on rotation { NumberAnimation { duration: Settings.animFast } }
                }

                StyledText {
                  Layout.fillWidth: true
                  text: `History · ${Notifications.history.length}`
                  color: Settings.colors.textMuted
                  font.pixelSize: 11
                  font.weight: Font.DemiBold
                }

                IconButton {
                  visible: feedArea.historyOpen
                  icon: "edit-clear-all-symbolic"
                  size: 12
                  color: Settings.colors.textMuted
                  onClicked: Notifications.clearHistory()
                }
              }
            }
          }
        }
      }
    }
  }
}
