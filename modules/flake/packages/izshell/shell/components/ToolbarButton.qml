import QtQuick
import qs.data

// A FloatingToolbar button: icon, optional label and key hint; `active` tints it.
Clickable {
  id: root

  property string icon
  property string label: ""
  property string hint: ""
  property bool active: false
  property real iconRotation: 0
  readonly property color tint: active ? Theme.colors.accent : Theme.colors.text

  anchors.verticalCenter: parent.verticalCenter
  implicitWidth: label === "" ? 44 : row.implicitWidth + 24
  implicitHeight: 44
  radius: Theme.innerRadius
  color: active ? Theme.colors.accentSoft : hovered ? Theme.colors.surfaceRaised : "transparent"

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 8

    MyIcon {
      anchors.verticalCenter: parent.verticalCenter
      icon: root.icon
      rotation: root.iconRotation
      size: 16
      color: root.hovered ? Theme.colors.accent : root.tint
    }
    StyledText {
      visible: root.label !== ""
      anchors.verticalCenter: parent.verticalCenter
      text: root.label
      font.pixelSize: 13
      color: root.tint
    }
    StyledText {
      visible: root.hint !== ""
      anchors.verticalCenter: parent.verticalCenter
      text: root.hint
      mono: true
      font.pixelSize: 10
      color: Theme.colors.textSubtle
    }
  }
}
