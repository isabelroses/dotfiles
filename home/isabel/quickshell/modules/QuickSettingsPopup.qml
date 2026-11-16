import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Quickshell
import Quickshell.Widgets
import qs.data
import qs.components
import qs.services

// Quick settings, media and notifications in one sheet. Quick settings sit
// nearest the bar's far end: at the bottom, or at the top when the bar is on top.
LazyLoader {
  active: Runtime.quickSettingsOpen

  SidePanel {
    namespace: "quicksettings"
    onCloseRequested: Runtime.quickSettingsOpen = false

    readonly property list<string> layout: Settings.barSide === "top"
      ? ["controls", "media", "notifications"]
      : ["notifications", "media", "controls"]
    readonly property real maxListHeight: (screen?.height ?? 1080) * 0.55

    GridLayout {
      anchors.fill: parent
      columns: 1
      rowSpacing: 12

      RowLayout {
        Layout.row: layout.indexOf("controls") * 2
        Layout.fillWidth: true
        spacing: 12

        ClippingWrapperRectangle {
          implicitWidth: 64
          implicitHeight: 64
          radius: Settings.radiusRound
          color: Settings.colors.overlay
          border.color: Settings.colors.accent
          border.width: 2

          Image {
            source: Settings.profilePicture
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            mipmap: true
            sourceSize: Qt.size(128, 128)
          }
        }

        ColumnLayout {
          Layout.fillWidth: true
          spacing: 1

          StyledText {
            Layout.fillWidth: true
            text: `${Time.greeting}, ${Settings.username}`
            font.pixelSize: 17
            font.weight: Font.DemiBold
            elide: Text.ElideRight
          }

          StyledText {
            Layout.fillWidth: true
            text: Time.longDate
            color: Settings.colors.textMuted
            font.pixelSize: 13
          }
        }

        IconButton {
          icon: "emblem-system-symbolic"
          size: 18
          padding: 10
          color: Settings.colors.textMuted
          onClicked: Runtime.openSettings()
        }

        IconButton {
          icon: "system-shutdown-symbolic"
          size: 18
          padding: 10
          color: Runtime.powerMenuOpen ? Settings.colors.error : Settings.colors.textMuted
          onClicked: Runtime.openPowerMenu()
        }
      }

      QuickSettings {
        Layout.row: layout.indexOf("controls") * 2 + 1
      }

      MediaPlayers {
        Layout.row: Math.max(0, layout.indexOf("media")) * 2
        visible: Media.recent && layout.includes("media")
      }

      RowLayout {
        visible: layout.includes("notifications")
        Layout.row: Math.max(0, layout.indexOf("notifications")) * 2
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
          opacity: Notifications.list.length > 0 ? 1 : 0.4
          implicitHeight: 24
          fontSize: 11
          border.width: 0
          text: "Clear all"
          onClicked: [...Notifications.list].forEach(n => n.dismiss())
        }
      }

      Item {
        id: feedArea
        visible: layout.includes("notifications")
        Layout.row: Math.max(0, layout.indexOf("notifications")) * 2 + 1
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
          id: feedColumn
          anchors.fill: parent
          spacing: 8

          StyledText {
            visible: Notifications.list.length === 0
            Layout.fillWidth: true
            Layout.fillHeight: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            text: Notifications.dndEnabled ? "Do not disturb is on" : "Nothing new"
            color: Settings.colors.textSubtle
            font.pixelSize: 12
          }

          ListView {
            id: notiList
            model: feedArea.liveFeed
            Layout.fillWidth: true
            visible: Notifications.list.length > 0
            Layout.fillHeight: true
            spacing: 6
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: Loader {
              required property var modelData
              width: ListView.view.width
              sourceComponent: modelData.kind === "header" ? headerComponent : liveComponent
            }
          }

          ListView {
            id: histList
            visible: feedArea.historyOpen
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, maxListHeight * 0.6)
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
