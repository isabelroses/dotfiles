import QtQuick
import qs.data

Clickable {
  id: root

  property string icon: ""
  property bool expanded: false
  property color tint: Settings.colors.accent

  implicitWidth: 34
  implicitHeight: 34
  radius: Settings.radiusSm
  color: expanded ? Utils.withAlpha(root.tint, 0.14) : hovered ? Settings.colors.overlay : Settings.colors.surfaceRaised
  border.width: 1
  border.color: expanded ? root.tint : Settings.colors.border

  Behavior on color { ColorAnimation { duration: Settings.animFast } }

  MyIcon {
    anchors.centerIn: parent
    icon: root.icon
    size: 14
    color: root.expanded ? root.tint : Settings.colors.textMuted
  }
}
