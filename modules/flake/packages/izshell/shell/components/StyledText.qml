import QtQuick
import qs.data

Text {
    property bool mono: false
    property bool serif: false

    color: Settings.colors.text
    font.family: serif ? Settings.fonts.serif : mono ? Settings.fonts.mono : Settings.fonts.sans
    font.pixelSize: 13
    elide: Text.ElideRight
    // native hinting mangles large serif curves
    renderType: serif ? Text.QtRendering : Text.NativeRendering
}
