import QtQuick
import QtQuick.Layouts
import qs.data

RowLayout {
  id: root

  property string text: ""
  property color tint: Settings.colors.accent

  spacing: 8

  Rectangle {
    implicitWidth: 6
    implicitHeight: 6
    color: root.tint
  }

  StyledText {
    text: root.text.toUpperCase()
    color: Settings.colors.textSubtle
    font.pixelSize: 10
    font.weight: Font.DemiBold
    font.letterSpacing: 1.2
  }
}
