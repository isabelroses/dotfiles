import QtQuick
import qs.data

// The shell's motion: Settings' duration and easing curve. Set `duration` for
// a quicker or slower one; the curve stays.
NumberAnimation {
  duration: Settings.animNormal
  easing.type: Easing.BezierSpline
  easing.bezierCurve: Settings.curve
}
