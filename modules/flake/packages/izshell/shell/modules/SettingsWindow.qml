import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import Qt.labs.folderlistmodel
import Quickshell
import qs.data
import qs.components

LazyLoader {
  active: Runtime.settingsOpen

  Modal {
    id: win
    namespace: "settings"
    onDismissed: Runtime.settingsOpen = false

    // "home" and the custom pages are built by hand; the rest are lists of Settings
    property string section: Runtime.settingsPage
    readonly property var sectionInfo: Settings.schema.find(s => s.name === section)
    readonly property bool inSchema: sectionInfo !== undefined && !sectionInfo.custom
    readonly property bool customPage: section === "home" || sectionInfo?.custom === true
    readonly property var pages: Settings.schema.map(s => ({ name: s.name, title: s.title, icon: s.icon }))
    property string query: ""

    // rows in boxed groups: a page's own groups, or search results under the
    // page they come from
    readonly property var groups: {
      const q = query.trim().toLowerCase();
      const out = [];
      for (const sec of Settings.schema) {
        if (q === "" && sec.name !== section) continue;
        for (const e of sec.entries) {
          const hay = `${sec.title} ${e.label} ${e.key} ${e.hint ?? ""}`.toLowerCase();
          if (q !== "" && !hay.includes(q)) continue;
          const title = q === "" ? (e.group ?? "") : sec.title;
          let g = out[out.length - 1];
          if (!g || g.title !== title) out.push(g = { title, rows: [] });
          g.rows.push({ path: `${sec.name}.${e.key}`, entry: e });
        }
      }
      return out;
    }

    Item {
      id: card
      implicitWidth: Math.min(960, win.width - 80)
      // the home page is only as tall as its content; the rest get the full height
      implicitHeight: Math.min(win.section === "home" && win.query === "" ? main.implicitHeight + 2 : 680, win.height - 80)

      CardSurface { raised: true; radius: Theme.sheetRadius }

      RowLayout {
        anchors { fill: parent; margins: 1 }
        spacing: 0

        Item {
          id: sidebar
          visible: win.section !== "home"
          Layout.fillHeight: true
          implicitWidth: 210

          Rectangle {
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right; topMargin: 16; bottomMargin: 16 }
            width: 1
            color: Theme.colors.border
          }

          ColumnLayout {
            anchors { fill: parent; margins: 12 }
            spacing: 2

            Clickable {
              id: back
              Layout.fillWidth: true
              Layout.bottomMargin: 10
              implicitHeight: 32
              radius: Theme.radiusSm
              color: hovered ? Theme.colors.surfaceRaised : "transparent"
              onClicked: {
                search.text = "";
                win.section = "home";
              }

              RowLayout {
                anchors { fill: parent; leftMargin: 8; rightMargin: 8 }
                spacing: 8

                MyIcon { icon: "go-previous-symbolic"; size: 12; color: Theme.colors.textMuted }

                StyledText {
                  Layout.fillWidth: true
                  text: "All settings"
                  color: back.hovered ? Theme.colors.text : Theme.colors.textMuted
                  font.pixelSize: 12
                }
              }
            }

            InputField {
              id: search
              Layout.fillWidth: true
              Layout.bottomMargin: 10
              implicitHeight: 32
              icon: "system-search-symbolic"
              placeholder: "Search"
              clearOnEscape: true
              fontSize: 12
              onTextChanged: win.query = text
            }

            Repeater {
              model: Settings.pageGroups

              ColumnLayout {
                id: pageGroup
                required property var modelData
                required property int index
                Layout.fillWidth: true
                Layout.topMargin: index > 0 ? 10 : 0
                spacing: 2

                StyledText {
                  Layout.leftMargin: 8
                  Layout.bottomMargin: 2
                  text: pageGroup.modelData.title
                  font.pixelSize: 11
                  font.weight: Font.DemiBold
                  color: Theme.colors.textSubtle
                }

                Repeater {
                  model: pageGroup.modelData.names.map(n => win.pages.find(p => p.name === n)).filter(p => p)

                  PanelListItem {
                    id: pageLink
                    required property var modelData
                    Layout.fillWidth: true
                    icon: modelData.icon
                    text: pageLink.modelData.title
                    active: win.query === "" && win.section === modelData.name
                    onClicked: {
                      search.text = "";
                      win.section = modelData.name;
                    }
                  }
                }
              }
            }

            Item { Layout.fillHeight: true }
          }
        }

        ColumnLayout {
          id: main
          Layout.fillWidth: true
          Layout.fillHeight: true
          spacing: 0

          RowLayout {
            Layout.fillWidth: true
            Layout.margins: 20
            Layout.bottomMargin: 8

            StyledText {
              Layout.fillWidth: true
              text: win.query !== "" ? `Results for “${win.query}”`
                : (win.pages.find(p => p.name === win.section)?.title ?? "Settings")
              serif: true
              font.pixelSize: 26
            }

            // with no sidebar on the home page, search lives in the header
            InputField {
              visible: win.section === "home"
              Layout.preferredWidth: 220
              implicitHeight: 32
              icon: "system-search-symbolic"
              placeholder: "Search"
              clearOnEscape: true
              fontSize: 12
              onTextChanged: win.query = text
            }

            IconButton {
              icon: "window-close-symbolic"
              size: 14
              color: Theme.colors.textMuted
              onClicked: Runtime.settingsOpen = false
            }
          }

          Rule { Layout.leftMargin: 20; Layout.rightMargin: 20; Layout.bottomMargin: 12 }

          ErrorBanner {
            text: Settings.error
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.bottomMargin: 8
          }

          Flickable {
            visible: win.query === "" && win.customPage
            Layout.preferredHeight: win.section === "home" ? contentHeight + bottomMargin : -1
            Layout.fillWidth: true
            Layout.fillHeight: true
            leftMargin: 20
            rightMargin: 20
            bottomMargin: 20
            clip: true
            contentWidth: width - 40
            contentHeight: page.implicitHeight
            boundsBehavior: Flickable.StopAtBounds

            Loader {
              id: page
              width: parent.width
              sourceComponent: ({ home: homePage, sound: soundPage, network: networkPage, bluetooth: bluetoothPage, system: systemPage })[win.section] ?? null
            }

            Component { id: soundPage; SoundPage {} }
            Component { id: networkPage; NetworkPage {} }
            Component { id: bluetoothPage; BluetoothPage {} }

            Component {
              id: homePage
              SettingsHome { sections: win.pages; onOpened: (name) => win.section = name }
            }

            Component {
              id: systemPage

              ColumnLayout {
                spacing: 18

                SystemInfo { Layout.fillWidth: true }

                // the config file behind every other page
                RowLayout {
                  Layout.fillWidth: true
                  spacing: 8

                  Caption {
                    Layout.fillWidth: true
                    text: Settings.path
                    mono: true
                    elide: Text.ElideMiddle
                  }

                  BoxButton {
                    implicitHeight: 28
                    fontSize: 11
                    text: "Open file"
                    onClicked: Qt.openUrlExternally("file://" + Settings.path)
                  }

                  BoxButton {
                    id: resetAll
                    property bool armed: false
                    implicitHeight: 28
                    fontSize: 11
                    text: armed ? "Sure?" : "Reset all"
                    filled: armed
                    fillColor: Theme.colors.error
                    onClicked: {
                      if (armed) { Settings.resetAll(); armed = false; }
                      else armed = true;
                    }
                    Timer { running: resetAll.armed; interval: 3000; onTriggered: resetAll.armed = false }
                  }
                }
              }
            }
          }

          Flickable {
            id: schemaPage
            visible: win.query !== "" || win.inSchema
            Layout.fillWidth: true
            Layout.fillHeight: true
            leftMargin: 20
            rightMargin: 20
            bottomMargin: 20
            clip: true
            contentWidth: width - 40
            contentHeight: schemaColumn.implicitHeight
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            ColumnLayout {
              id: schemaColumn
              width: schemaPage.contentWidth
              spacing: 18

              ThemePreview {
                visible: win.query === "" && win.section === "appearance"
                Layout.fillWidth: true
              }

              Repeater {
                model: win.groups

                ColumnLayout {
                  id: settingsGroup
                  required property var modelData
                  Layout.fillWidth: true
                  spacing: 8

                  SectionLabel {
                    visible: settingsGroup.modelData.title !== ""
                    text: settingsGroup.modelData.title
                    size: 16
                  }

                  RowGroup {
                    Repeater {
                      model: settingsGroup.modelData.rows
                      SettingRow { Layout.fillWidth: true }
                    }
                  }
                }
              }
            }
          }

          StyledText {
            visible: win.groups.length === 0 && (win.query !== "" || win.inSchema)
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 40
            text: "No settings match"
            color: Theme.colors.textMuted
          }
        }
      }
    }

    // a list entry in a setting: its contents in a row, in a small raised box
    component Chip: Rectangle {
      default property alias content: chipRow.data
      width: chipRow.implicitWidth + 8
      height: 28
      radius: Theme.radiusSm
      color: Theme.colors.surfaceRaised
      border.width: 1
      border.color: Theme.colors.borderStrong
      RowLayout { id: chipRow; anchors.centerIn: parent; spacing: 4 }
    }

    component ChipButton: IconButton { size: 10; padding: 3; color: Theme.colors.textMuted }

    component SettingRow: Item {
      id: row
      required property var modelData
      required property int index
      readonly property var entry: modelData.entry
      readonly property string path: modelData.path
      readonly property var value: Settings.values[path]
      readonly property bool isDefault: JSON.stringify(value) === JSON.stringify(entry.default)
      readonly property bool isPath: entry.type === "path" || entry.type === "wallpaper"
      readonly property bool wide: entry.type === "list" || entry.type === "items" || entry.type === "path" || entry.type === "wallpaper" || entry.type === "string"

      implicitHeight: layout.implicitHeight + 24

      HoverHandler { id: rowHover }

      Hairline { visible: row.index > 0; inset: 14 }

      GridLayout {
        id: layout
        anchors { left: parent.left; right: parent.right; verticalCenter: parent.verticalCenter; leftMargin: 14; rightMargin: 10 }
        columns: row.wide ? 1 : 2
        columnSpacing: 16
        rowSpacing: 10

        RowLayout {
          Layout.fillWidth: true
          spacing: 6

          ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            StyledText {
              Layout.fillWidth: true
              text: row.entry.label
              font.pixelSize: 13
              font.weight: Font.Medium
            }

            Caption {
              visible: text !== ""
              Layout.fillWidth: true
              text: row.entry.hint ?? ""
              wrapMode: Text.Wrap
            }
          }

          Clickable {
            visible: !row.isDefault && rowHover.hovered
            implicitWidth: resetText.implicitWidth + 14
            implicitHeight: 22
            radius: Theme.radiusSm
            color: hovered ? Theme.colors.surfaceRaised : "transparent"
            onClicked: Settings.reset(row.path)

            StyledText {
              id: resetText
              anchors.centerIn: parent
              text: "Reset"
              font.pixelSize: 11
              color: parent.hovered ? Theme.colors.accent : Theme.colors.textMuted
            }
          }
        }

        Loader {
          Layout.fillWidth: row.wide
          Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
          sourceComponent: ({
            bool: toggleControl,
            int: numberControl,
            float: numberControl,
            choice: choiceControl,
            color: colorControl,
            list: listControl,
            items: itemsControl,
            wallpaper: wallpaperControl,
          })[row.entry.type] ?? textControl
        }
      }

      Component {
        id: toggleControl

        ToggleSwitch { on: row.value === true; onToggled: Settings.set(row.path, !on) }
      }

      Component {
        id: numberControl

        RowLayout {
          spacing: 10

          ThinSlider {
            implicitWidth: 180
            handleWidth: 12
            handleHeight: 18
            from: row.entry.min
            to: row.entry.max
            stepSize: row.entry.type === "int" ? 1 : (row.entry.step ?? 0.05)
            snapMode: Slider.SnapAlways
            value: row.value
            onMoved: Settings.set(row.path, row.entry.type === "int" ? Math.round(value) : Math.round(value * 100) / 100)
          }

          StyledText {
            Layout.minimumWidth: 40
            horizontalAlignment: Text.AlignRight
            text: row.entry.type === "int" ? row.value : Number(row.value).toFixed(2) + "×"
            mono: true
            font.pixelSize: 12
          }
        }
      }

      Component {
        id: choiceControl

        ChoicePills {
          options: row.entry.options.map(o => ({ value: o, label: o.charAt(0).toUpperCase() + o.slice(1) }))
          value: row.value
          onPicked: (v) => Settings.set(row.path, v)
        }
      }

      Component {
        id: colorControl

        Row {
          spacing: 6

          Repeater {
            model: row.entry.options

            Clickable {
              required property string modelData
              onClicked: Settings.set(row.path, modelData)
              readonly property bool selected: row.value === modelData
              width: 24
              height: 24
              radius: Theme.radiusXs
              color: Theme.colors[modelData]
              border.width: selected ? 2 : 0
              border.color: Theme.colors.text

              Rectangle {
                visible: parent.selected
                anchors { fill: parent; margins: 2 }
                color: "transparent"
                border.width: 2
                border.color: Theme.colors.base
              }

              ToolTip.visible: hovered
              ToolTip.text: modelData
            }
          }
        }
      }

      Component {
        id: textControl

        RowLayout {
          spacing: 8

          InputField {
            Layout.fillWidth: true
            implicitHeight: 32
            fontSize: 12
            mono: row.isPath
            placeholder: row.entry.placeholder ?? ""
            text: row.value
            onEditingFinished: if (text !== row.value) Settings.set(row.path, text)
          }

          Thumbnail {
            visible: row.isPath && !row.entry.folder
            implicitWidth: 32
            implicitHeight: 32
            source: row.isPath && row.value ? "file://" + row.value : ""
            sourceSize: Qt.size(64, 64)
            borderColor: status === Image.Error ? Theme.colors.error : Theme.colors.border
          }
        }
      }

      Component {
        id: wallpaperControl

        ColumnLayout {
          id: wp
          spacing: 10

          readonly property string folder: row.value ? row.value.slice(0, row.value.lastIndexOf("/")) : ""

          Loader { Layout.fillWidth: true; sourceComponent: textControl }

          GridView {
            id: grid
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentHeight, cellHeight * 3)
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            cellWidth: width / Math.max(1, Math.floor(width / 120))
            cellHeight: cellWidth * 9 / 16 + 6
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            model: FolderListModel {
              folder: wp.folder ? "file://" + wp.folder : ""
              nameFilters: ["*.png", "*.jpg", "*.jpeg", "*.webp"]
              showDirs: false
              sortField: FolderListModel.Name
            }

            delegate: Item {
              id: tile
              required property string filePath
              required property string fileUrl
              readonly property bool selected: filePath === row.value
              width: grid.cellWidth
              height: grid.cellHeight

              Clickable {
                id: tileButton
                anchors { fill: parent; margins: 3 }
                onClicked: Settings.set(row.path, tile.filePath)
                radius: Theme.radiusSm

                Thumbnail {
                  anchors.fill: parent
                  radius: tileButton.radius
                  source: tile.fileUrl
                  sourceSize: Qt.size(240, 135)
                  borderWidth: tile.selected ? 2 : 1
                  borderColor: tile.selected ? Theme.colors.accent
                             : tileButton.hovered ? Theme.colors.borderStrong
                             : Theme.colors.border
                }
              }
            }
          }
        }
      }

      // an ordered pick from a fixed set: chips that move left and right, and
      // a menu of what's left. Entries sharing a pool share their items, so a
      // bar item sits in one section at a time
      Component {
        id: itemsControl

        Flow {
          id: items
          spacing: 6

          readonly property var taken: {
            const sec = Settings.schema.find(s => s.name === row.path.split(".")[0]);
            const pool = row.entry.pool;
            const siblings = pool ? sec.entries.filter(x => x.pool === pool).map(x => `${sec.name}.${x.key}`) : [row.path];
            return siblings.reduce((all, p) => all.concat(p === row.path ? row.value : Settings.get(p)), []);
          }

          function move(from: int, to: int): void {
            const next = row.value.slice();
            next.splice(to, 0, next.splice(from, 1)[0]);
            Settings.set(row.path, next);
          }

          Repeater {
            model: row.value

            Chip {
              id: chip
              required property string modelData
              required property int index

              ChipButton { icon: "go-previous-symbolic"; enabled: chip.index > 0; onClicked: items.move(chip.index, chip.index - 1) }
              StyledText { text: Settings.itemNames[chip.modelData] ?? chip.modelData; font.pixelSize: 12 }
              ChipButton {
                icon: "go-next-symbolic"
                enabled: chip.index < row.value.length - 1
                onClicked: items.move(chip.index, chip.index + 1)
              }
              ChipButton {
                icon: "window-close-symbolic"
                onClicked: Settings.set(row.path, row.value.filter(v => v !== chip.modelData))
              }
            }
          }

          Dropdown {
            readonly property var remaining: row.entry.options.filter(o => !items.taken.includes(o))
            visible: remaining.length > 0
            implicitWidth: 120
            implicitHeight: 28
            options: remaining.map(o => ({ value: o, label: Settings.itemNames[o] ?? o }))
            displayText: "Add"
            onPicked: (v) => Settings.set(row.path, [...row.value, v])
          }

          StyledText {
            visible: row.value.length === 0
            height: 28
            verticalAlignment: Text.AlignVCenter
            text: "Empty"
            font.pixelSize: 12
            color: Theme.colors.textSubtle
          }
        }
      }

      Component {
        id: listControl

        Flow {
          spacing: 6

          Repeater {
            model: row.value

            Chip {
              id: listChip
              required property string modelData
              required property int index

              StyledText { text: listChip.modelData; font.pixelSize: 12; Layout.leftMargin: 4 }
              ChipButton {
                icon: "window-close-symbolic"
                onClicked: Settings.set(row.path, row.value.filter((_, i) => i !== listChip.index))
              }
            }
          }

          InputField {
            width: 140
            height: 28
            fontSize: 12
            placeholder: "+ add"
            onAccepted: {
              const v = text.trim();
              if (v !== "" && !row.value.includes(v)) Settings.set(row.path, [...row.value, v]);
              text = "";
            }
          }
        }
      }
    }
  }
}
