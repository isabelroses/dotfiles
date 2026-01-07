import org.kde.kirigami
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

    Icon {
        id: iconSource
        anchors.fill: parent
        source: Quickshell.iconPath(root.icon)

        isMask: true
        // FIXME:
        // color: Settings.colors.foreground
        color: invert ? "#1e1e2e" : "#cdd6f4"
    }
}
