import QtQuick
import QtQuick.Layouts
import qs.data
import qs.services

MyIcon {
    Layout.alignment: Qt.AlignCenter
    icon: Pipewire.sinkIcon
    size: 16
    color: Pipewire.sinkMuted ? Settings.colors.textSubtle : Settings.colors.text

    BarTooltip {
        text: (Pipewire.sinkMuted ? "Muted · " : Pipewire.sinkVolumeText + " · ") + Pipewire.nodeName(Pipewire.sink)
    }
}
