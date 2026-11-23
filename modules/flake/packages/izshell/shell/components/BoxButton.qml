import QtQuick
import QtQuick.Layouts
import qs.data

Clickable {
  id: root

  property string text: ""
  property string icon: ""
  property bool filled: false
  property color fillColor: Theme.colors.accent
  property int fontSize: 12
  opacity: enabled ? 1 : 0.5

  implicitWidth: text === "" ? implicitHeight : row.implicitWidth + 28
  implicitHeight: 36
  radius: Theme.radiusSm
  color: filled ? (hovered ? Qt.lighter(fillColor, 1.08) : fillColor)
       : hovered ? Theme.colors.surfaceRaised
       : "transparent"
  border.width: 1
  border.color: filled ? fillColor : Theme.colors.borderStrong

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 6

    MyIcon {
      visible: root.icon !== ""
      icon: root.icon
      size: Math.round(root.fontSize * 1.25)
      color: root.filled ? Theme.colors.textOnAccent : Theme.colors.text
    }

    StyledText {
      visible: root.text !== ""
      text: root.text
      font.pixelSize: root.fontSize
      font.weight: Font.DemiBold
      color: root.filled ? Theme.colors.textOnAccent : Theme.colors.text
    }
  }
}
