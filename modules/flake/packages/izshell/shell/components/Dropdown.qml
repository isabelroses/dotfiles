import QtQuick
import QtQuick.Controls.Basic
import qs.data

// A themed picker. `options` is [{ value, label }]; `value` is the selected
// value and `picked(value)` fires when the user chooses one.
ComboBox {
  id: root

  property var options: []
  property var value: undefined
  property int fontSize: 12

  signal picked(value: var)

  model: options
  textRole: "label"
  valueRole: "value"
  currentIndex: options.findIndex(o => o.value === value)
  displayText: currentIndex >= 0 ? options[currentIndex].label : "—"
  onActivated: (index) => root.picked(options[index].value)

  implicitHeight: 32
  implicitWidth: 220
  font.pixelSize: fontSize
  font.family: Settings.fonts.sans

  background: Rectangle {
    radius: Settings.radiusSm
    color: root.hovered || root.popup.visible ? Settings.colors.surfaceRaised : Settings.colors.base
    border.width: 1
    border.color: root.popup.visible ? Settings.colors.accent : Settings.colors.borderStrong
    Behavior on color { ColorAnimation { duration: Settings.animFast } }
  }

  contentItem: StyledText {
    leftPadding: 10
    rightPadding: root.indicator.width + 6
    text: root.displayText
    font.pixelSize: root.fontSize
    verticalAlignment: Text.AlignVCenter
  }

  indicator: MyIcon {
    x: root.width - width - 10
    y: (root.height - height) / 2
    icon: "pan-down-symbolic"
    size: 12
    color: Settings.colors.textMuted
  }

  delegate: ItemDelegate {
    id: item
    required property var modelData
    required property int index
    width: ListView.view.width
    height: 30
    highlighted: root.highlightedIndex === index

    background: Rectangle {
      radius: Math.max(0, Settings.radiusSm - 2)
      color: item.highlighted ? Settings.colors.surfaceRaised : "transparent"
    }

    contentItem: StyledText {
      leftPadding: 4
      text: item.modelData.label
      font.pixelSize: root.fontSize
      color: item.index === root.currentIndex ? Settings.colors.accent : Settings.colors.text
      font.weight: item.index === root.currentIndex ? Font.DemiBold : Font.Normal
      verticalAlignment: Text.AlignVCenter
    }
  }

  popup: Popup {
    y: root.height + 4
    width: Math.max(root.width, 200)
    implicitHeight: Math.min(list.contentHeight + 8, 300)
    padding: 4

    background: Rectangle {
      radius: Settings.radiusSm
      color: Settings.colors.base
      border.width: 1
      border.color: Settings.colors.borderStrong
    }

    contentItem: ListView {
      id: list
      clip: true
      model: root.popup.visible ? root.delegateModel : null
      currentIndex: root.highlightedIndex
      boundsBehavior: Flickable.StopAtBounds
      ScrollIndicator.vertical: ScrollIndicator {}
    }
  }
}
