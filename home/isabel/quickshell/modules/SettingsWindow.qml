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

    property string section: Config.schema[0].name
    property string query: ""

    readonly property var rows: {
      const q = query.trim().toLowerCase();
      const out = [];
      for (const sec of Config.schema) {
        if (q === "" && sec.name !== section) continue;
        for (const e of sec.entries) {
          const hay = `${sec.title} ${e.label} ${e.key} ${e.hint ?? ""}`.toLowerCase();
          if (q === "" || hay.includes(q))
            out.push({ path: `${sec.name}.${e.key}`, entry: e, sectionTitle: sec.title });
        }
      }
      return out;
    }

    Rectangle {
      id: card
      implicitWidth: Math.min(820, win.width - 80)
      implicitHeight: Math.min(580, win.height - 80)
      color: Settings.colors.base
      radius: Settings.rounding
      border.color: Settings.colors.borderStrong
      border.width: 1

      RowLayout {
        anchors { fill: parent; margins: 1 }
        spacing: 0

        Rectangle {
          Layout.fillHeight: true
          implicitWidth: 210
          color: Settings.colors.surface

          Rectangle {
            anchors { top: parent.top; bottom: parent.bottom; right: parent.right }
            width: 1
            color: Settings.colors.border
          }

          ColumnLayout {
            anchors { fill: parent; margins: 12 }
            spacing: 2

            SectionLabel {
              Layout.bottomMargin: 12
              Layout.leftMargin: 4
              text: "Settings"
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
              model: Config.schema

              PanelListItem {
                required property var modelData
                Layout.fillWidth: true
                icon: modelData.icon
                text: modelData.title
                active: win.query === "" && win.section === modelData.name
                onClicked: {
                  search.text = "";
                  win.section = modelData.name;
                }
              }
            }

            Item { Layout.fillHeight: true }

            StyledText {
              Layout.fillWidth: true
              Layout.leftMargin: 4
              text: "settings.toml"
              mono: true
              font.pixelSize: 10
              color: Settings.colors.textSubtle
              elide: Text.ElideMiddle
            }

            RowLayout {
              Layout.fillWidth: true
              spacing: 6

              BoxButton {
                Layout.fillWidth: true
                implicitHeight: 28
                fontSize: 11
                text: "Open file"
                onClicked: Quickshell.execDetached(["xdg-open", Config.path])
              }

              BoxButton {
                id: resetAll
                property bool armed: false
                Layout.fillWidth: true
                implicitHeight: 28
                fontSize: 11
                text: armed ? "Sure?" : "Reset all"
                filled: armed
                fillColor: Settings.colors.error
                onClicked: {
                  if (armed) { Config.resetAll(); armed = false; }
                  else armed = true;
                }
                Timer { running: resetAll.armed; interval: 3000; onTriggered: resetAll.armed = false }
              }
            }
          }
        }

        ColumnLayout {
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
                : (Config.schema.find(s => s.name === win.section)?.title ?? "")
              font.pixelSize: 18
              font.weight: Font.DemiBold
            }

            IconButton {
              icon: "window-close-symbolic"
              size: 14
              color: Settings.colors.textMuted
              onClicked: Runtime.settingsOpen = false
            }
          }

          Rectangle {
            visible: Config.error !== ""
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.bottomMargin: 8
            implicitHeight: errText.implicitHeight + 16
            radius: Settings.radiusSm
            color: Utils.withAlpha(Settings.colors.error, 0.12)
            border.color: Settings.colors.error
            border.width: 1

            StyledText {
              id: errText
              anchors { fill: parent; margins: 8 }
              text: Config.error
              color: Settings.colors.error
              font.pixelSize: 11
              wrapMode: Text.Wrap
            }
          }

          ThemePreview {
            visible: win.query === "" && win.section === "appearance"
            Layout.fillWidth: true
            Layout.leftMargin: 20
            Layout.rightMargin: 20
            Layout.bottomMargin: 8
          }

          ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            leftMargin: 20
            rightMargin: 20
            bottomMargin: 20
            clip: true
            spacing: 6
            boundsBehavior: Flickable.StopAtBounds
            model: win.rows
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: SettingRow {
              width: ListView.view.width - 40
              searching: win.query !== ""
            }
          }

          StyledText {
            visible: win.rows.length === 0
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 40
            text: "No settings match"
            color: Settings.colors.textSubtle
          }
        }
      }
    }

    component SettingRow: Rectangle {
      id: row
      required property var modelData
      readonly property var entry: modelData.entry
      readonly property string path: modelData.path
      readonly property var value: Config.values[path]
      readonly property bool isDefault: JSON.stringify(value) === JSON.stringify(entry.default)
      property bool searching: false
      readonly property bool isPath: entry.type === "path" || entry.type === "wallpaper"
      readonly property bool wide: entry.type === "list" || entry.type === "path" || entry.type === "wallpaper" || entry.type === "string"

      implicitHeight: layout.implicitHeight + 24
      radius: Settings.radiusMd
      color: Settings.colors.surface
      border.width: 1
      border.color: Settings.colors.border

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

            StyledText {
              visible: text !== ""
              Layout.fillWidth: true
              text: row.searching ? `${row.modelData.sectionTitle}${row.entry.hint ? " · " + row.entry.hint : ""}` : (row.entry.hint ?? "")
              font.pixelSize: 11
              color: Settings.colors.textMuted
              wrapMode: Text.Wrap
            }
          }

          IconButton {
            visible: !row.isDefault
            icon: "edit-undo-symbolic"
            size: 12
            color: Settings.colors.textSubtle
            onClicked: Config.reset(row.path)
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
            wallpaper: wallpaperControl,
          })[row.entry.type] ?? textControl
        }
      }

      Component {
        id: toggleControl

        Clickable {
          readonly property bool on: row.value === true
          onClicked: Config.set(row.path, !on)
          implicitWidth: 40
          implicitHeight: 22
          radius: Settings.radiusSm
          color: on ? Settings.colors.accent : Settings.colors.surfaceRaised
          border.width: 1
          border.color: on ? Settings.colors.accent : Settings.colors.borderStrong
          Behavior on color { ColorAnimation { duration: Settings.animFast } }

          Rectangle {
            width: 14; height: 14
            radius: Settings.radiusXs
            anchors.verticalCenter: parent.verticalCenter
            x: parent.on ? parent.width - width - 4 : 4
            color: parent.on ? Settings.colors.textOnAccent : Settings.colors.textMuted
            Behavior on x { NumberAnimation { duration: Settings.animFast; easing.type: Easing.OutCubic } }
          }
        }
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
            onMoved: Config.set(row.path, row.entry.type === "int" ? Math.round(value) : Math.round(value * 100) / 100)
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

        Row {
          spacing: -1

          Repeater {
            model: row.entry.options

            Clickable {
              required property string modelData
              onClicked: Config.set(row.path, modelData)
              readonly property bool selected: row.value === modelData
              width: Math.max(64, optText.implicitWidth + 24)
              height: 28
              z: selected ? 1 : 0
              color: selected ? Settings.colors.accent : hovered ? Settings.colors.surfaceRaised : Settings.colors.base
              border.width: 1
              border.color: selected ? Settings.colors.accent : Settings.colors.borderStrong

              StyledText {
                id: optText
                anchors.centerIn: parent
                text: parent.modelData
                font.pixelSize: 12
                font.weight: parent.selected ? Font.DemiBold : Font.Normal
                color: parent.selected ? Settings.colors.textOnAccent : Settings.colors.textMuted
              }
            }
          }
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
              onClicked: Config.set(row.path, modelData)
              readonly property bool selected: row.value === modelData
              width: 24
              height: 24
              radius: Settings.radiusXs
              color: Settings.colors[modelData]
              border.width: selected ? 2 : 0
              border.color: Settings.colors.text

              Rectangle {
                visible: parent.selected
                anchors { fill: parent; margins: 2 }
                color: "transparent"
                border.width: 2
                border.color: Settings.colors.base
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
            text: row.value
            onEditingFinished: if (text !== row.value) Config.set(row.path, text)
          }

          Rectangle {
            visible: row.isPath
            implicitWidth: 32
            implicitHeight: 32
            radius: Settings.radiusSm
            color: Settings.colors.overlay
            border.width: 1
            border.color: preview.status === Image.Error ? Settings.colors.error : Settings.colors.border
            clip: true

            Image {
              id: preview
              anchors { fill: parent; margins: 1 }
              source: row.isPath && row.value ? "file://" + row.value : ""
              fillMode: Image.PreserveAspectCrop
              sourceSize: Qt.size(64, 64)
              asynchronous: true
            }
          }
        }
      }

      Component {
        id: wallpaperControl

        ColumnLayout {
          id: wp
          spacing: 10

          readonly property string folder: row.value ? row.value.slice(0, row.value.lastIndexOf("/")) : ""

          Loader {
            Layout.fillWidth: true
            sourceComponent: textControl
          }

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
              required property string filePath
              required property string fileUrl
              readonly property bool selected: filePath === row.value
              width: grid.cellWidth
              height: grid.cellHeight

              Clickable {
                anchors { fill: parent; margins: 3 }
                onClicked: Config.set(row.path, parent.filePath)
                radius: Settings.radiusSm
                color: Settings.colors.overlay
                border.width: parent.selected ? 2 : 1
                border.color: parent.selected ? Settings.colors.accent
                            : hovered ? Settings.colors.borderStrong
                            : Settings.colors.border
                clip: true

                Image {
                  anchors { fill: parent; margins: parent.border.width }
                  source: parent.parent.fileUrl
                  sourceSize: Qt.size(240, 135)
                  fillMode: Image.PreserveAspectCrop
                  asynchronous: true
                  cache: true
                }
              }
            }
          }
        }
      }

      Component {
        id: listControl

        Flow {
          spacing: 6

          Repeater {
            model: row.value

            Rectangle {
              required property string modelData
              required property int index
              width: chipRow.implicitWidth + 16
              height: 28
              radius: Settings.radiusSm
              color: Settings.colors.surfaceRaised
              border.width: 1
              border.color: Settings.colors.borderStrong

              RowLayout {
                id: chipRow
                anchors.centerIn: parent
                spacing: 6
                StyledText { text: parent.parent.modelData; font.pixelSize: 12 }
                IconButton {
                  icon: "window-close-symbolic"
                  size: 10
                  padding: 3
                  color: Settings.colors.textMuted
                  onClicked: {
                    const next = row.value.slice();
                    next.splice(parent.parent.index, 1);
                    Config.set(row.path, next);
                  }
                }
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
              if (v !== "" && !row.value.includes(v)) Config.set(row.path, [...row.value, v]);
              text = "";
            }
          }
        }
      }
    }
  }
}
