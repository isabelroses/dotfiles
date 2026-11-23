import QtQuick
import qs.data

// One-of-a-few picker. `options` holds strings or { value, label }.
Row {
  id: root

  property var options: []
  property var value: undefined
  signal picked(value: var)

  // square corners: a joined segmented strip; rounded: separate pills
  spacing: Theme.radiusSm > 2 ? 4 : -1

  Repeater {
    model: root.options

    Clickable {
      required property var modelData
      readonly property var optionValue: modelData?.value ?? modelData
      readonly property bool selected: root.value === optionValue
      onClicked: root.picked(optionValue)
      width: Math.max(64, optText.implicitWidth + 24)
      height: 28
      radius: Theme.radiusSm > 2 ? Theme.radiusSm : 0
      z: selected ? 1 : 0
      color: selected ? Theme.colors.accent : hovered ? Theme.colors.surfaceRaised : Theme.colors.base
      border.width: 1
      border.color: selected ? Theme.colors.accent : Theme.colors.borderStrong

      StyledText {
        id: optText
        anchors.centerIn: parent
        text: parent.modelData?.label ?? parent.modelData
        font.pixelSize: 12
        font.weight: parent.selected ? Font.DemiBold : Font.Normal
        color: parent.selected ? Theme.colors.textOnAccent : Theme.colors.textMuted
      }
    }
  }
}
