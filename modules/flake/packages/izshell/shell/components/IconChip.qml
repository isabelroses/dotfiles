import QtQuick
import qs.data

Rectangle {
  id: root

  property alias icon: glyph.icon
  property alias iconSize: glyph.size
  property alias iconColor: glyph.color
  property int size: 32

  implicitWidth: size
  implicitHeight: size
  radius: Theme.radiusRound
  color: Theme.colors.overlay

  MyIcon {
    id: glyph
    anchors.centerIn: parent
  }
}
