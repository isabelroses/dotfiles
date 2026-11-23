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
      readonly property int shadowRoom: BarPlacement.floating ? 16 : 0
      // card offset from the screen edge, across the bar
      readonly property int outer: BarPlacement.floating
        ? BarPlacement.reserved - Theme.cardThickness - Theme.cardGap
        : (BarPlacement.reserved - Theme.cardThickness) / 2
      // inset of the first and last card from the ends of the bar
      readonly property int ends: BarPlacement.floating ? outer : 4

      // slides off the edge while this monitor shows a fullscreen window. The
      // window covers the top layer at once, so the bar rises to the overlay
      // just for the slide, then drops back; it keeps its reserved strip so
      // windows don't reflow when it returns
      readonly property bool fullscreen: Hyprland.monitorFor(modelData)?.activeWorkspace?.hasFullscreen ?? false
      property real hidden: fullscreen ? 1 : 0
      Behavior on hidden { Anim {} }
      WlrLayershell.layer: fullscreen && hidden < 1 ? WlrLayer.Overlay : WlrLayer.Top

      implicitWidth: BarPlacement.reserved + shadowRoom
      implicitHeight: BarPlacement.reserved + shadowRoom
      color: "transparent"
      exclusionMode: ExclusionMode.Normal
      exclusiveZone: BarPlacement.reserved
      WlrLayershell.namespace: "bar"
      mask: BarPlacement.floating ? cardsMask : laneMask

      property Region laneMask: Region { item: lane }
      property Region cardsMask: Region {
        item: head
        Region { item: middle }
        Region { item: tail }
      }

      anchors {
        top: BarPlacement.side !== "bottom"
        bottom: BarPlacement.side !== "top"
        left: BarPlacement.side !== "right"
        right: BarPlacement.side !== "left"
      }

      Item {
        id: lane
        opacity: 1 - win.hidden
        transform: Translate {
          readonly property real d: (BarPlacement.reserved + win.shadowRoom) * win.hidden
          x: !BarPlacement.vertical ? 0 : BarPlacement.onRight ? d : -d
          y: BarPlacement.vertical ? 0 : BarPlacement.onBottom ? d : -d
        }
        x: BarPlacement.onRight ? parent.width - width : 0
        y: BarPlacement.onBottom ? parent.height - height : 0
        width: BarPlacement.vertical ? BarPlacement.reserved : parent.width
        height: BarPlacement.vertical ? parent.height : BarPlacement.reserved

        // distance of a card's near side from the lane's near edge
        readonly property real across: (BarPlacement.onRight || BarPlacement.onBottom)
          ? BarPlacement.reserved - win.outer - Theme.cardThickness
          : win.outer

        CardSurface {
          visible: !BarPlacement.floating
          attached: true
          vertical: BarPlacement.vertical
        }

        // bar.start / middle / end; an item listed twice only shows the first time
        readonly property list<string> startItems: Settings.bar.start
        readonly property list<string> middleItems: Settings.bar.middle.filter(i => !startItems.includes(i))
        readonly property list<string> endItems: Settings.bar.end.filter(i => !startItems.includes(i) && !middleItems.includes(i))

        BarSection {
          id: head
          items: lane.startItems
          x: BarPlacement.vertical ? lane.across : win.ends
          y: BarPlacement.vertical ? win.ends : lane.across
        }

        BarSection {
          id: middle
          items: lane.middleItems
          x: BarPlacement.vertical ? lane.across : (lane.width - width) / 2
          y: BarPlacement.vertical ? (lane.height - height) / 2 : lane.across
        }

        BarSection {
          id: tail
          items: lane.endItems
          x: BarPlacement.vertical ? lane.across : lane.width - width - win.ends
          y: BarPlacement.vertical ? lane.height - height - win.ends : lane.across
        }
      }
    }
  }

  // one end (or the middle) of the bar: runs of items share a card, while media
  // and mic get cards of their own that only show while something is happening
  // (a player, mic in use or screen share)
  component BarSection: Grid {
    id: section

    property list<string> items: []
    readonly property var cards: Settings.barCards(items)

    columns: BarPlacement.vertical ? 1 : Math.max(1, cards.length)
    spacing: 6

    Repeater {
      model: section.cards

      BarCard {
        id: card
        required property var modelData
        readonly property bool isMedia: modelData[0] === "media"
        readonly property bool isMic: modelData[0] === "mic"
        // from the data, not the children: a hidden card hides its children too
        readonly property bool active: isMedia ? Media.selectedPlayer !== null
          : isMic ? Pipewire.micUsers.length > 0 || Pipewire.screenShares.length > 0
          : true

        spacing: isMedia || isMic ? 6 : 10
        opacity: active ? 1 : 0
        scale: active ? 1 : 0.85
        visible: opacity > 0
        Behavior on opacity { Anim { duration: Theme.animFast } }
        Behavior on scale { Anim {} }

        Repeater {
          model: card.modelData

          DelegateChooser {
            role: "modelData"

            DelegateChoice { roleValue: "launcher"; Launcher {} }
            DelegateChoice { roleValue: "workspaces"; Workspaces {} }
            DelegateChoice { roleValue: "clock"; Clock {} }
            DelegateChoice { roleValue: "tray"; SysTray {} }
            DelegateChoice { roleValue: "media"; BarGroup { spacing: 6; NowPlaying {} } }
            DelegateChoice { roleValue: "mic"; BarGroup { spacing: 6; RecordingDot {} } }
            DelegateChoice { roleValue: "status"; StatusCapsule {} }
          }
        }
      }
    }
  }

  // opens quick settings; scrolling it changes the volume
  component StatusCapsule: Clickable {
    id: capsule
    onClicked: Surfaces.toggle("quickSettings")
    onScrolled: (e) => Pipewire.setSinkVolume(Pipewire.sinkVolume + (e.angleDelta.y > 0 ? 0.05 : -0.05))
    Layout.alignment: Qt.AlignCenter
    implicitWidth: BarPlacement.vertical ? 34 : statusGroup.implicitWidth + 22
    implicitHeight: BarPlacement.vertical ? statusGroup.implicitHeight + 22 : 34
    radius: Theme.innerRadius
    color: Surfaces.quickSettingsOpen ? Theme.colors.accentSoft
         : capsule.hovered ? Utils.withAlpha(Theme.colors.text, 0.08)
         : "transparent"


    BarGroup {
      id: statusGroup
      anchors.centerIn: parent
      spacing: 12

      Repeater {
        model: Settings.bar.status

        DelegateChooser {
          role: "modelData"

          DelegateChoice { roleValue: "notifications"; Noti {} }
          DelegateChoice { roleValue: "volume"; Volume {} }
          DelegateChoice { roleValue: "mic"; RecordingDot { compact: true } }
          DelegateChoice { roleValue: "network"; Network {} }
          DelegateChoice { roleValue: "battery"; Battery {} }
        }
      }
    }
  }
}
