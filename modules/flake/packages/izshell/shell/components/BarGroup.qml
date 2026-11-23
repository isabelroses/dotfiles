import QtQuick
import QtQuick.Layouts
import qs.data

// Lays children out along the bar: a column on a side bar, a row on a top/bottom bar.
GridLayout {
  property real spacing: 10

  flow: BarPlacement.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
  rows: BarPlacement.vertical ? 99 : 1
  columns: BarPlacement.vertical ? 1 : 99
  rowSpacing: spacing
  columnSpacing: spacing
}
