import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic
import "root:/data"
import "root:/components"

RowLayout {
    id: root

    property string icon: ""
    property real value: 0
    property real from: 0
    property real to: 1
    property color accentColor: Settings.colors.accent
    property bool showPercentage: true
    property bool iconClickable: false

    signal moved(real value)
    signal iconClicked()

    Layout.fillWidth: true
    spacing: 12

    IconButton {
        icon: root.icon
        size: 18
        onClicked: root.iconClicked()
    }

    Slider {
        id: slider
        Layout.fillWidth: true
        from: root.from
        to: root.to
        value: root.value

        onMoved: root.moved(value)

        background: Rectangle {
            x: slider.leftPadding
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: slider.availableWidth
            height: 4
            radius: 2
            color: Settings.colors.backgroundLightest

            Rectangle {
                width: slider.visualPosition * parent.width
                height: parent.height
                radius: 2
                color: root.accentColor
            }
        }

        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
            y: slider.topPadding + slider.availableHeight / 2 - height / 2
            width: 14
            height: 14
            radius: 7
            color: slider.pressed ? root.accentColor : Settings.colors.foreground
        }
    }

    Text {
        visible: root.showPercentage
        text: Math.round((slider.value - root.from) / (root.to - root.from) * 100) + "%"
        color: Settings.colors.foreground
        opacity: 0.7
        font.pixelSize: 12
        Layout.preferredWidth: 36
    }
}
