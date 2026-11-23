import QtQuick
import qs.data

// The password as a growing cross of squares instead of dots:
// the first 13 fill a diamond around the centre in a set order,
// then the four arms grow outwards one square at a time.
Item {
  id: root

  property int count: 0
  property bool failed: false
  property int cell: 12
  property int gap: 3

  readonly property int pitch: cell + gap
  readonly property var inner: [[0, 0], [-1, -1], [1, -1], [1, 1], [-1, 1], [-2, 0], [0, -2],
                                [2, 0], [0, 2], [-1, 0], [0, -1], [1, 0], [0, 1]]
  // reach of the cross from the centre, in cells
  readonly property int reach: count <= 1 ? 0 : count <= 5 ? 1 : count <= 13 ? 2 : 3 + Math.floor((count - 14) / 4)

  function spot(i: int): var {
    if (i < inner.length) return inner[i];
    const k = i - inner.length;
    const d = 3 + Math.floor(k / 4);
    return [[-d, 0], [0, -d], [d, 0], [0, d]][k % 4];
  }

  implicitWidth: (reach * 2 + 1) * pitch - gap
  implicitHeight: count > 0 ? implicitWidth : 0
  Behavior on implicitWidth { Anim {} }

  Repeater {
    model: root.count

    Rectangle {
      required property int index
      readonly property var at: root.spot(index)
      readonly property bool newest: index === root.count - 1

      width: root.cell
      height: root.cell
      x: root.width / 2 + at[0] * root.pitch - width / 2
      y: root.height / 2 + at[1] * root.pitch - height / 2
      radius: Theme.pill(width) / 2
      color: root.failed ? Theme.colors.error : newest ? Theme.colors.accent : Theme.colors.text
      Behavior on color { ColorAnimation { duration: Theme.animNormal } }

      scale: 0
      Component.onCompleted: scale = 1
      Behavior on scale { NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutBack } }
    }
  }
}
