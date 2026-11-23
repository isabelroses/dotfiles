import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import qs.data
import qs.components

// Month calendar that opens from the clock, level with it beside the bar.
// Today gets an accent ring and the current week a soft band.
// Arrows, the scroll wheel or the left/right keys browse months; clicking the
// title jumps back to today. Clicking anywhere else or Escape closes it.
LazyLoader {
  active: Surfaces.calendarOpen

  PanelWindow {
    id: win

    // transparent margin around the card for its shadow to fall into
    readonly property int pad: 24
    readonly property int gap: BarPlacement.floating ? Theme.cardGap : 0

    color: "transparent"
    implicitWidth: card.width + pad * 2
    implicitHeight: card.height + pad * 2
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "calendar"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    mask: Region { item: card }

    // anchored only to the bar's edge, so the compositor centres it along the
    // bar, level with the clock
    anchors {
      left: BarPlacement.side === "left"
      right: BarPlacement.side === "right"
      top: BarPlacement.side === "top"
      bottom: BarPlacement.side === "bottom"
    }
    readonly property var beside: BarPlacement.windowMargins(gap - pad)
    margins {
      left: beside.left
      right: beside.right
      top: beside.top
      bottom: beside.bottom
    }

    HyprlandFocusGrab {
      active: true
      windows: [win]
      onCleared: {
        Surfaces.dismissedByFocusLoss("calendar");
      }
    }

    FocusScope {
      id: card

      readonly property date today: Time.date
      property bool followToday: true
      property date browsed: monthStart(today)
      readonly property date month: followToday ? monthStart(today) : browsed
      readonly property bool isThisMonth: sameMonth(month, today)
      readonly property var days: monthDays(month)
      readonly property int weekRow: isThisMonth ? Math.floor(days.findIndex(d => sameDay(d, today)) / 7) : -1

      readonly property int cell: 34
      readonly property int padding: 14

      x: win.pad
      y: win.pad
      width: cell * 7 + padding * 2
      height: column.implicitHeight + padding * 2
      focus: true

      Keys.onEscapePressed: Surfaces.close("calendar")
      Keys.onLeftPressed: shift(-1)
      Keys.onRightPressed: shift(1)

      // dates are pinned to midday so a DST shift can never push one into the
      // neighbouring day
      function monthStart(d: date): date { return new Date(d.getFullYear(), d.getMonth(), 1, 12); }
      function sameMonth(a: date, b: date): bool { return a.getMonth() === b.getMonth() && a.getFullYear() === b.getFullYear(); }
      function sameDay(a: date, b: date): bool { return a.getDate() === b.getDate() && sameMonth(a, b); }
      // six full weeks, monday first, starting on or before the 1st
      function monthDays(m: date): var {
        const y = m.getFullYear(), mo = m.getMonth();
        const first = new Date(y, mo, 1, 12);
        const back = first.getDay() === 0 ? 6 : first.getDay() - 1;
        return Array.from({ length: 42 }, (_, i) => new Date(y, mo, 1 - back + i, 12));
      }
      function shift(delta: int): void {
        browsed = new Date(month.getFullYear(), month.getMonth() + delta, 1, 12);
        followToday = sameMonth(browsed, today);
      }

      opacity: 0
      scale: 0.96
      transformOrigin: BarPlacement.vertical ? (BarPlacement.onRight ? Item.Right : Item.Left)
                                            : (BarPlacement.onBottom ? Item.Bottom : Item.Top)
      Component.onCompleted: { opacity = 1; scale = 1; }
      Behavior on opacity { Anim { duration: Theme.animFast } }
      Behavior on scale { Anim {} }

      CardSurface {
        attached: !BarPlacement.floating
        radius: attached ? 0 : Theme.sheetRadius
        raised: true
      }

      // attached cards still need a full outline, since they float mid-edge
      Rectangle {
        visible: !BarPlacement.floating
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: Theme.colors.border
      }

      WheelHandler {
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: (e) => card.shift(e.angleDelta.y > 0 ? -1 : 1)
      }

      ColumnLayout {
        id: column
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: card.padding }
        spacing: 6

        RowLayout {
          Layout.fillWidth: true
          Layout.leftMargin: 4
          Layout.bottomMargin: 4
          spacing: 6

          Item {
            implicitWidth: title.implicitWidth
            implicitHeight: title.implicitHeight

            RowLayout {
              id: title
              spacing: 6

              StyledText {
                text: Qt.locale().standaloneMonthName(card.month.getMonth(), Locale.LongFormat)
                serif: true
                font.italic: true
                font.pixelSize: 24
              }

              StyledText {
                Layout.alignment: Qt.AlignBaseline
                text: card.month.getFullYear()
                font.pixelSize: 13
                color: Theme.colors.textMuted
              }
            }

            HoverHandler { cursorShape: card.followToday ? Qt.ArrowCursor : Qt.PointingHandCursor }
            TapHandler { onTapped: card.followToday = true }
          }

          Item { Layout.fillWidth: true }

          IconButton {
            icon: "go-previous-symbolic"
            size: 12
            padding: 7
            color: Theme.colors.textMuted
            onClicked: card.shift(-1)
          }

          IconButton {
            icon: "go-next-symbolic"
            size: 12
            padding: 7
            color: Theme.colors.textMuted
            onClicked: card.shift(1)
          }
        }

        Row {
          Repeater {
            model: 7
            Caption {
              required property int index
              width: card.cell
              horizontalAlignment: Text.AlignHCenter
              text: Qt.locale().dayName((index + 1) % 7, Locale.ShortFormat).slice(0, 2)
              font.weight: Font.Medium
            }
          }
        }

        Item {
          implicitWidth: card.cell * 7
          implicitHeight: card.cell * 6

          Rectangle {
            visible: card.weekRow >= 0
            y: card.weekRow * card.cell
            width: parent.width
            height: card.cell
            radius: Theme.pill(card.cell)
            color: Utils.withAlpha(Theme.colors.text, 0.06)
          }

          Grid {
            columns: 7

            Repeater {
              model: card.days

              Item {
                id: day
                required property var modelData
                required property int index
                readonly property bool isToday: card.sameDay(modelData, card.today)
                readonly property bool inMonth: modelData.getMonth() === card.month.getMonth()

                width: card.cell
                height: card.cell

                Rectangle {
                  anchors.centerIn: parent
                  width: card.cell - 4
                  height: card.cell - 4
                  radius: Theme.pill(width)
                  color: "transparent"
                  border.width: 2
                  border.color: Theme.colors.accent
                  visible: day.isToday
                }

                StyledText {
                  anchors.centerIn: parent
                  text: day.modelData.getDate()
                  font.pixelSize: 12
                  font.weight: day.isToday ? Font.Bold : Font.Normal
                  color: day.isToday ? Theme.colors.accent
                       : !day.inMonth ? Theme.colors.textSubtle
                       : day.index % 7 >= 5 ? Theme.colors.textMuted
                       : Theme.colors.text
                  opacity: day.inMonth ? 1 : 0.55
                }
              }
            }
          }
        }
      }
    }
  }
}
