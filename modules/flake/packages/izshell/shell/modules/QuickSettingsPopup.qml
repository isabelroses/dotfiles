import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Qt.labs.qmlmodels
import Quickshell
import Quickshell.Widgets
import qs.data
import qs.components
import qs.services

// Quick settings, media and notifications in one sheet. Quick settings sit
// nearest the bar's far end: at the bottom, or at the top when the bar is on top.
LazyLoader {
  active: Surfaces.quickSettingsOpen

  SidePanel {
    namespace: "quicksettings"
    // always only as tall as its content (the feed scrolls past a cap); stacked
    // cards cover the sheet rather than stretching it
    fill: false
    // escape and the close button take the top stacked card off first
    onCloseRequested: {
      if (qs.cardOpen || Surfaces.wifiPasswordOpen) Surfaces.dismiss();
      else Surfaces.close("quickSettings");
    }

    readonly property list<string> layout: BarPlacement.side === "top"
      ? ["controls", "media", "notifications"]
      : ["notifications", "media", "controls"]
    readonly property real maxListHeight: (screen?.height ?? 1080) * 0.55

    GridLayout {
      anchors.fill: parent
      columns: 1
      rowSpacing: 12

      readonly property bool covered: qs.cardOpen || Surfaces.wifiPasswordOpen
      opacity: covered ? 0.35 : 1
      scale: covered ? 0.97 : 1
      transformOrigin: Item.Top
      Behavior on opacity { Anim {} }
      Behavior on scale { Anim {} }

      RowLayout {
        Layout.row: layout.indexOf("controls") * 2
        Layout.fillWidth: true
        Layout.leftMargin: 2
        spacing: 12

        ClippingWrapperRectangle {
          implicitWidth: 64
          implicitHeight: 64
          radius: Theme.cardRadius
          color: Theme.colors.overlay
          border.color: Theme.colors.border
          border.width: 1

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
          spacing: 0

          StyledText {
            Layout.fillWidth: true
            text: `${Time.greeting},`
            color: Theme.colors.textMuted
            font.pixelSize: 12
          }

          StyledText {
            Layout.fillWidth: true
            text: Settings.general.username
            serif: true
            font.pixelSize: 24
          }

          StyledText {
            Layout.fillWidth: true
            text: Time.longDate
            color: Theme.colors.textMuted
            font.pixelSize: 12
          }
        }

        IconButton {
          icon: "emblem-system-symbolic"
          size: 16
          padding: 9
          color: Theme.colors.textMuted
          onClicked: Surfaces.openSettings("home")
        }

        IconButton {
          icon: "system-shutdown-symbolic"
          size: 16
          padding: 9
          color: Theme.colors.textMuted
          onClicked: Surfaces.openPowerMenu("")
        }
      }

      QuickSettings {
        id: qs
        stackHost: stack
        Layout.row: layout.indexOf("controls") * 2 + 1
      }

      MediaPlayers {
        Layout.row: Math.max(0, layout.indexOf("media")) * 2
        visible: Media.recent && layout.includes("media")
      }

      RowLayout {
        visible: layout.includes("notifications") && Notifications.list.length > 0
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
          radius: Theme.radiusXs
          color: Theme.colors.accentSoft

          StyledText {
            id: countText
            anchors.centerIn: parent
            text: Notifications.list.length
            mono: true
            color: Theme.colors.accent
            font.pixelSize: 11
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
        // so a content-sized sheet still leaves room for the feed
        implicitHeight: feedColumn.implicitHeight
        visible: layout.includes("notifications") && Notifications.list.length > 0
        Layout.row: Math.max(0, layout.indexOf("notifications")) * 2 + 1
        Layout.fillWidth: true
        Layout.fillHeight: true

        property bool historyOpen: false

        function grouped(items: var, timeOf: var): var {
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

        ColumnLayout {
          id: feedColumn
          anchors.fill: parent
          spacing: 8

          Rule {}

          ScrollList {
            id: notiList
            model: feedArea.liveFeed
            Layout.fillWidth: true
            visible: Notifications.list.length > 0
            Layout.preferredHeight: Math.min(contentHeight, maxListHeight)
            spacing: 6

            delegate: DelegateChooser {
              role: "kind"
              DelegateChoice { roleValue: "header"; FeedHeader {} }
              DelegateChoice { roleValue: "item"; FeedCard {} }
            }
          }

          ScrollList {
            id: histList
            visible: feedArea.historyOpen
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, maxListHeight * 0.6)
            model: feedArea.historyFeed
            spacing: 6

            delegate: DelegateChooser {
              role: "kind"
              DelegateChoice { roleValue: "header"; FeedHeader {} }
              DelegateChoice { roleValue: "item"; HistoryCard {} }
            }
          }

          Clickable {
            onClicked: feedArea.historyOpen = !feedArea.historyOpen
            visible: Notifications.history.length > 0
            Layout.fillWidth: true
            implicitHeight: 32
            radius: Theme.radiusSm
            color: hovered ? Theme.colors.surfaceRaised : "transparent"
            border.width: 1
            border.color: Theme.colors.border

            RowLayout {
              anchors { fill: parent; leftMargin: 10; rightMargin: 4 }
              spacing: 8

              MyIcon {
                icon: "go-next-symbolic"
                size: 10
                color: Theme.colors.textMuted
                rotation: feedArea.historyOpen ? -90 : 0
                Behavior on rotation { Anim { duration: Theme.animFast } }
              }

              Caption {
                Layout.fillWidth: true
                text: `History · ${Notifications.history.length}`
                font.weight: Font.DemiBold
              }

              IconButton {
                visible: feedArea.historyOpen
                icon: "edit-clear-all-symbolic"
                size: 12
                color: Theme.colors.textMuted
                onClicked: Notifications.clearHistory()
              }
            }
          }
        }
      }
    }

    Item {
      id: stack
      anchors.fill: parent

      MouseArea {
        anchors.fill: parent
        enabled: qs.cardOpen || Surfaces.wifiPasswordOpen
        onClicked: Surfaces.dismiss()
      }

      Loader {
        z: 3
        active: Surfaces.wifiPasswordOpen
        width: parent.width
        y: BarPlacement.side === "top" ? 0 : parent.height - height
        sourceComponent: WifiPasswordPrompt {
          implicitWidth: stack.width
          radius: Theme.cardRadius
        }
      }
    }

    component FeedHeader: StyledText {
      required property var modelData
      width: ListView.view.width
      topPadding: 6
      leftPadding: 4
      text: modelData.label
      color: Theme.colors.textMuted
      font.pixelSize: 11
      font.weight: Font.DemiBold
    }

    component FeedCard: NotificationCard {
      required property var modelData
      width: ListView.view.width
      notification: modelData.item
    }

    component HistoryCard: Box {
      id: histCard
      required property var modelData
      readonly property var entry: modelData.item
      readonly property int entryIndex: modelData.index
      width: ListView.view.width
      implicitHeight: histRow.implicitHeight + 16
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
            }
            Caption {
              text: histCard.entry.time ? Notifications.relativeTime(histCard.entry.time) : ""
              mono: true
            }
          }

          Caption {
            Layout.fillWidth: true
            visible: text !== ""
            text: histCard.entry.body ?? ""
            textFormat: Text.PlainText
            maximumLineCount: 1
          }
        }

        IconButton {
          Layout.alignment: Qt.AlignTop
          icon: "window-close-symbolic"
          size: 10
          padding: 5
          color: Theme.colors.textSubtle
          onClicked: Notifications.removeHistory(histCard.entryIndex)
        }
      }
    }
  }
}
