import QtQuick
import qs.data

// The shell's motion: Theme's duration and easing curve. Set `duration` for
// a quicker or slower one; the curve stays.
NumberAnimation {
  duration: Theme.animNormal
  easing.type: Easing.BezierSpline
  easing.bezierCurve: Theme.curve
}
