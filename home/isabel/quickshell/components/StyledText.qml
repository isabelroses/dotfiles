import QtQuick
import qs.data

Text {
    property bool mono: false

    color: Settings.colors.text
    font.family: mono ? Settings.fonts.mono : Settings.fonts.sans
    font.pixelSize: 13
    renderType: Text.NativeRendering
}
