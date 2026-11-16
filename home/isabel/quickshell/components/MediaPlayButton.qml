import QtQuick
import qs.data
import qs.services

Clickable {
    id: root

    property int diameter: 34
    onClicked: Media.selectedPlayer?.togglePlaying()
    implicitWidth: diameter
    implicitHeight: diameter
    radius: diameter / 2
    color: hovered ? Qt.lighter(Settings.colors.accent, 1.08) : Settings.colors.accent
    scale: pressed ? 0.92 : 1
    Behavior on scale { NumberAnimation { duration: 90 } }

    MyIcon {
        anchors.centerIn: parent
        icon: Media.playing ? "media-playback-pause-symbolic" : "media-playback-start-symbolic"
        size: root.diameter * 0.45
        color: Settings.colors.textOnAccent
    }
}
