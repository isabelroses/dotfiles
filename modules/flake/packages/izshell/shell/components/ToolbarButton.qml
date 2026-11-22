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
  readonly property color tint: active ? Settings.colors.accent : Settings.colors.text

  anchors.verticalCenter: parent.verticalCenter
  implicitWidth: label === "" ? 44 : row.implicitWidth + 24
  implicitHeight: 44
  radius: Settings.innerRadius
  color: active ? Settings.colors.accentSoft : hovered ? Settings.colors.surfaceRaised : "transparent"

  Row {
    id: row
    anchors.centerIn: parent
    spacing: 8

    MyIcon {
      anchors.verticalCenter: parent.verticalCenter
      icon: root.icon
      rotation: root.iconRotation
      size: 16
      color: root.hovered ? Settings.colors.accent : root.tint
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
      color: Settings.colors.textSubtle
    }
  }
}
