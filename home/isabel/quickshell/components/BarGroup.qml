import QtQuick
import QtQuick.Layouts
import qs.data

// Lays children out along the bar: a column on a side bar, a row on a top/bottom bar.
GridLayout {
  property real spacing: 10

  flow: Settings.barVertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
  rows: Settings.barVertical ? 99 : 1
  columns: Settings.barVertical ? 1 : 99
  rowSpacing: spacing
  columnSpacing: spacing
}
