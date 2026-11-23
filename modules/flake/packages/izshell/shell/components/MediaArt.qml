import QtQuick
import Quickshell.Widgets
import qs.data
import qs.services

ClippingWrapperRectangle {
    id: root

    property int size: 52
    radius: Theme.radiusSm
    implicitWidth: size
    implicitHeight: size
    color: Theme.colors.overlay

    Item {
        implicitWidth: root.size
        implicitHeight: root.size

        MyIcon {
            anchors.centerIn: parent
            visible: art.status !== Image.Ready
            icon: "folder-music-symbolic"
            size: 20
            color: Theme.colors.textSubtle
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
