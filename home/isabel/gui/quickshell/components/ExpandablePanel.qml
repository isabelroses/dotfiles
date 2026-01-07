import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "root:/data"

Rectangle {
    id: root

    property string title: ""
    property string subtitle: ""
    property bool expanded: false
    property alias content: contentLoader.sourceComponent
    property int contentHeight: 150

    Layout.fillWidth: true
    Layout.preferredHeight: expanded ? contentLoader.item?.height + 48 : 0
    visible: expanded
    radius: 8
    color: Settings.colors.backgroundLighter
    clip: true

    Behavior on Layout.preferredHeight {
        NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true

            Text {
                text: root.title
                color: Settings.colors.foreground
                font {
                    pixelSize: 13
                    weight: Font.Medium
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                text: root.subtitle
                color: Settings.colors.accent
                font.pixelSize: 11
                visible: root.subtitle !== ""
            }
        }

        Loader {
            id: contentLoader
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(item?.implicitHeight ?? 0, root.contentHeight)
        }
    }
}
