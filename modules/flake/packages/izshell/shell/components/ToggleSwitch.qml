import QtQuick
import qs.data

// On/off switch in the accent; `toggled` asks the owner to flip `on`.
Clickable {
  id: sw

  property bool on: false
  signal toggled()

  onClicked: sw.toggled()
  implicitWidth: 40
  implicitHeight: 22
  radius: Theme.pill(height)
  color: on ? Theme.colors.accent : Theme.colors.surfaceRaised
  border.width: 1
  border.color: on ? Theme.colors.accent : Theme.colors.borderStrong

  Rectangle {
    width: 14; height: 14
    radius: Theme.pill(width)
    anchors.verticalCenter: parent.verticalCenter
    x: sw.on ? parent.width - width - 4 : 4
    color: sw.on ? Theme.colors.textOnAccent : Theme.colors.textMuted
    Behavior on x { Anim {} }
  }
}
