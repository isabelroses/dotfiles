import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import "root:/data"

Item {
    id: root

    Layout.alignment: Qt.AlignCenter
    implicitWidth: 20
    implicitHeight: 20

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property PwNode sink: Pipewire.defaultAudioSink
    property real volume: sink?.audio?.volume ?? 0
    property bool muted: sink?.audio?.muted ?? false

    property string iconName: {
        if (muted) return "audio-volume-muted-symbolic";
        if (volume > 0.66) return "audio-volume-high-symbolic";
        if (volume > 0.33) return "audio-volume-medium-symbolic";
        if (volume > 0) return "audio-volume-low-symbolic";
        return "audio-volume-muted-symbolic";
    }

    IconButton {
        anchors.centerIn: parent
        icon: root.iconName
        size: 18
        onClicked: {
            if (root.sink?.audio) {
                root.sink.audio.muted = !root.sink.audio.muted;
            }
        }
    }
}
