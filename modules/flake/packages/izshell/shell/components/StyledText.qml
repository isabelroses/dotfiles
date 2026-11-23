import QtQuick
import qs.data

Text {
    property bool mono: false
    property bool serif: false

    color: Theme.colors.text
    font.family: serif ? Theme.fonts.serif : mono ? Theme.fonts.mono : Theme.fonts.sans
    font.pixelSize: 13
    elide: Text.ElideRight
    // native hinting mangles large serif curves
    renderType: serif ? Text.QtRendering : Text.NativeRendering
}
