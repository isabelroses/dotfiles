import QtQuick
import Quickshell.Widgets
import qs.data
import qs.services

ClippingWrapperRectangle {
    id: root

    property int size: 52
    radius: Settings.radiusSm
    implicitWidth: size
    implicitHeight: size
    color: Settings.colors.overlay

    Item {
        implicitWidth: root.size
        implicitHeight: root.size

        MyIcon {
            anchors.centerIn: parent
            visible: art.status !== Image.Ready
            icon: "folder-music-symbolic"
            size: 20
            color: Settings.colors.textSubtle
        }

        Image {
            id: art
            anchors.fill: parent
            source: Media.selectedPlayer?.trackArtUrl ?? ""
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            sourceSize: Qt.size(192, 192)
        }
    }
}
