import QtQuick
import QtQuick.Layouts
import Quickshell
import Izshell
import qs.data
import qs.components

// The keybinds the Hyprland config describes, read from Hyprland each time it
// opens. A description reads "Group: Label"; binds sharing one (focus a
// workspace on each number key) collapse into a single row. Undescribed binds
// and those inside submaps are left out.
LazyLoader {
  active: Surfaces.cheatsheetOpen

  Modal {
    id: win
    namespace: "cheatsheet"
    surface: "cheatsheet"
    Component.onCompleted: Hyprctl.request("j/binds", reply => groups = parse(reply))

    // [{ title, rows: [{ label, keys: [string] }] }]
    property var groups: []

    readonly property var modNames: [[64, "Super"], [4, "Ctrl"], [8, "Alt"], [1, "Shift"]]
    readonly property var keyNames: ({
      "mouse:272": "Drag", "mouse:273": "Right drag", mouse_down: "Scroll ↓", mouse_up: "Scroll ↑",
      grave: "`", slash: "/", Return: "Enter", Escape: "Esc", Space: "Space",
    })

    function keyName(key: string): string {
      return keyNames[key] ?? (key.length === 1 ? key.toUpperCase() : key);
    }

    function parse(text: string): var {
      let binds;
      try { binds = JSON.parse(text); } catch (e) { return []; }
      const rows = new Map();
      for (const b of binds) {
        if (!b.has_description || b.submap !== "") continue;
        const id = b.description + "|" + b.modmask;
        const key = keyName(b.key);
        const row = rows.get(id);
        if (row) { row.more.push(key); continue; }
        const split = b.description.indexOf(": ");
        rows.set(id, {
          group: split < 0 ? "" : b.description.slice(0, split),
          label: split < 0 ? b.description : b.description.slice(split + 2),
          mods: modNames.filter(([m]) => b.modmask & m).map(([, n]) => n),
          key, more: [],
        });
      }
      const groups = [];
      for (const r of rows.values()) {
        // one other key reads "A / B"; a run like 1 … 0 reads first to last
        const key = r.more.length === 0 ? r.key
          : r.more.length === 1 ? `${r.key} / ${r.more[0]}`
          : `${r.key}–${r.more[r.more.length - 1]}`;
        let g = groups.find(g => g.title === r.group);
        if (!g) groups.push(g = { title: r.group, rows: [] });
        g.rows.push({ label: r.label, keys: [...r.mods, key] });
      }
      return groups;
    }

    Item {
      implicitWidth: layout.implicitWidth + 56
      implicitHeight: layout.implicitHeight + 48

      CardSurface { raised: true; radius: Theme.sheetRadius }

      ColumnLayout {
        id: layout
        anchors.centerIn: parent
        spacing: 20

        SectionLabel { text: "Keybinds"; size: 24 }

        GridLayout {
          visible: win.groups.length > 0
          columns: Math.min(3, win.groups.length)
          columnSpacing: 40
          rowSpacing: 24

          Repeater {
            model: win.groups

            ColumnLayout {
              id: group
              required property var modelData
              Layout.alignment: Qt.AlignTop
              spacing: 6

              Caption { visible: text !== ""; text: group.modelData.title; font.weight: Font.DemiBold }

              Repeater {
                model: group.modelData.rows

                RowLayout {
                  id: bind
                  required property var modelData
                  spacing: 24

                  StyledText { Layout.fillWidth: true; text: bind.modelData.label; font.pixelSize: 13 }

                  Row {
                    spacing: 4
                    Repeater {
                      model: bind.modelData.keys
                      Rectangle {
                        required property string modelData
                        width: Math.max(height, cap.implicitWidth + 12)
                        height: 22
                        radius: Theme.radiusXs
                        color: Theme.colors.surfaceRaised
                        border.width: 1
                        border.color: Theme.colors.borderStrong
                        StyledText { id: cap; anchors.centerIn: parent; text: parent.modelData; mono: true; font.pixelSize: 11 }
                      }
                    }
                  }
                }
              }
            }
          }
        }

        Caption {
          visible: win.groups.length === 0
          text: 'No binds have descriptions yet: give hl.bind a { description = "Group: Label" }.'
        }
      }
    }
  }
}
