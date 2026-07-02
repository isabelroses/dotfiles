import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Widgets
import "root:/data"

Item {
    id: root

    property string icon: ""
    property int size: 18
    property bool invert: false

    implicitWidth: size
    implicitHeight: size

    IconImage {
        id: iconSource
        anchors.fill: parent
        source: Quickshell.iconPath(root.icon)

        layer.enabled: true
        layer.effect: MultiEffect {
            brightness: 1.0
            colorization: 1.0
            colorizationColor: root.invert ? "#1e1e2e" : "#cdd6f4"
        }
    }
}
