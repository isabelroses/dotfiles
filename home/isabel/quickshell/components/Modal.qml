import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import qs.data

PanelWindow {
  id: root

  property string namespace: "modal"
  default property alias content: wrapper.data

  signal dismissed()

  color: "transparent"
  anchors { top: true; bottom: true; left: true; right: true }
  exclusionMode: ExclusionMode.Ignore
  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.namespace: namespace
  WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

  Rectangle {
    anchors.fill: parent
    color: Settings.colors.scrim
    opacity: holder.opacity

    MouseArea {
      anchors.fill: parent
      onClicked: root.dismissed()
    }
  }

  FocusScope {
    id: holder
    anchors.centerIn: parent
    implicitWidth: wrapper.implicitWidth
    implicitHeight: wrapper.implicitHeight
    width: implicitWidth
    height: implicitHeight
    focus: true
    Keys.onEscapePressed: root.dismissed()

    opacity: 0
    scale: 0.96
    Component.onCompleted: { opacity = 1; scale = 1; }
    Behavior on opacity { NumberAnimation { duration: Settings.animNormal } }
    Behavior on scale { NumberAnimation { duration: Settings.animNormal; easing.type: Easing.OutCubic } }

    WrapperMouseArea {
      id: wrapper
      anchors.fill: parent
    }
  }
}
