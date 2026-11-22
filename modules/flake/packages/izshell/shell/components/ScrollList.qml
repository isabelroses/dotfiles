import QtQuick
import QtQuick.Controls.Basic

// A ListView that clips, stops at its ends and shows a scrollbar when it overflows.
ListView {
  clip: true
  boundsBehavior: Flickable.StopAtBounds
  ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
}
