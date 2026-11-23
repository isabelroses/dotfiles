pragma Singleton

import Quickshell
import Quickshell.Services.Pipewire as QsPipewire
import QtQuick
import qs.data

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
    readonly property string sourceIcon: levelIcon("microphone-sensitivity", sourceMuted, sourceVolume)

    readonly property var groups: {
        const g = { sinks: [], sources: [], streams: [], micUsers: [], screenShares: [] };
        for (const n of QsPipewire.Pipewire.nodes.values) {
            const name = n.name ?? "";
            switch (n.type) {
            case QsPipewire.PwNodeType.AudioSink:
                g.sinks.push(n);
                break;
            case QsPipewire.PwNodeType.AudioSource:
                if (!name.endsWith(".monitor")) g.sources.push(n);
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
    readonly property list<QsPipewire.PwNode> sinks: groups.sinks
    readonly property list<QsPipewire.PwNode> sources: groups.sources
    readonly property list<QsPipewire.PwNode> streams: groups.streams
    readonly property list<QsPipewire.PwNode> micUsers: groups.micUsers
    readonly property list<QsPipewire.PwNode> screenShares: groups.screenShares

    // For views: these lists are rebuilt whenever any node changes, and a model
    // that only adds and removes the rows that did keeps the rest (and what is
    // being dragged in them) alive.
    readonly property ScriptModel sinkModel: ScriptModel { values: [...root.sinks] }
    readonly property ScriptModel sourceModel: ScriptModel { values: [...root.sources] }
    readonly property ScriptModel streamModel: ScriptModel { values: [...root.streams] }
    readonly property ScriptModel micUserModel: ScriptModel { values: [...root.micUsers] }

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

    function setSourceVolume(volume: real): void {
        if (source?.audio) source.audio.volume = Math.max(0, Math.min(1, volume));
    }

    function toggleSourceMute(): void {
        if (source?.audio) source.audio.muted = !source.audio.muted;
    }

    function setDefaultSource(node: QsPipewire.PwNode): void {
        QsPipewire.Pipewire.preferredDefaultAudioSource = node;
    }

    function setDefaultSink(node: QsPipewire.PwNode): void {
        QsPipewire.Pipewire.preferredDefaultAudioSink = node;
    }

    // sends an app's stream to another device; wireplumber keeps it there
    function moveStream(stream: QsPipewire.PwNode, target: QsPipewire.PwNode): void {
        if (stream && target)
            Quickshell.execDetached(["pw-metadata", String(stream.id), "target.object", target.name, "Spa:String"]);
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

    function inputIcon(node: QsPipewire.PwNode): string {
        const n = (node?.name ?? "").toLowerCase();
        if (n.includes("bluez")) return "audio-headset-symbolic";
        if (n.includes("webcam") || n.includes("camera")) return "camera-web-symbolic";
        return "audio-input-microphone-symbolic";
    }

    function streamName(node: QsPipewire.PwNode): string {
        const name = node?.properties?.["application.name"] || node?.description || node?.name || "Unknown";
        return Utils.appName(name);
    }

    function streamIcon(node: QsPipewire.PwNode): string {
        const p = node?.properties ?? {};
        const bin = (p["application.process.binary"] ?? "").toLowerCase().replace(/^\./, "").replace(/-wrapped$/, "");
        const entry = DesktopEntries.heuristicLookup(p["application.name"] || bin);
        return p["application.icon-name"] || entry?.icon || bin || "audio-x-generic-symbolic";
    }

    reloadableId: "pipewire"
}
