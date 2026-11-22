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
  radius: Settings.pill(height)
  color: on ? Settings.colors.accent : Settings.colors.surfaceRaised
  border.width: 1
  border.color: on ? Settings.colors.accent : Settings.colors.borderStrong

  Rectangle {
    width: 14; height: 14
    radius: Settings.pill(width)
    anchors.verticalCenter: parent.verticalCenter
    x: sw.on ? parent.width - width - 4 : 4
    color: sw.on ? Settings.colors.textOnAccent : Settings.colors.textMuted
    Behavior on x { Anim {} }
  }
}
