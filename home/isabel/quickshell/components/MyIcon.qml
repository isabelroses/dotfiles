import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import qs.data

Item {
    id: root

    property string icon: ""
    property int size: 18
    property color color: Settings.colors.text

    implicitWidth: size
    implicitHeight: size

    IconImage {
        id: iconSource
        anchors.fill: parent
        source: Quickshell.iconPath(root.icon)
        visible: root.icon !== ""

        layer.enabled: true
        layer.effect: MultiEffect {
            brightness: 1.0
            colorization: 1.0
            colorizationColor: root.color
        }

        Behavior on opacity { NumberAnimation { duration: Settings.animFast } }
    }
}
