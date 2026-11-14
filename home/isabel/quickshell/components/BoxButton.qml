import QtQuick
import QtQuick.Layouts
import qs.data

Clickable {
  id: root

  property string text: ""
  property string icon: ""
  property bool filled: false
  property color fillColor: Settings.colors.accent
  property int fontSize: 12


  implicitWidth: text === "" ? implicitHeight : row.implicitWidth + 28
  implicitHeight: 36
  radius: Settings.radiusSm
  color: filled ? (hovered ? Qt.lighter(fillColor, 1.08) : fillColor)
       : hovered ? Settings.colors.surfaceRaised
       : "transparent"
  border.width: 1
  border.color: filled ? fillColor : Settings.colors.borderStrong
  Behavior on color { ColorAnimation { duration: Settings.animFast } }

  RowLayout {
    id: row
    anchors.centerIn: parent
    spacing: 6

    MyIcon {
      visible: root.icon !== ""
      icon: root.icon
      size: Math.round(root.fontSize * 1.25)
      color: root.filled ? Settings.colors.textOnAccent : Settings.colors.text
    }

    StyledText {
      visible: root.text !== ""
      text: root.text
      font.pixelSize: root.fontSize
      font.weight: Font.DemiBold
      color: root.filled ? Settings.colors.textOnAccent : Settings.colors.text
    }
  }
}
