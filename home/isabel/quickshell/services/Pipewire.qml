pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire as QsPipewire
import QtQuick

Singleton {
    id: root

    readonly property QsPipewire.PwNode sink: QsPipewire.Pipewire.defaultAudioSink
    readonly property real sinkVolume: sink?.audio?.volume ?? 0
    readonly property bool sinkMuted: sink?.audio?.muted ?? false
    readonly property string sinkVolumeText: Math.round(sinkVolume * 100) + "%"
    readonly property string sinkIcon: levelIcon("audio-volume", sinkMuted, sinkVolume)

    readonly property QsPipewire.PwNode source: QsPipewire.Pipewire.defaultAudioSource
    readonly property real sourceVolume: source?.audio?.volume ?? 0
    readonly property bool sourceMuted: source?.audio?.muted ?? false
    readonly property string sourceVolumeText: Math.round(sourceVolume * 100) + "%"
    readonly property string sourceIcon: levelIcon("microphone-sensitivity", sourceMuted, sourceVolume)

    readonly property var groups: {
        const g = { sinks: [], streams: [], micUsers: [], screenShares: [] };
        for (const n of QsPipewire.Pipewire.nodes.values) {
            const name = n.name ?? "";
            switch (n.type) {
            case QsPipewire.PwNodeType.AudioSink:
                g.sinks.push(n);
                break;
            case QsPipewire.PwNodeType.AudioOutStream:
                g.streams.push(n);
                break;
            case QsPipewire.PwNodeType.AudioInStream:
                if (!name.startsWith("effect_") && n.properties?.["stream.monitor"] !== "true") g.micUsers.push(n);
                break;
            case QsPipewire.PwNodeType.VideoSource:
                if (name.includes("xdpw")) g.screenShares.push(n);
                break;
            }
        }
        return g;
    }
    readonly property var sinks: groups.sinks
    readonly property var streams: groups.streams
    readonly property var micUsers: groups.micUsers
    readonly property var screenShares: groups.screenShares

    QsPipewire.PwObjectTracker {
        objects: [root.sink, root.source, ...root.streams, ...root.micUsers]
    }

    function levelIcon(base: string, muted: bool, volume: real): string {
        if (muted || volume <= 0) return `${base}-muted-symbolic`;
        if (volume > 0.66) return `${base}-high-symbolic`;
        if (volume > 0.33) return `${base}-medium-symbolic`;
        return `${base}-low-symbolic`;
    }

    function setSinkVolume(volume: real): void {
        if (sink?.audio) sink.audio.volume = Math.max(0, Math.min(1, volume));
    }

    function toggleSinkMute(): void {
        if (sink?.audio) sink.audio.muted = !sink.audio.muted;
    }

    function toggleSourceMute(): void {
        if (source?.audio) source.audio.muted = !source.audio.muted;
    }

    function setDefaultSink(node: QsPipewire.PwNode): void {
        QsPipewire.Pipewire.preferredDefaultAudioSink = node;
    }

    function nodeName(node: QsPipewire.PwNode): string {
        return node?.description || node?.nickname || node?.name || "Unknown";
    }

    function nodeIcon(node: QsPipewire.PwNode): string {
        const n = (node?.name ?? "").toLowerCase();
        if (n.includes("bluez")) return "audio-headphones-symbolic";
        if (n.includes("hdmi")) return "video-display-symbolic";
        if (n.includes("usb")) return "audio-headset-symbolic";
        return "audio-speakers-symbolic";
    }

    function streamName(node: QsPipewire.PwNode): string {
        const name = node?.properties?.["application.name"] || node?.description || node?.name || "Unknown";
        return DesktopEntries.heuristicLookup(name)?.name || name.charAt(0).toUpperCase() + name.slice(1);
    }

    function streamIcon(node: QsPipewire.PwNode): string {
        const p = node?.properties ?? {};
        const bin = (p["application.process.binary"] ?? "").toLowerCase().replace(/^\./, "").replace(/-wrapped$/, "");
        const entry = DesktopEntries.heuristicLookup(p["application.name"] || bin);
        return p["application.icon-name"] || entry?.icon || bin || "audio-x-generic-symbolic";
    }

    reloadableId: "pipewire"
}
