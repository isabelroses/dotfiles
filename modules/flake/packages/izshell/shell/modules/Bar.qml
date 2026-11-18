import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import Qt.labs.qmlmodels
import qs.data
import qs.components
import qs.services

// Floating: the bar is cards hovering off the screen edge, in the three
// sections bar.start, bar.middle and bar.end lay out. The window is
// a little wider than the space it reserves so the card shadows aren't
// clipped, and input only lands on the cards themselves.
// Attached: the same groups sit on one strip flush with the edge.
Scope {
  id: root

  Variants {
    model: Quickshell.screens

    PanelWindow {
      id: win
      required property ShellScreen modelData
      screen: modelData

      // spare room past the reserved strip for shadows to fall into
      readonly property int shadowRoom: Settings.barFloating ? 16 : 0
      // card offset from the screen edge, across the bar
      readonly property int outer: Settings.barFloating
        ? Settings.barWidth - Settings.cardThickness - Settings.cardGap
        : (Settings.barWidth - Settings.cardThickness) / 2
      // inset of the first and last card from the ends of the bar
      readonly property int ends: Settings.barFloating ? outer : 4

      // slides off the edge while this monitor shows a fullscreen window. The
      // window covers the top layer at once, so the bar rises to the overlay
      // just for the slide, then drops back; it keeps its reserved strip so
      // windows don't reflow when it returns
      readonly property bool fullscreen: Hyprland.monitorFor(modelData)?.activeWorkspace?.hasFullscreen ?? false
      property real hidden: fullscreen ? 1 : 0
      Behavior on hidden { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Settings.curve } }
      WlrLayershell.layer: fullscreen && hidden < 1 ? WlrLayer.Overlay : WlrLayer.Top

      implicitWidth: Settings.barWidth + shadowRoom
      implicitHeight: Settings.barWidth + shadowRoom
      color: "transparent"
      exclusionMode: ExclusionMode.Normal
      exclusiveZone: Settings.barWidth
      WlrLayershell.namespace: "bar"
      mask: Settings.barFloating ? cardsMask : laneMask

      property Region laneMask: Region { item: lane }
      property Region cardsMask: Region {
        item: head
        Region { item: middle }
        Region { item: tail }
      }

      anchors {
        top: Settings.barSide !== "bottom"
        bottom: Settings.barSide !== "top"
        left: Settings.barSide !== "right"
        right: Settings.barSide !== "left"
      }

      Item {
        id: lane
        opacity: 1 - win.hidden
        transform: Translate {
          readonly property real d: (Settings.barWidth + win.shadowRoom) * win.hidden
          x: !Settings.barVertical ? 0 : Settings.barOnRight ? d : -d
          y: Settings.barVertical ? 0 : Settings.barOnBottom ? d : -d
        }
        x: Settings.barOnRight ? parent.width - width : 0
        y: Settings.barOnBottom ? parent.height - height : 0
        width: Settings.barVertical ? Settings.barWidth : parent.width
        height: Settings.barVertical ? parent.height : Settings.barWidth

        // distance of a card's near side from the lane's near edge
        readonly property real across: (Settings.barOnRight || Settings.barOnBottom)
          ? Settings.barWidth - win.outer - Settings.cardThickness
          : win.outer

        CardSurface {
          visible: !Settings.barFloating
          attached: true
          vertical: Settings.barVertical
        }

        // bar.start / middle / end; an item listed twice only shows the first time
        readonly property list<string> startItems: Config.get("bar.start")
        readonly property list<string> middleItems: Config.get("bar.middle").filter(i => !startItems.includes(i))
        readonly property list<string> endItems: Config.get("bar.end").filter(i => !startItems.includes(i) && !middleItems.includes(i))

        BarSection {
          id: head
          items: lane.startItems
          x: Settings.barVertical ? lane.across : win.ends
          y: Settings.barVertical ? win.ends : lane.across
        }

        BarSection {
          id: middle
          items: lane.middleItems
          x: Settings.barVertical ? lane.across : (lane.width - width) / 2
          y: Settings.barVertical ? (lane.height - height) / 2 : lane.across
        }

        BarSection {
          id: tail
          items: lane.endItems
          x: Settings.barVertical ? lane.across : lane.width - width - win.ends
          y: Settings.barVertical ? lane.height - height - win.ends : lane.across
        }
      }
    }
  }

  // one end (or the middle) of the bar: runs of items share a card, and media
  // gets a card of its own that only shows while something is happening
  // (music, mic in use, screen share)
  component BarSection: Grid {
    id: section

    property list<string> items: []
    readonly property var cards: {
      const out = [];
      for (const id of items) {
        const last = out[out.length - 1];
        if (id !== "media" && last && last[0] !== "media") last.push(id);
        else out.push([id]);
      }
      return out;
    }

    columns: Settings.barVertical ? 1 : Math.max(1, cards.length)
    spacing: 6

    Repeater {
      model: section.cards

      BarCard {
        id: card
        required property var modelData
        readonly property bool isMedia: modelData[0] === "media"
        // from the data, not the children: a hidden card hides its children too
        readonly property bool active: !isMedia || Media.selectedPlayer !== null
          || Pipewire.micUsers.length > 0 || Pipewire.screenShares.length > 0

        spacing: isMedia ? 6 : 10
        opacity: active ? 1 : 0
        scale: active ? 1 : 0.85
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: Settings.animFast } }
        Behavior on scale { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.BezierSpline; easing.bezierCurve: Settings.curve } }

        Repeater {
          model: card.modelData

          DelegateChooser {
            role: "modelData"

            DelegateChoice { roleValue: "launcher"; Launcher {} }
            DelegateChoice { roleValue: "workspaces"; Workspaces {} }
            DelegateChoice { roleValue: "clock"; Clock {} }
            DelegateChoice { roleValue: "tray"; SysTray {} }
            DelegateChoice { roleValue: "media"; BarGroup { spacing: 6; RecordingDot {} NowPlaying {} } }
            DelegateChoice { roleValue: "status"; StatusCapsule {} }
          }
        }
      }
    }
  }

  // opens quick settings; scrolling it changes the volume
  component StatusCapsule: Clickable {
    id: capsule
    onClicked: Runtime.toggleQuickSettings()
    onScrolled: (e) => Pipewire.setSinkVolume(Pipewire.sinkVolume + (e.angleDelta.y > 0 ? 0.05 : -0.05))
    Layout.alignment: Qt.AlignCenter
    implicitWidth: Settings.barVertical ? 34 : statusGroup.implicitWidth + 22
    implicitHeight: Settings.barVertical ? statusGroup.implicitHeight + 22 : 34
    radius: Settings.innerRadius
    color: Runtime.quickSettingsOpen ? Settings.colors.accentSoft
         : capsule.hovered ? Utils.withAlpha(Settings.colors.text, 0.08)
         : "transparent"

    Behavior on color { ColorAnimation { duration: Settings.animFast } }

    BarGroup {
      id: statusGroup
      anchors.centerIn: parent
      spacing: 12

      Repeater {
        model: Config.get("bar.status")

        DelegateChooser {
          role: "modelData"

          DelegateChoice { roleValue: "notifications"; Noti {} }
          DelegateChoice { roleValue: "volume"; Volume {} }
          DelegateChoice { roleValue: "network"; Network {} }
          DelegateChoice { roleValue: "battery"; Battery {} }
        }
      }
    }
  }
}
