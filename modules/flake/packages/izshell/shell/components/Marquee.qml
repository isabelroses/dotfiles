import QtQuick
import QtQuick.Effects
import qs.data

// A single line of text that drifts sideways when it's too long to fit, but
// only while `playing` is true; otherwise it sits still. Text that doesn't fit
// is faded out at the edges rather than cut off with an ellipsis.
Item {
  id: root

  property alias text: first.text
  property alias color: first.color
  property alias font: first.font
  property bool playing: false
  // seconds to rest at the start of each pass, and drift speed in px/s
  property real rest: 1.2
  property real speed: 24
  property int gap: 32

  readonly property real textWidth: first.implicitWidth
  readonly property bool tooLong: textWidth > width + 0.5
  readonly property bool moving: visible && playing && tooLong
  readonly property real loop: textWidth + gap

  implicitHeight: first.implicitHeight
  clip: true

  // two copies side by side, so scrolling one loop's width wraps seamlessly
  Row {
    id: strip
    x: 0
    anchors.verticalCenter: parent.verticalCenter
    spacing: root.gap

    StyledText {
      id: first
      wrapMode: Text.NoWrap
    }

    StyledText {
      visible: root.moving
      text: first.text
      color: first.color
      font: first.font
      wrapMode: Text.NoWrap
    }
  }

  SequentialAnimation {
    running: root.moving
    loops: Animation.Infinite
    onRunningChanged: if (!running) strip.x = 0

    PropertyAction { target: strip; property: "x"; value: 0 }
    PauseAnimation { duration: root.rest * 1000 }
    NumberAnimation {
      target: strip
      property: "x"
      to: -root.loop
      duration: Math.max(3000, root.loop / root.speed * 1000)
    }
  }

  onTextChanged: strip.x = 0

  // soft edges only when there's overflow to hide; the start edge fades in
  // once the text has moved off it
  layer.enabled: tooLong
  layer.effect: MultiEffect {
    maskEnabled: true
    maskSource: edges
    maskThresholdMin: 0.5
    maskSpreadAtMin: 1
  }

  Item {
    id: edges
    anchors.fill: parent
    visible: false
    layer.enabled: true

    Rectangle {
      id: fadeRect
      anchors.fill: parent
      readonly property real fade: 14 / Math.max(1, root.width)
      gradient: Gradient {
        orientation: Gradient.Horizontal
        GradientStop { position: 0; color: strip.x < 0 ? "transparent" : "white" }
        GradientStop { position: fadeRect.fade; color: "white" }
        GradientStop { position: 1 - fadeRect.fade; color: "white" }
        GradientStop { position: 1; color: "transparent" }
      }
    }
  }
}
