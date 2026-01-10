pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire as QsPipewire
import QtQuick

Singleton {
    id: root

    // Track the default audio sink
    QsPipewire.PwObjectTracker {
        objects: [QsPipewire.Pipewire.defaultAudioSink, QsPipewire.Pipewire.defaultAudioSource]
    }

    // Default audio sink (speakers/headphones)
    readonly property QsPipewire.PwNode sink: QsPipewire.Pipewire.defaultAudioSink
    readonly property real sinkVolume: sink?.audio?.volume ?? 0
    readonly property bool sinkMuted: sink?.audio?.muted ?? false

    // Default audio source (microphone)
    readonly property QsPipewire.PwNode source: QsPipewire.Pipewire.defaultAudioSource
    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property bool sourceMuted: source?.audio?.muted ?? false

    // All nodes for detailed view
    readonly property var nodes: QsPipewire.Pipewire.nodes

    // Icon based on volume and mute state for sink
    readonly property string sinkIcon: {
        if (sinkMuted) return "audio-volume-muted-symbolic";
        if (sinkVolume > 0.66) return "audio-volume-high-symbolic";
        if (sinkVolume > 0.33) return "audio-volume-medium-symbolic";
        if (sinkVolume > 0) return "audio-volume-low-symbolic";
        return "audio-volume-muted-symbolic";
    }

    // Icon based on volume and mute state for source
    readonly property string sourceIcon: {
        if (sourceMuted) return "microphone-sensitivity-muted-symbolic";
        if (sourceVolume > 0.66) return "microphone-sensitivity-high-symbolic";
        if (sourceVolume > 0.33) return "microphone-sensitivity-medium-symbolic";
        if (sourceVolume > 0) return "microphone-sensitivity-low-symbolic";
        return "microphone-sensitivity-muted-symbolic";
    }

    // Volume percentage string
    readonly property string sinkVolumeText: Math.round(sinkVolume * 100) + "%"
    readonly property string sourceVolumeText: Math.round(sourceVolume * 100) + "%"

    // Functions to control sink (speakers)
    function setSinkVolume(volume: real): void {
        if (sink?.audio) {
            sink.audio.volume = Math.max(0, Math.min(1, volume));
        }
    }

    function toggleSinkMute(): void {
        if (sink?.audio) {
            sink.audio.muted = !sink.audio.muted;
        }
    }

    function setSinkMuted(muted: bool): void {
        if (sink?.audio) {
            sink.audio.muted = muted;
        }
    }

    // Functions to control source (microphone)
    function setSourceVolume(volume: real): void {
        if (source?.audio) {
            source.audio.volume = Math.max(0, Math.min(1, volume));
        }
    }

    function toggleSourceMute(): void {
        if (source?.audio) {
            source.audio.muted = !source.audio.muted;
        }
    }

    function setSourceMuted(muted: bool): void {
        if (source?.audio) {
            source.audio.muted = muted;
        }
    }

    reloadableId: "pipewire"
}

